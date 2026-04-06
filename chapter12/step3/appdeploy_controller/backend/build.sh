docker build -t masungil/appdeploy-controller:latest .
docker login -u masungil -p $DOCKER_PASSWORD
docker push masungil/appdeploy-controller:latest