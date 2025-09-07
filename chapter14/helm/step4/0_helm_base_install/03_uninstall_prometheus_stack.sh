#!/bin/bash

HELM_RELEASE_NAME="prometheus" # 설치할 릴리즈 이름
NAMESPACE="monitoring"         # 설치할 네임스페이스
VALUES_FILE="custom-values.initial.yaml" # 사용할 values 파일

echo "uninstalling kube-prometheus-stack Helm chart..."

helm uninstall ${HELM_RELEASE_NAME} -n ${NAMESPACE}

if [ $? -eq 0 ]; then
    echo "\nHelm uninstallation command sent. It may take a few minutes for all pods to be terminated."
    echo "Check status with: kubectl get pods -n ${NAMESPACE}"
    echo "Access Grafana UI (if NodePort) with: kubectl port-forward -n ${NAMESPACE} svc/${HELM_RELEASE_NAME}-grafana 3000:80"
else
    echo "\nHelm uninstallation failed! Please check the error messages above."
fi
