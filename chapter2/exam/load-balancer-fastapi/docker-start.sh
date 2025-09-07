
#docker 브리지 네트워크 생성 
docker network create my-net

# 폴더 변경 
cd load-balancer-fastapi

# web1 실행 (alias = app)
docker run -d --rm   --name web1   --net my-net   --net-alias app   app

# web2 실행 (alias = app)
docker run -d --rm   --name web2   --net my-net   --net-alias app   app

# nginx 로드밸런서 실행
docker run -d --rm   --name lb   --net my-net   -v ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro   -p 8080:80   nginx

