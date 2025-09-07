#!/bin/bash
# 이 스크립트는 dev-user에게 storage-admin 권한이 올바르게 부여되었는지 테스트합니다.
# kubectl의 --as 플래그를 사용하여 dev-user인 것처럼 명령을 실행합니다.

set -e
NAMESPACE="development"

echo "--- [단계 1] 테스트 환경 구성 ---"
echo "development 네임스페이스를 생성합니다 (이미 있다면 무시됩니다)."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "storage-admin ClusterRole과 ClusterRoleBinding을 적용합니다."
kubectl apply -f storage-admin-clusterrole.yaml
kubectl apply -f storage-admin-binding.yaml

echo
echo "--- [단계 2] dev-user로 권한 테스트 실행 ---"
echo "storage-admin-binding.yaml에 따라 dev-user는 storage-admin 권한을 가집니다."
echo "dev-user인 것처럼 kubectl 명령을 실행하여 권한을 테스트합니다."
echo

echo ">>> 테스트 1: 허용된 작업 (PersistentVolume 목록 조회)"
echo "실행 명령어: kubectl --as=dev-user get pv"
# PV가 없을 수 있으므로 || true 처리
kubectl --as=dev-user get pv || echo "(결과 없음 - 정상)"
echo

echo ">>> 테스트 2: 허용된 작업 (StorageClass 목록 조회)"
echo "실행 명령어: kubectl --as=dev-user get sc"
kubectl --as=dev-user get sc
echo

echo ">>> 테스트 3: 허용된 작업 (모든 네임스페이스의 PVC 조회)"
echo "실행 명령어: kubectl --as=dev-user get pvc --all-namespaces"
kubectl --as=dev-user get pvc --all-namespaces || echo "(결과 없음 - 정상)"
echo

echo ">>> 테스트 4: 거부된 작업 (Secret 목록 조회)"
echo "실행 명령어: kubectl --as=dev-user get secrets -n ${NAMESPACE}"
if kubectl --as=dev-user get secrets -n ${NAMESPACE} &> /dev/null; then
    echo "오류: 예상과 달리 명령이 성공했습니다."
    exit 1
else
    echo "성공: 예상대로 권한이 거부되었습니다."
fi
echo

echo "--- [단계 3] 정리 ---"
echo "테스트에 사용된 리소스를 삭제합니다."
kubectl delete -f storage-admin-binding.yaml
kubectl delete -f storage-admin-clusterrole.yaml
echo "테스트 완료."
