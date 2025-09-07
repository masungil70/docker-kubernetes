#!/bin/bash

#  1단계: Nginx Ingress Controller Helm 리포지토리 추가
# 1. Nginx Ingress Controller Helm 리포지토리 추가
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# 2. Helm 리포지토리 업데이트 (최신 차트 정보 가져오기)
helm repo update

# 2단계: Nginx Ingress Controller 설치
# helm install 명령어를 사용하여 Nginx Ingress Controller를 배포합니다. 이때, 서비스 타입을 지정하여 외부에서 접근 가능하도록 설정할 수 있습니다. 온프레미스 환경에서는 NodePort 또는 LoadBalancer (MetalLB와 같은 소프트웨어 로드밸런서가 있는 경우)를 주로 사용합니다.

# NodePort 타입으로 설치하는 예시
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.service.externalTrafficPolicy=Local

