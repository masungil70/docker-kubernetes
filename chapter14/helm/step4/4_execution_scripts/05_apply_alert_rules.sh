#!/bin/bash

# PrometheusRule을 monitoring 네임스페이스에 배포합니다.
# 중요: kube-prometheus-stack이 monitoring 네임스페이스에 설치되어 있어야 합니다.

echo "Applying PrometheusRule for high CPU usage..."
kubectl apply -f ../2_kubernetes_manifests/alert-rules.yaml -n monitoring

echo "\nPrometheusRule 'calculator-alert-rules' created in 'monitoring' namespace."
