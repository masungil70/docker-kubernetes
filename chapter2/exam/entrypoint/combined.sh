#!/bin/sh

echo ' 1. 이미지 빌드'
echo 'docker build -t combined-example -f Dockerfile.combined .'
docker build -t combined-example -f Dockerfile.combined .

echo '\n 2. 기본 실행 (ENTRYPOINT + CMD 조합)'
echo 'docker run --rm combined-example'
docker run --rm combined-example

echo '\n 3. `docker run`에서 인자 전달 (CMD만 대체되어 ENTRYPOINT에 추가됨)'
echo 'docker run --rm combined-example another-arg'
docker run --rm combined-example another-arg

echo '\n 4. `docker run`에서 --entrypoint 옵션, 인자 전달 (entrypoint, CMD 모두 run 을 통해 전달)'
echo 'docker run --rm --entrypoint='echo'  combined-example another-arg'
docker run --rm --entrypoint='echo' combined-example another-arg
