


#정상 응답 
echo "정상 응답(200)"
curl -k https://api.kosa.kr/health

wait 1

### 장애 응답 (500)을 위해 1,2은 종료하고 3번에 장애 환경 변수 값을 설정한다 
docker stop api-1
docker stop api-2
docker stop api-3
docker rm api-3
wait 1

# 3번에 장애 환경 변수 값을 설정한다 
docker run -d \
  --name api-3 \
  --hostname api-3 \
  --net my-net \
  --net-alias api-server \
  -e FAIL_MODE=true \
  api-server:1.0

curl -k https://api.kosa.kr/health

## 2) 사용자 목록 조회 API

# api-1 ,api-2 서버 시작 
docker start api-1 api-2 

# api-3 종료하고 다시 정상 시작 할 수 있게 함 
docker rm -f api-3

docker run -d \
  --name api-3 \
  --hostname api-3 \
  --net my-net \
  --net-alias api-server \
  api-server:1.0

# 사용자 목록 조회
curl -k https://api.kosa.kr/api/users

wait 1

#사용자 단건 조회 API

curl -k https://api.kosa.kr/api/users/1


#존재하지 않을 경우 (404) 
curl -k https://api.kosa.kr/api/users/99

# 컨테이너 실행 시 환경변수 사용
#-e APP_MODE=production
#-e APP_VERSION=1.0.0
echo -e APP_MODE=production 설정 
echo -e APP_VERSION=1.0.0 설정 

#기존 api-1 api-2 api-3 모두 멈춤고 제거함 
docker stop api-1 api-2 api-3
docker rm -f api-1 api-2 api-3

# api-1 실행 (net-alias = api-server) 
docker run -d \
  --name api-1 \
  --hostname api-1 \
  --net my-net \
  --net-alias api-server \
  -e APP_MODE=production \
  -e APP_VERSION=1.0.0 \
  api-server:1.0

# api-2 실행 (net-alias = api-server) 
docker run -d \
  --name api-2 \
  --hostname api-2 \
  --net my-net \
  --net-alias api-server \
  -e APP_MODE=production \
  -e APP_VERSION=1.1.0 \
  api-server:1.0

# api-3 실행 (net-alias = api-server) 
docker run -d \
  --name api-3 \
  --hostname api-3 \
  --net my-net \
  --net-alias api-server \
  -e APP_MODE=production \
  -e APP_VERSION=1.0.2 \
api-server:1.0


curl -k https://api.kosa.kr/api/config
curl -k https://api.kosa.kr/api/config
curl -k https://api.kosa.kr/api/config


### 요청 반복

for i in {1..5}; do curl -k https://api.kosa.kr/health; done


# 종료 시그널 테스트 API
docker stop api-1 
docker logs api-1 

# hub.kosa.kr의 인증서를 현재의 서버에 복사합니다 
HUB_SERVER="hub.kosa.kr"

scp kosa@${HUB_SERVER}:~/certs/ca.crt /usr/local/share/ca-certificates/ca_hub.crt
sudo update-ca-certificates
 
### docker 서비스를 재실행한다 
sudo service docker restart 

### 로그인

docker login https://hub.kosa.kr

### Push

docker push hub.kosa.kr/api-server:1.0

### Pull

docker pull hub.kosa.kr/api-server:1.0
