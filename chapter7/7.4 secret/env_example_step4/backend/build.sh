docker build -t masungil/env_backend:latest .
docker login -u masungil -p $DOCKER_PASSWORD
docker push masungil/env_backend:latest