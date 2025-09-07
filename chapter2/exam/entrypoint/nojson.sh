echo ' 1. 이미지 빌드'
echo 'docker build -t nojson-example -f Dockerfile.nojson  .'
docker build -t nojson-example -f Dockerfile.nojson .

echo '\n 2. 기본 실행 (ENTRYPOINT + CMD 조합)'
echo 'docker run --rm nojson-example'
docker run --rm nojson-example
