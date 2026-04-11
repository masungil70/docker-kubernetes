#!/bin/bash

set -e

### 변수 설정
API_SERVER="api.kosa.kr"
HUB_SERVER="hub.kosa.kr"
## # 현재 실해되는 서버의 아이피를 자동으로 추출하여 IP변수 대입한다 
API_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
CERTS_PATH="/home/kosa/certs"

### 1. 디렉토리 생성
mkdir ${CERTS_PATH}

### 2. 인증서 생성 (Self-Signed)
### 2.1 개인키 생성 
openssl genrsa -out ${CERTS_PATH}/ca.key 2048

### 2.2 인증서 생성 - 한번에 입력
openssl req -x509 -new -key ${CERTS_PATH}/ca.key \
-subj "/C=KR/ST=Seoul/L=Gangnam-gu/O=MyCompany/OU=Development Team/CN=${API_SERVER}/emailAddress=admin@example.com" \
-out ${CERTS_PATH}/ca.crt \
-days 10000

### 2.3 nginx에서 사용할 도메인 개인 키 생성 
openssl genrsa -out ${CERTS_PATH}/domain.key 2048

### 2.4 SSL/TLS 인증서를 발급받기 위한 중간 단계인 인증서 서명 요청(CSR, Certificate Signing Request) 파일을 생성 방법  
openssl req -new -key ${CERTS_PATH}/domain.key -subj /CN=${API_SERVER} -out ${CERTS_PATH}/domain.csr

### 2.5 인증서에 포함될 X.509 v3 확장(extensions) 정보
cat <<EOF > extfile.cnf
[v3_req]
subjectAltName = @alt_names

[dn]
CN = ${API_SERVER}

[alt_names]
DNS.1 = ${API_SERVER}
IP.1 = ${API_IP}
EOF

### 3.6 사설 인증 기관(Private CA)의 역할을 수행하여, 접수된 인증서 서명 요청(CSR)에 서명하고 최종 SSL/TLS 인증서를 발급하는 명령어
openssl x509 -req -in ${CERTS_PATH}/domain.csr -CA ${CERTS_PATH}/ca.crt -CAkey ${CERTS_PATH}/ca.key -CAcreateserial -out ${CERTS_PATH}/domain.crt -days 10000 -extfile extfile.cnf  -extensions v3_req

### 3.7 사설 인증서를 인증서 목록에 복사하고 인증서를 업데이트 한다 
sudo cp ${CERTS_PATH}/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
 
### 3.8 docker 서비스를 재실행한다 
sudo service docker restart 

