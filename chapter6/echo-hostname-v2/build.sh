#!/bin/bash
# 이미지 빌드
docker build -t masungil/echo-hostname:2.0 .

# Docker Hub에 로그인
docker login -u masungil -p ${DOCKER_PASSWORD}

# 이미지 푸시
docker push masungil/echo-hostname:2.0
