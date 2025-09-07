#!/bin/bash

echo "[MASTER] 쿠버네티스 클러스터 초기화 (kubeadm init)"
kubeadm init --kubernetes-version=v1.30.1 --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint="master1.co.kr:6443"

echo "[MASTER] kubectl 설정"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[MASTER] 네트워크 플러그인(Flannel) 설치"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "[MASTER] 마스터 노드 설정 완료."
echo "[MASTER] 워커 노드를 클러스터에 조인시키려면 아래 join 명령어를 복사하여 워커 노드에서 실행하세요."
kubeadm token create --print-join-command

#쉘 구문 자동완성 플러그 추가 
echo  -e "\n쉘 구문 자동완성 플러그 추가 "
apt install bash-completion

#아래7 구문 쉘에서 실행 
echo  -e "\n아래 구문 쉘에서 실행 "
source <(kubectl completion bash)
source <(kubeadm completion bash)

#다음에 로그인시 실행될 수 있도록 .bashrc 맨 마지막에 아래 구문 추가함 
echo  -e "\n다음에 로그인시 실행될 수 있도록 .bashrc 맨 마지막에 아래 구문 추가함 "
echo "source <(kubectl completion bash)" >> .bashrc
echo "source <(kubeadm completion bash)" >> .bashrc

#엔진X 웹서버 설치 후 확인
echo  -e "\n엔진X 웹서버 설치 후 확인"
kubectl run webserver --image=nginx

