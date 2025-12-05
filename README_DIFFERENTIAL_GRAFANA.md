# 📊 Differential Flamegraphs with Grafana + Pyroscope

This guide enables **performance regression detection** using **Grafana + Pyroscope differential flamegraphs**, extending the base Observability POC.

---

## 🔥 What This Adds

| Feature | Pyroscope Only | Grafana Integration |
|---|---|---|
| Flamegraphs | ✔ | ✔ |
| CPU breakdown table | ✔ | ✔ |
| Differential flamegraphs (baseline vs regression) | ❌ | **✔** |
| Compare two time windows | ❌ | **✔** |
| Regression heatmap visualization | ❌ | **✔** |
| Dashboards, alerting, history | Limited | **Full** |

---

## 1. Deploy Grafana

```bash
kubectl apply -f k8s/grafana.yaml -n observability-demo
kubectl rollout status deployment/grafana -n observability-demo
```

Port forward:

```bash
kubectl port-forward svc/grafana 3000:3000 -n observability-demo
```

Open UI:

```
http://localhost:3000
user: admin
pass: admin
```

---

## 2. Add Pyroscope as a Datasource

Grafana → **Connections → Add data source → Pyroscope**

Use address:

```
http://localhost:4040
```

Or within cluster:

```
http://pyroscope.observability-demo.svc.cluster.local:4040
```

Click **Save & Test**.

---

## 3. Enable Profiling & Flamegraph Features

```bash
kubectl set env deployment/grafana   -n observability-demo   GF_FEATURE_TOGGLES_ENABLE="profiling,flameGraphProfiling"   GF_PROFILING_DATASOURCES_ENABLED="true"

kubectl rollout restart deployment/grafana -n observability-demo
```

Refresh Grafana after restart.

---

## 4. Install Profiling Panels

In Grafana UI:

**Administration → Plugins → Install**

Install:

- Flamegraph Panel
- Profile Diff Panel
- Table Profiling Panel

---

## 5. Viewing Java Profiles

Navigate:

```
Grafana → Explore → Pyroscope datasource
```

Query example:

```
process_cpu:cpu:nanoseconds{service_name="java-demo"}
```

You should now see:

✔ Graph timeline  
✔ Table view  
✔ Flamegraph view  

---

## 6. Differential CPU Regression Detection

1. Run load (baseline)
2. Change workload/app (regression)
3. In *Explore* select **Compare profiles**
4. Select two different time ranges

Result:

- 🔴 Red = more CPU used vs baseline (regression)
- 🔵 Blue = reduced CPU usage (improvement)

Perfect for production regression tracking.

---

## 🔥 Example Use Case

| Deployment | Expected Result |
|---|---|
| Build A (baseline) | Stable CPU profile |
| Build B (new release) | Hot path grows red in diff flamegraph |

Allows early detection of:

- Code inefficiencies
- JVM GC or lock contention
- Hot loops introduced in PRs
- Microservice latency-side CPU regressions

---

## Long‑Term Value

This unlocks SRE‑grade observability:

📍 Detect regressions before customers notice  
📍 Visualize CPU hotspots over time  
📍 Integrate with alerts (p99 CPU ↑ > threshold)  
📍 Store historical performance snapshots  
📍 Build CI/CD profiling gates  

---

## Next Extensions

Optional improvements:

| Feature | Description |
|---|---|
| CI regression profiler | Fail PR if CPU > X% vs baseline |
| Offline SVG export tooling | Flamegraph artifacts for reports |
| eBPF mode | Remove JVM agent entirely |
| Performance dashboard | SLA burn‑down over weeks |

---

You now have a production‑ready flamegraph regression workflow. 🚀
