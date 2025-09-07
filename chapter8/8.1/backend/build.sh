docker build -t masungil/http-echo:latest .
docker login -u masungil -p $DOCKER_PASSWORD
docker push masungil/http-echo:latest