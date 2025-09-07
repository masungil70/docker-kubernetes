#!/bin/bash
# 이미지 빌드
docker build -t masungil/fastapi-benchmark:latest .

# Docker Hub에 로그인
docker login -u masungil -p ${DOCKER_PASSWORD}

# 이미지 푸시
docker push masungil/fastapi-benchmark:latest
