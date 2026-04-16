#!/bin/bash

set -e

### 변수 설정
HUB_SERVER="hub.kosa.kr"
CERTS_PATH="/home/kosa/certs"

### 1 사설 인증서를 인증서 목록에 복사하고 인증서를 업데이트 한다 
sudo scp kosa@${HUB_SERVER}:${CERTS_PATH}/ca.crt /usr/local/share/ca-certificates/hub_ca.crt
sudo update-ca-certificates
 
### 2 docker 서비스를 재실행한다 
sudo service docker restart 

