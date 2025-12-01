# 📘 Observability POC — eBPF Flamegraphs for Java in Kubernetes

This POC demonstrates how to collect **real-time call-stack flamegraphs** from **Java applications running inside Kubernetes pods** using **eBPF-based continuous profiling**.  
It is designed to model a **real-world banking production environment targeting RHEL9** while being fully runnable on **Ubuntu or any Linux laptop**.

## 🔧 Features

- eBPF-powered continuous profiling  
- Zero instrumentation (no JVM agents required)  
- JVM JIT + Native stack tracing  
- Kubernetes-aware container attribution  
- Full flamegraphs (CPU, time-diff, trends)  
- Lightweight sample Java workload  
- Pyroscope UI for visualization  

## 📂 Repository Structure

```
observability-poc/
├── k8s/
│   ├── pyroscope-daemonset.yaml
│   ├── pyroscope-server.yaml
│   └── java-demo-deployment.yaml
├── java-demo/
│   ├── Main.java
│   ├── Dockerfile
│   └── build.sh
├── scripts/
│   ├── load-generator.sh
│   ├── port-forward-pyroscope.sh
│   └── verify-ebpf.sh
└── README.md
```

## 🚀 1. Prerequisites

### Local Machine
- Linux laptop (Ubuntu recommended)
- Docker or Podman
- Kubernetes (Kind, Minikube, or MicroK8s)
- `kubectl` installed
- Kernel with BPF + BTF support (Ubuntu 22.04+ OK)

### To simulate RHEL9
```
./scripts/verify-ebpf.sh
```

## 📦 2. Build the Java Demo App

```
cd java-demo
./build.sh
```

## 📡 3. Start Kubernetes Cluster

### Using Kind
```
kind create cluster
```

### Using Minikube
```
minikube start --driver=docker
```

## 📥 4. Deploy Pyroscope Server

```
kubectl apply -f k8s/pyroscope-server.yaml
```

## 🐝 5. Deploy Pyroscope eBPF Agent DaemonSet

```
kubectl apply -f k8s/pyroscope-daemonset.yaml
```

## ☕ 6. Deploy Java Demo Workload

```
kubectl apply -f k8s/java-demo-deployment.yaml
```

## 🌐 7. Access Pyroscope UI

```
./scripts/port-forward-pyroscope.sh
```

Go to: http://localhost:4040

## 🔥 8. View Flamegraphs

Pyroscope will automatically show:

- CPU Flamegraph  
- Time-Diff Flamegraph  
- Table View  

## 🧪 9. Optional: Add Load

```
./scripts/load-generator.sh
```

## 🛠 10. RHEL9 Compatibility Notes

- Ensure BTF available  
- SELinux considerations  
- Privileged DaemonSet requirements  

## 🧩 11. Troubleshooting

- Missing BTF  
- Missing Java symbols  
- Empty Pyroscope profiles  

## 📊 12. Comparison With Other Profiling Methods

(eBPF vs JFR vs async-profiler comparison table)

## 🏦 13. Bank Stakeholder Summary

### Benefits
- Zero instrumentation  
- Low overhead  
- Full JVM/native profiling  
- Works with hardened clusters  

### Risks
- Privileged DaemonSet approval  
- SELinux blocking  
- Kernel mismatches  

## 🎯 14. Summary

A full eBPF-based continuous profiling POC that models production banking environments.

