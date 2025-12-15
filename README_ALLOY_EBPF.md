# Grafana Alloy eBPF Profiling Demo

This extends the Java + Pyroscope demo with node-level eBPF profiling using Grafana Alloy.
Alloy runs as a privileged DaemonSet, discovers pods via the Kubernetes API, and sends eBPF CPU
profiles to the existing Pyroscope instance.

Note: eBPF CPU profiling in Pyroscope currently focuses on native workloads (Go, Rust, C/C++, and
Python with frame pointers enabled). JVM workloads like `java-demo` are still best profiled via the
Java agent (JFR / async-profiler).

---

## What this manifest does

`alloy-pyroscope-ebpf.yaml` defines:

- A namespace: `observability-demo`
- A service account + RBAC (`alloy-ebpf`) so Alloy can `get`, `list`, and `watch` pods
- A ConfigMap `alloy-config` containing the Alloy configuration:
  - `discovery.kubernetes "pods"` – discovers all pods in the cluster
  - `discovery.relabel "local_pods"` – sets a `service_name` label of the form
    `ebpf/<namespace>/<container>` for each container
  - `pyroscope.write "pyro"` – sends profiles to
    `http://pyroscope.observability-demo.svc.cluster.local:4040`
  - `pyroscope.ebpf "ebpf"` – collects eBPF CPU profiles and forwards them to `pyro`
- A DaemonSet `alloy-ebpf-profiler`:
  - Runs `grafana/alloy:latest` on each node
  - Mounts `/etc/alloy/config.alloy` from the ConfigMap
  - Runs privileged with `hostPID: true` so eBPF can see host processes

---

## Prerequisites

- A running Kubernetes cluster (for example, kind).
- The Pyroscope server already deployed in the `observability-demo` namespace, with a Service named
  `pyroscope` exposing port `4040`.
- Optionally: application workloads in `observability-demo` (for example, the existing
  `java-demo` deployment).

---

## Deploying the eBPF profiler

From the `k8s/` directory:

```bash
kubectl apply -f alloy-pyroscope-ebpf.yaml
kubectl rollout status ds/alloy-ebpf-profiler -n observability-demo
```

Check that the Alloy DaemonSet pod is running:

```bash
kubectl get pods -n observability-demo -l app=alloy-ebpf -o wide
kubectl logs -n observability-demo -l app=alloy-ebpf --tail=50
```

In the logs you should see lines similar to:

- `eBPF tracer loaded`
- `Attached tracer program`
- `Attached sched monitor`

indicating that the eBPF profiler is active.

---

## Viewing eBPF profiles in Pyroscope

Open the Pyroscope UI (via NodePort or `kubectl port-forward`, depending on your setup), and:

1. Select the profile type:

   ```text
   process_cpu:cpu:nanoseconds:cpu:nanoseconds
   ```

2. In the labels or filters pane, look at:
   - `service_name` – values like `ebpf/<namespace>/<container>`
   - `pyroscope_spy` – used to distinguish eBPF vs other profilers (for example, `javaspy`, `gospy`,
     and so on)

Use these labels to filter and compare profiles collected via eBPF with those collected by
language-specific agents.
