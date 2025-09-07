docker build -t masungil/http-echo:banana .
docker login -u masungil -p $DOCKER_PASSWORD
docker push masungil/http-echo:banana