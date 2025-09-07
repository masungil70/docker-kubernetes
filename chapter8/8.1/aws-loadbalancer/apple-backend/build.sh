docker build -t masungil/http-echo:apple .
docker login -u masungil -p $DOCKER_PASSWORD
docker push masungil/http-echo:apple