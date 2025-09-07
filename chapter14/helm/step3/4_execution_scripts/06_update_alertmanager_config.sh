#!/bin/bash

# 이 스크립트는 custom-values.yaml을 사용하여
# kube-prometheus-stack의 설정을 업그레이드합니다.

# 중요: 실행하기 전에 custom-values.yaml 파일의 내용을
# 자신의 환경에 맞게 (특히 메일 발송) 수정하세요.

HELM_RELEASE_NAME="prometheus"      # helm ls -n monitoring 으로 확인
NAMESPACE="monitoring"
VALUES_FILE="custom-values.yaml"

echo "Upgrading Helm release '${HELM_RELEASE_NAME}' with new Alertmanager config..."

helm upgrade ${HELM_RELEASE_NAME} prometheus-community/kube-prometheus-stack \
  -n ${NAMESPACE} \
  -f ${VALUES_FILE}

echo "\nUpgrade command sent. It may take a few moments for the changes to apply."
echo "Check status with: kubectl get pods -n ${NAMESPACE} | grep alertmanager"
