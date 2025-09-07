#!/bin/bash

HELM_RELEASE_NAME="prometheus" # 설치할 릴리즈 이름
NAMESPACE="monitoring"         # 설치할 네임스페이스
VALUES_FILE="custom-values.initial.yaml" # 사용할 values 파일

echo "Installing kube-prometheus-stack Helm chart..."

helm install ${HELM_RELEASE_NAME} prometheus-community/kube-prometheus-stack \
  -n ${NAMESPACE} \
  --create-namespace \
  -f ${VALUES_FILE}

if [ $? -eq 0 ]; then
    echo "\nHelm installation command sent. It may take a few minutes for all pods to be running."
    echo "Check status with: kubectl get pods -n ${NAMESPACE}"
    echo "Access Grafana UI (if ClusterIP) with: kubectl port-forward -n ${NAMESPACE} svc/${HELM_RELEASE_NAME}-grafana 3000:80"
else
    echo "\nHelm installation failed! Please check the error messages above."
fi
