#!/bin/bash

# --- 1단계: Helm 리포지토리 설정 ---

echo "[1단계] Helm 리포지토리를 추가하고 업데이트합니다..."

# Nginx 차트가 포함된 bitnami 리포지토리를 추가합니다.
helm repo add bitnami https://charts.bitnami.com/bitnami

# 추가된 리포지토리의 최신 차트 정보를 가져옵니다.
helm repo update


# --- 2단계: Nginx 설치 ---

echo "\n[2단계] 사용자 정의 설정(nginx-values.yaml)을 사용하여 Nginx를 설치합니다..."

# 'nginx-release'라는 이름으로, 'nginx' 네임스페이스에 Nginx를 설치합니다.
# '--namespace nginx'는 격리된 공간에 설치하기 위함이며, '--create-namespace'는 해당 네임스페이스가 없을 경우 자동으로 생성하는 옵션입니다.
# '-f nginx-values.yaml' 옵션으로 우리가 만든 설정 파일을 적용합니다.
# helm install nginx-release bitnami/nginx --namespace nginx --create-namespace -f nginx-values.yaml
#
# 네임스페이스 없이 기본 네임스페이스에 설치하려면 아래 명령을 사용합니다.
helm install nginx-release bitnami/nginx -f nginx-values.yaml


# --- 3단계: 설치 상태 확인 ---

echo "\n[3단계] Nginx 설치 상태와 외부 접속 정보를 확인합니다..."

# Helm 릴리즈 상태를 확인합니다. (STATUS가 'deployed'인지 확인)
# helm status nginx-release --namespace nginx
#
# 네임스페이스 없이 기본 네임스페이스에 설치했다면 아래 명령을 사용합니다.
# helm status nginx-release

# Nginx를 위해 생성된 쿠버네티스 리소스(Pod, Service 등)를 확인합니다.
# kubectl get all --namespace nginx
#
# 네임스페이스 없이 기본 네임스페이스에 설치했다면 아래 명령을
# kubectl get all 


# Nginx 서비스의 상세 정보를 확인하여 외부에서 접속할 NodePort 번호를 확인합니다.
# kubectl describe service nginx-release --namespace nginx
#
# 네임스페이스 없이 기본 네임스페이스에 설치했다면 아래 명령을 사용합니다.
kubectl describe service nginx-release 

# 또는 아래 명령으로도 서비스 클러스터IP 정보를 확인할 수 있습니다.
kubectl get svc


echo "\n[접속 방법] 위 'kubectl describe' 결과에서 'NodePort:' 항목의 포트 번호와\n       쿠버네티스 노드(서버)의 IP 주소를 사용하여 웹 브라우저에서 접속하세요.
       예: http://<노드_IP>:<NodePort_번호>"


# --- 4단계: 릴리즈 업그레이드 (예시) ---

# echo "\n[4단계] Nginx 파드 개수를 3개로 변경하여 업그레이드를 진행합니다..."
# # nginx-values.yaml 파일의 replicaCount 값을 3으로 수정한 후 아래 명령을 실행합니다.
# helm upgrade nginx-release bitnami/nginx --namespace nginx -f nginx-values.yaml


# --- 5단계: 릴리즈 삭제 (정리) ---

# echo "\n[5단계] 설치된 Nginx 릴리즈를 삭제합니다..."

# 'nginx-release' 릴리즈와 관련된 모든 리소스를 삭제합니다.
# helm uninstall nginx-release --namespace nginx
#
# 네임스페이스 없이 기본 네임스페이스에 설치했다면 아래 명령을 사용합니다.
# helm uninstall nginx-release 

# 네임스페이스까지 삭제하려면 아래 명령을 실행합니다.
# kubectl delete namespace nginx

# echo "\n스크립트의 모든 절차 안내가 끝났습니다."
