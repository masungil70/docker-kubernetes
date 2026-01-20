#!/bin/bash
set -e
# Install MariaDB Galera Cluster using Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install MariaDB Galera with custom values
helm install mariadb-galera bitnami/mariadb-galera -f galera-values.yaml
# mariadb-galera 설치 후 30초 대기
sleep 30

# API 서버 배포
kubectl apply -f api-deployment.yaml
# API 서비스 배포
kubectl apply -f api-service.yaml

