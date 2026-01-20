#!/bin/bash

# --- 변수 설정 ---
DOCKER_USERNAME="masungil" # 자신의 Docker Hub 사용자 이름으로 변경
IMAGE_NAME="fastapi-calculator"
IMAGE_TAG="v1"

# ------------------

# 1. Docker 이미지 빌드
echo "Building Docker image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
cd ../1_fastapi_app
docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} .

if [ $? -ne 0 ]; then
    echo "Docker build failed!"
    exit 1
fi

# 2. Docker Hub에 로그인 (필요 시)
docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}

# 3. Docker 이미지 푸시
echo "Pushing Docker image to Docker Hub..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}

if [ $? -eq 0 ]; then
    echo "Image successfully pushed to ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
else
    echo "Docker push failed! Make sure you are logged in."
    exit 1
fi
