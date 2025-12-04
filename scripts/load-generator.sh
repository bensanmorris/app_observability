#!/bin/bash
while true; do
  kubectl exec deploy/java-demo -- bash -c "echo 'load'" >/dev/null 2>&1
done
