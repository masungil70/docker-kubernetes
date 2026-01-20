#!/bin/bash

# 이 스크립트는 쿠버네티스 노드를 관리하는 명령어 예시를 포함합니다.
# 실제 환경에서는 이 명령어를 직접 실행하기보다 클라우드 제공자의 관리 콘솔이나
# Terraform, Ansible 같은 자동화 도구를 사용하는 것이 더 안전하고 일반적입니다.

NODE_TO_MANAGE="k8s-worker-node-3" # 예시 노드 이름

echo "### Node Management Command Examples ###"

# --- 노드 스케줄링 중단 (Cordon) ---
# 더 이상 새로운 파드가 이 노드에 할당되지 않도록 합니다.
echo "\n# To cordon a node (prevent new pods from scheduling):"
echo "# kubectl cordon ${NODE_TO_MANAGE}"

# --- 노드에서 파드 비우기 (Drain) ---
# 노드의 모든 파드를 다른 노드로 안전하게 이동시킵니다.
echo "\n# To drain a node (safely evict all pods):"
echo "# kubectl drain ${NODE_TO_MANAGE} --ignore-daemonsets"

# --- 노드 삭제 ---
# 클러스터에서 노드를 제거합니다. (온프레미스 환경)
# 클라우드 환경에서는 노드 그룹의 크기를 줄여야 합니다.
echo "\n# To delete a node from the cluster (after draining):"
echo "# kubectl delete node ${NODE_TO_MANAGE}"

# --- 클라우드 제공자 CLI 예시 (참고용) ---
echo "\n# --- Cloud Provider Examples (for reference) ---"
echo "# GKE: gcloud container clusters resize my-cluster --node-pool=my-pool --num-nodes=5"
echo "# EKS: eksctl scale nodegroup --cluster=my-cluster --name=my-nodegroup --nodes=5"
echo "# AKS: az aks scale --resource-group my-rg --name my-cluster --node-count 5"
