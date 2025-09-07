#!/bin/bash

# 색상 변수 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 스크립트 시작
echo -e "${GREEN}=================================================================${NC}"
echo -e "             ${GREEN}개발용 Docker Swarm 환경 설정 스크립트${NC}"
echo -e "${GREEN}=================================================================${NC}"
echo
echo "이 스크립트는 개발 환경에 최적화된 스택을 배포합니다."
echo "- 소스 코드 실시간 동기화"
echo "- 8080 포트로 서비스"
echo

# --- 1. Docker Swarm 모드 확인 ---
SWARM_STATUS=$(docker info --format "{{.Swarm.LocalNodeState}}")
if [ "$SWARM_STATUS" != "active" ]; then
    echo -e "${RED}[오류] Docker가 Swarm 모드로 실행되고 있지 않습니다.${NC}"
    echo "'docker swarm init' 명령어를 사용하여 먼저 Swarm을 활성화하세요."
    exit 1
fi
echo -e "[1/4] ${GREEN}Docker Swarm 모드가 활성화되어 있습니다.${NC}"

# --- 2. Docker Secret 생성 (기존에 없다면) ---
echo
echo "[2/4] 데이터베이스 비밀번호용 Secret을 확인 및 생성합니다."
if ! docker secret inspect db_root_password > /dev/null 2>&1; then
    echo " - Secret이 없으므로 새로 생성합니다."
    read -sp '   - DB Root 비밀번호를 입력하세요: ' DB_ROOT_PASSWORD
    echo
    read -sp '   - DB User 비밀번호를 입력하세요: ' DB_PASSWORD
    echo
    echo "$DB_ROOT_PASSWORD" | docker secret create db_root_password -
    echo "$DB_PASSWORD" | docker secret create db_password -
    echo -e "     -> ${GREEN}'db_root_password'와 'db_password' Secret을 생성했습니다.${NC}"
else
    echo -e " - ${GREEN}기존 Secret('db_root_password', 'db_password')을 사용합니다.${NC}"
fi

# --- 3. Backend 이미지 빌드 확인 ---
if [ -f .env ]; then
    export $(cat .env | sed 's/#.*//g' | xargs)
fi
BACKEND_DEV_IMAGE=${BACKEND_IMAGE_DEV:-my-backend:dev}
echo
echo "[3/4] Backend 이미지 준비 확인"
echo
echo -e "${YELLOW}============================ 중요 ============================${NC}"
echo
echo -e "  개발용 백엔드 이미지(${GREEN}${BACKEND_DEV_IMAGE}${NC})를"
echo   "로컬에 빌드했는지 확인하세요. (Push는 필요 없습니다)"
echo
echo   "DB_NAME = ${DB_NAME}"
echo   "예시 명령어:"
echo   "cd backend"
echo   "docker build -t ${BACKEND_DEV_IMAGE} ."
echo
echo -e "${YELLOW}==============================================================${NC}"
read -p "준비가 완료되었다면 Enter 키를 눌러 계속 진행하세요..."

# --- 4. 개발용 애플리케이션 스택 배포 ---
echo
echo "[4/4] 개발용 애플리케이션 스택을 배포합니다..."
docker stack deploy -c docker-stack.dev.yml dev_stack
echo -e "     -> ${GREEN}'dev_stack' 배포를 시작했습니다.${NC}"

echo
echo -e "${GREEN}=================================================================${NC}"
echo -e "               ${GREEN}개발 환경 설정이 완료되었습니다!${NC}"
echo -e "${GREEN}=================================================================${NC}"
echo
echo "- 배포 상태 확인:"
echo "  docker stack ps dev_stack"
echo
echo "- 개발용 애플리케이션 접속:"
echo -e "  웹 브라우저에서 ${YELLOW}http://localhost:8080${NC} 주소로 접속하세요."
echo
