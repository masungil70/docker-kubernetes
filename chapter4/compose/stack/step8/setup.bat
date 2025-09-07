#!/bin/bash

# 색상 변수 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 스크립트 시작
echo -e "${GREEN}=================================================================${NC}"
echo -e "          ${GREEN}현업용 Docker Swarm 환경 설정 스크립트${NC}"
echo -e "${GREEN}=================================================================${NC}"
echo
echo "이 스크립트는 다음과 같은 작업을 수행합니다:"
echo "1. Docker Swarm 모드 활성화 여부 확인"
echo "2. DB 비밀번호 입력을 받아 Docker Secret 생성"
echo "3. Nginx 설정을 Docker Config로 생성"
echo "4. 로깅(EFK) 스택 배포"
echo "5. 애플리케이션(prod) 스택 배포"
echo
echo -e "${YELLOW}주의: 스크립트 실행 전, backend 이미지를 빌드하여"
echo -e "  미리 Docker 레지스트리에 푸시해야 합니다.${NC}"
echo -e "  (.env 파일의 BACKEND_IMAGE_PROD 변수 참조)"
echo

# --- 1. Docker Swarm 모드 확인 ---
SWARM_STATUS=$(docker info --format "{{.Swarm.LocalNodeState}}")
if [ "$SWARM_STATUS" != "active" ]; then
    echo -e "${RED}[오류] Docker가 Swarm 모드로 실행되고 있지 않습니다.${NC}"
    echo "'docker swarm init' 명령어를 사용하여 먼저 Swarm을 활성화하세요."
    exit 1
fi
echo -e "[1/5] ${GREEN}Docker Swarm 모드가 활성화되어 있습니다.${NC}"

# --- 2. Docker Secret 생성 (멱등성 보장) ---
echo
echo "[2/5] 데이터베이스 비밀번호용 Secret을 재생성합니다."
# 기존 Secret이 존재할 경우 삭제하여 멱등성을 보장
if docker secret inspect db_root_password > /dev/null 2>&1; then
    echo " - 기존 'db_root_password' Secret을 삭제합니다."
    docker secret rm db_root_password
fi
if docker secret inspect db_password > /dev/null 2>&1; then
    echo " - 기존 'db_password' Secret을 삭제합니다."
    docker secret rm db_password
fi

echo " - Secret을 새로 생성합니다."
read -sp ' - DB Root 비밀번호를 입력하세요: ' DB_ROOT_PASSWORD
echo
read -sp ' - DB User 비밀번호를 입력하세요: ' DB_PASSWORD
echo
echo "$DB_ROOT_PASSWORD" | docker secret create db_root_password -
echo "$DB_PASSWORD" | docker secret create db_password -
echo -e "     -> ${GREEN}'db_root_password'와 'db_password' Secret을 생성했습니다.${NC}"

# --- 3. Docker Config 생성 (멱등성 보장) ---
echo
echo "[3/5] Nginx 설정을 Docker Config로 재생성합니다."
# 기존 Config가 존재할 경우 삭제하여 멱등성을 보장
if docker config inspect nginx_config > /dev/null 2>&1; then
    echo " - 기존 'nginx_config' Config를 삭제합니다."
    docker config rm nginx_config
fi
docker config create nginx_config nginx/nginx.conf
echo -e "     -> ${GREEN}'nginx_config' Config를 생성했습니다.${NC}"

# Fluentd 설정 파일을 Docker Config로 생성 (멱등성 보장)
if docker config inspect fluentd_config > /dev/null 2>&1; then
    echo " - 기존 'fluentd_config' Config를 삭제합니다."
    docker config rm fluentd_config
fi
docker config create fluentd_config fluentd/conf/fluent.conf
echo -e "     -> ${GREEN}'fluentd_config' Config를 생성했습니다.${NC}"

# --- 4. Backend 이미지 빌드 및 푸시 확인 ---
# .env 파일을 읽어 환경변수로 설정 (CRLF 문제 방지)
if [ -f .env ]; then
    echo " - .env 파일에서 환경 변수를 로드합니다."
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 주석이나 빈 줄은 건너뜁니다.
        if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
            continue
        fi
        export "$line"
    done < <(tr -d '\r' < .env) # Windows CRLF 이슈 해결
fi

echo
echo "[4/5] Backend 이미지 준비 확인"
echo
echo -e "${YELLOW}============================ 중요 ============================${NC}"
echo
echo -e "  .env 파일에 지정된 백엔드 이미지(${GREEN}${BACKEND_IMAGE_PROD}${NC})를"
echo   "빌드하여 Docker 레지스트리에 푸시했는지 확인하세요."
echo
echo   "예시 명령어:"
echo   "cd backend"
echo   "docker build -t ${BACKEND_IMAGE_PROD} ."
echo   "docker push ${BACKEND_IMAGE_PROD}"
echo
echo -e "${YELLOW}==============================================================${NC}"
read -p "준비가 완료되었다면 Enter 키를 눌러 계속 진행하세요..."

# Fluentd 이미지 빌드 및 푸시
#echo
#read -p "Docker 레지스트리 사용자 이름 (예: your_docker_id)을 입력하세요: " DOCKER_REGISTRY_USER
#if [ -z "$DOCKER_REGISTRY_USER" ]; then
#    echo -e "${RED}[오류] Docker 레지스트리 사용자 이름이 필요합니다. 이미지를 푸시할 수 없습니다.${NC}"
#    echo "단일 노드 환경이 아니라면 이미지를 수동으로 푸시해야 합니다." 
#    exit 1
#fi

DOCKER_REGISTRY_USER="masungil"
#FULL_IMAGE_NAME="${DOCKER_REGISTRY_USER}/fluentd-custom:latest"
#echo "[4/5] Fluentd 이미지 빌드: ${FULL_IMAGE_NAME}"
#docker build -t "${FULL_IMAGE_NAME}" ./fluentd
#echo -e "     -> ${GREEN}'${FULL_IMAGE_NAME}' 이미지 빌드 완료.${NC}"
#
#echo " - 이미지 푸시: ${FULL_IMAGE_NAME}"
#docker push "${FULL_IMAGE_NAME}"
#echo -e "     -> ${GREEN}이미지 푸시 완료.${NC}"

export DOCKER_REGISTRY_USER # Export for docker stack deploy

# --- 5. 애플리케이션 스택 배포 ---

echo
echo "[5/5] 애플리케이션(prod) 스택을 배포합니다..."
docker stack deploy -c docker-stack.yml prod_stack
echo -e "     -> ${GREEN}'prod_stack' 배포를 시작했습니다.${NC}"

echo
echo -e "${GREEN}=================================================================${NC}"
echo -e "               ${GREEN}모든 설정이 완료되었습니다!${NC}"
echo -e "${GREEN}=================================================================${NC}"
echo
echo "- 배포 상태 확인:"
echo "  docker stack ps logging"
echo "  docker stack ps prod_stack"
echo
echo "- Kibana 접속 (로그 확인):"
echo -e "  웹 브라우저에서 ${YELLOW}http://<서버_IP>:5601${NC} 주소로 접속하세요."
echo
echo "- 애플리케이션 접속:"
echo -e "  웹 브라우저에서 ${YELLOW}http://<서버_IP>${NC} 주소로 접속하세요."
echo
