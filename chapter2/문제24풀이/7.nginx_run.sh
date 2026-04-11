#!/bin/bash

set -e

### 변수 설정
API_SERVER="api.kosa.kr"
## # 현재 실해되는 서버의 아이피를 자동으로 추출하여 IP변수 대입한다 
API_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
CERTS_PATH="/home/kosa/certs"

### nginx Reverse Proxy 파일 생성 
cat <<EOF > ${CERTS_PATH}/nginx.conf

upstream api-server {
  least_conn;
  
  server api-server:8000 max_fails=3 fail_timeout=5s;
}

server {
    listen 443 ssl;
    server_name ${API_SERVER};

    ssl_certificate /etc/nginx/conf.d/domain.crt;
    ssl_certificate_key /etc/nginx/conf.d/domain.key;

    client_max_body_size 0;
    chunked_transfer_encoding on;

    location / {
        
        proxy_pass                         http://api-server;
        proxy_set_header Host              \$http_host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        #proxy_read_timeout                 900;
        
        # 장애 대응 핵심
        proxy_next_upstream error timeout http_500 http_502 http_503 http_504;

        # 빠른 failover
        proxy_connect_timeout 2s;
        proxy_send_timeout 5s;
        proxy_read_timeout 5s;        
    }

}
EOF


### 7. nginx를 certs을 볼륨 설정 하고 myregistry 컨테이너를 네트웩에서 registry이름으로 접근할 실행한다 
docker run -d --name nginx \
  -p 443:443 \
  -v ${CERTS_PATH}:/etc/nginx/conf.d \
  --net my-net \
  nginx:1.27

