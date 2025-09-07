#!/bin/bash

# HPA(Horizontal Pod Autoscaler)를 배포합니다.
# 중요: HPA가 동작하려면 클러스터에 Metrics Server가 설치되어 있어야 합니다.

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

echo "Applying HPA..."
kubectl apply -f ../2_kubernetes_manifests/hpa.yaml

echo "\nWaiting for HPA to read metrics..."
sleep 15

echo "\nCurrent HPA status:"
kubectl get hpa calculator-hpa
