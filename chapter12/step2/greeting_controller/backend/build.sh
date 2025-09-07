docker build -t masungil/greeting-controller:latest .
docker login -u masungil -p $DOCKER_PASSWORD
docker push masungil/greeting-controller:latest