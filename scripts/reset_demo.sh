#!/usr/bin/env bash
set -e

### -------------------------------
### Config
### -------------------------------
NAMESPACE="observability-demo"
USE_KIND=true                # change to false if using minikube
AUTO_PORT_FORWARD=true

ROOT_DIR="$(dirname "$0")/.."
K8S_DIR="$ROOT_DIR/k8s"
JAVA_DIR="$ROOT_DIR/java-demo"

echo "=== Resetting Observability Demo ==="


### -------------------------------------------------
### Ensure Kubernetes cluster is running and context is set
### -------------------------------------------------

# Does a kind cluster named observability-demo exist?
if kind get clusters | grep -q "observability-demo"; then
    echo "→ Kind cluster 'observability-demo' already exists"

    # Make sure kubectl context is set to it
    kubectl config use-context kind-observability-demo >/dev/null 2>&1 || {
        echo "→ Setting kube context..."
        kubectl cluster-info --context kind-observability-demo || true
    }
else
    echo "⚠ No cluster found — creating kind cluster..."
    kind create cluster --name observability-demo
fi

echo "✓ Cluster ready"



### -------------------------------------------------
### Delete existing workloads
### -------------------------------------------------
echo "→ Deleting existing demo resources..."

kubectl delete deploy/java-demo -n $NAMESPACE --ignore-not-found
kubectl delete deploy/pyroscope -n $NAMESPACE --ignore-not-found
kubectl delete svc/pyroscope -n $NAMESPACE --ignore-not-found
kubectl delete pvc --all -n $NAMESPACE --ignore-not-found
kubectl delete configmap --all -n $NAMESPACE --ignore-not-found

echo "✓ Workloads removed"


### -------------------------------------------------
### Rebuild & redeploy
### -------------------------------------------------
echo "→ Rebuilding java image..."
docker build -t java-demo:latest "$JAVA_DIR"

echo "→ Loading image into kind..."
kind load docker-image java-demo:latest --name observability-demo

echo "→ Pulling Pyroscope image (if not already present)..."
docker pull grafana/pyroscope:latest || true

echo "→ Loading Pyroscope image into kind..."
kind load docker-image grafana/pyroscope:latest --name observability-demo

echo "→ Ensuring namespace exists..."
kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create ns $NAMESPACE

echo "→ Applying manifests..."
kubectl apply -n $NAMESPACE -f "$K8S_DIR/pyroscope-server.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/java-demo-deployment.yaml"

echo "→ Waiting for pods..."
kubectl wait --for=condition=ready pod -l app=java-demo -n $NAMESPACE --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=pyroscope -n $NAMESPACE --timeout=120s || true


### -------------------------------------------------
### Port forward
### -------------------------------------------------
if $AUTO_PORT_FORWARD; then
  echo "→ Starting port-forward..."
  kubectl port-forward svc/pyroscope 4040:4040 -n $NAMESPACE
else
  echo "✓ All done."
  echo "Open Pyroscope UI using:"
  echo "kubectl port-forward svc/pyroscope 4040:4040 -n $NAMESPACE"
fi

