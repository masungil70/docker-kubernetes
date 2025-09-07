#!/bin/sh

echo '1. 이미지 빌드'
echo 'docker build -t cmd-example -f Dockerfile.cmd .'
docker build -t cmd-example -f Dockerfile.cmd .

echo ""
echo '2. 기본 커맨드 실행 (Dockerfile의 CMD 실행)'
echo 'docker run --rm cmd-example'
docker run --rm cmd-example

echo ""
echo "3. docker run에서 커맨드 전달 (CMD가 대체됨)"
echo "docker run --rm cmd-example echo \"Hello from command line\""
docker run --rm cmd-example echo "Hello from command line"
