#!/bin/bash

echo "[COMMON] 1. 시스템 업데이트 및 필수 패키지 설치"
apt-get update && apt-get install -y apt-transport-https ca-certificates curl gpg

echo "[COMMON] 2. 스왑 비활성화"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "[COMMON] 3. 커널 모듈 로드 및 네트워크 설정"
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

echo "[COMMON] 4. 컨테이너 런타임 (containerd) 설치"
apt-get install -y containerd

echo "[COMMON] 5. containerd 설정 (systemd cgroup 드라이버 사용)"
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "[COMMON] 6. 쿠버네티스 패키지 설치 (kubelet, kubeadm, kubectl)"
# Google Cloud public signing key 추가
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Kubernetes apt repository 추가
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
KUBE_VERSION="1.30.1-1.1"
apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} kubectl=${KUBE_VERSION}
apt-mark hold kubelet kubeadm kubectl

echo "[COMMON] 모든 노드 공통 설정 완료."
echo "================================================================================================="

