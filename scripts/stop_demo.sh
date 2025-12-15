#!/usr/bin/env bash
set -e

### -------------------------------
### Config
### -------------------------------
NAMESPACE="observability-demo"
USE_KIND=true                # change to false if using minikube
AUTO_PORT_FORWARD=true

ROOT_DIR="$(dirname "$0")/.."

echo "=== Stopping Observability Demo ==="


### -------------------------------------------------
### Ensure Kubernetes cluster is running and context is set
### -------------------------------------------------

# Does a kind cluster named observability-demo exist?
if kind get clusters | grep -q "observability-demo"; then
    kind delete cluster --name observability-demo
fi

echo "✓ Cluster stopped"

