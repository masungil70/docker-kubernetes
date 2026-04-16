# api-1 실행 (net-alias = api-server) 
docker run -d --name api-1 --hostname api-1 --net my-net --net-alias api-server api-server:0.1

# api-2 실행 (net-alias = api-server) 
docker run -d --name api-2 --hostname api-2 --net my-net --net-alias api-server api-server:0.1

# api-3 실행 (net-alias = api-server) 
docker run -d --name api-3 --hostname api-3 --net my-net --net-alias api-server api-server:0.1

