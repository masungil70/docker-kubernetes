#!/bin/bash

set -e

#1. 우분투 시스템 패키지 업데이트
apt-get update

#2. Docker의 공식 사이트에 설치 파일 받기 
curl -fsSL https://get.docker.com -o get-docker.sh

#3. Docker 설치
sh get-docker.sh

#4. 도커 실행상태 확인
systemctl status docker

#5.sudo 권한 없이 docker 사용 하기
usermod -aG docker kosa

### 6. nginx 패키지 설치
apt update
apt install -y nginx 

