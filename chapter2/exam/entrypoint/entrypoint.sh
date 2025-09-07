#!/bin/sh

echo '1. 이미지 빌드'
echo 'docker build -t entrypoint-example -f Dockerfile.entrypoint .'
docker build -t entrypoint-example -f Dockerfile.entrypoint .

echo '\n2. 기본 커맨드 실행 (Dockerfile의 ENTRYPOINT 실행)'
echo 'docker run --rm entrypoint-example'
docker run --rm entrypoint-example

echo '\n3. `docker run`에서 인자 전달 (ENTRYPOINT에 추가됨)'
echo 'docker run --rm entrypoint-example new-arg-from-cli'
docker run --rm entrypoint-example new-arg-from-cli
