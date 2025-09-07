#!/bin/bash

# calculator-app.yaml에 정의된 Deployment, Service, Ingress를 배포합니다.
# 중요: 배포하기 전에 calculator-app.yaml 파일의 image 경로를 자신의 이미지 경로로 수정해야 합니다.

echo "Deploying Calculator App (Deployment, Service, Ingress)..."
kubectl apply -f ../2_kubernetes_manifests/calculator-app.yaml

echo "\nDeployment status:"
kubectl get deployment calculator-deployment

echo "\nService status:"
kubectl get service calculator-service

echo "\nIngress status:"
kubectl get ingress calculator-ingress
