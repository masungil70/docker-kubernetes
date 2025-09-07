#!/bin/bash

# 이 스크립트는 X.509 인증서를 사용하여 쿠버네티스 사용자 사용할 수 있는 키와 인증서, CA 인증서를 생성 압축파일로 묶는 과정을 자동화합니다.,
# 스크립트 실행 중 오류가 발생하면 즉시 중단됩니다.
set -e
# 스크립트가 실행되는 디렉토리 기준으로 파일을 찾도록 경로를 설정합니다.
cd "$(dirname "$0")"

# --- 변수 정의 ---
USER_NAME="dev-user"
USER_GROUP="development"
CSR_NAME="dev-user-csr"
KUBECONFIG_CONTEXT_NAME="dev-user-context"
# 현재 kubectl 컨텍스트의 클러스터 이름을 가져옵니다.
# 로컬 머신에 클러스터가 1개만 설정되어 있다는 가정 하에 동작합니다.
# 여러 클러스터가 있다면 이 부분을 수동으로 설정해야 할 수 있습니다.
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')
# 원래의 kubectl 컨텍스트를 저장해 둡니다.
ORIGINAL_CONTEXT=$(kubectl config current-context)

echo "--- [단계 1] 사용자 개인 키 생성 ---"
echo "${USER_NAME} 사용자의 2048비트 RSA 개인 키를 생성합니다. (dev-user.key)"
openssl genrsa -out ${USER_NAME}.key 2048
echo "개인 키 생성 완료."
echo

echo "--- [단계 2] 인증서 서명 요청(CSR) 생성 ---"
echo "개인 키를 사용하여 CSR을 생성합니다."
echo "CSR의 CN(Common Name)은 사용자 이름, O(Organization)는 그룹을 나타냅니다."
openssl req -new -key ${USER_NAME}.key -out ${USER_NAME}.csr -subj "/CN=${USER_NAME}"
echo "CSR 생성 완료. (dev-user.csr)"
echo

echo "--- [단계 3] 쿠버네티스 CertificateSigningRequest 오브젝트 생성 및 제출 ---"
# CSR 파일 내용을 base64로 인코딩합니다.
CSR_CONTENT=$(cat ${USER_NAME}.csr | base64 | tr -d '\n')
# 쿠버네티스에 CSR 오브젝트를 생성하기 위한 YAML 파일을 heredoc으로 만듭니다.
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  request: ${CSR_CONTENT}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
echo "쿠버네티스에 CSR 오브젝트 제출 완료."
echo

echo "--- [단계 4] CSR 승인 ---"
echo "관리자 권한으로 제출된 CSR(${CSR_NAME})을 승인합니다."
kubectl certificate approve ${CSR_NAME}
echo "CSR 승인 완료."
echo

echo "--- [단계 5] 서명된 인증서 추출 ---"
echo "승인된 CSR에서 서명된 인증서를 추출하여 ${USER_NAME}.crt 파일로 저장합니다."
# 인증서가 발급될 때까지 잠시 기다릴 수 있습니다.
sleep 2
kubectl get csr ${CSR_NAME} -o jsonpath='{.status.certificate}' | base64 --decode > ${USER_NAME}.crt
echo "인증서 추출 완료. (dev-user.crt)"
echo

echo "--- [단계 6] 생성된 파일들(key, crt, ca) 압축 파일로 생성합니다 ---"
tar -czf ${USER_NAME}-files.tar.gz ${USER_NAME}.key ${USER_NAME}.crt  /etc/kubernetes/pki/ca.crt
echo "압축 파일 생성 완료. (${USER_NAME}-files.tar.gz)" 

echo "5. 생성된 로컬 파일들(key, csr, crt) 삭제"
rm ${USER_NAME}.key ${USER_NAME}.csr ${USER_NAME}.crt
echo
echo "모든 정리 작업 완료."
