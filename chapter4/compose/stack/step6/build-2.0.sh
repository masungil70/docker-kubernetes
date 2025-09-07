#!/bin/bash

#이미지 2.0 빌드하여 docker hub에 push 한다

docker build -t masungil/my-fastapi-app:2.0 . --no-cache
echo "이미지 빌드 성공"

docker login -u masungil -p$DOCKER_PASSWORD
echo "로그인 성공"

docker push masungil/my-fastapi-app:2.0
echo "이미지 푸시 성공"


