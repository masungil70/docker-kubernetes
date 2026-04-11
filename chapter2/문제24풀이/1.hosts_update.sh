#!/bin/bash

set -e

### 변수 설정
API_SERVER="api.kosa.kr"
HUB_SERVER="hub.kosa.kr"
HUB_IP="192.168.80.133"
## # 현재 실해되는 서버의 아이피를 자동으로 추출하여 IP변수 대입한다 
API_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

echo ${API_IP} ${API_SERVER} >> /etc/hosts
echo ${HUB_IP} ${HUB_SERVER} >> /etc/hosts
