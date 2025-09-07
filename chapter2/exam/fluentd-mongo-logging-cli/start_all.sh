#!/bin/bash

# 스크립트 실행 중 오류 발생 시 즉시 중단
set -e

#Build the custom Fluentd image
docker build -t fluentd-mongo ./fluentd

echo "### 1. Starting MongoDB Container ###"
docker run -d  --name mongo-db  --network logging-net  -p 27017:27017  mongo:5.0

echo "### 2. Starting Fluentd Container ###"
# fluentd/log/buffer 디렉토리 생성 (버퍼 파일 저장용)
mkdir -p fluentd/log/buffer

docker run -d  --name fluentd-aggregator  --network logging-net  -p 24224:24224  -p 24224:24224/udp  -v "/home/kosa/fluentd-mongo-logging-cli/fluentd/conf:/fluentd/etc"  -v "/home/kosa/fluentd-mongo-logging-cli/fluentd/log/buffer:/fluentd/log/buffer"  fluentd-mongo

# Fluentd가 시작될 시간을 잠시 줍니다.
echo "Waiting for Fluentd to start..."
sleep 10

echo "### 3. Starting Nginx Containers (x2) ###"
# Nginx 1
docker run -d  --name nginx1  --network logging-net  -p 8081:80  --log-driver=fluentd  --log-opt fluentd-address=localhost:24224  --log-opt tag="nginx.access.{{.Name}}"  nginx

# Nginx 2
docker run -d  --name nginx2  --network logging-net  -p 8082:80  --log-driver=fluentd  --log-opt fluentd-address=localhost:24224  --log-opt tag="nginx.access.{{.Name}}"  nginx

echo "### 4. Starting MySQL Containers (x2) ###"
# MySQL 1
docker run -d  --name mysql1  --network logging-net  -e MYSQL_ROOT_PASSWORD=mysecretpassword1  --log-driver=fluentd  --log-opt fluentd-address=localhost:24224  --log-opt tag="mysql.log.{{.Name}}"  mysql:8.0

# MySQL 2
docker run -d  --name mysql2  --network logging-net  -e MYSQL_ROOT_PASSWORD=mysecretpassword2  --log-driver=fluentd  --log-opt fluentd-address=localhost:24224  --log-opt tag="mysql.log.{{.Name}}"  mysql:8.0

echo "### All containers are starting! ###"
docker ps

