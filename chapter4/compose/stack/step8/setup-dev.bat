@echo off
setlocal

echo.
echo =================================================================
echo              개발용 Docker Swarm 환경 설정 스크립트
echo =================================================================
echo.
echo 이 스크립트는 개발 환경에 최적화된 스택을 배포합니다.
echo - 소스 코드 실시간 동기화
echo - 8080 포트로 서비스
echo.

rem --- 1. Docker Swarm 모드 확인 ---
docker info --format "{{.Swarm.LocalNodeState}}" | findstr "active" > nul
if %errorlevel% neq 0 (
    echo [오류] Docker가 Swarm 모드로 실행되고 있지 않습니다.
    echo 'docker swarm init' 명령어를 사용하여 먼저 Swarm을 활성화하세요.
    goto:eof
)
echo [1/4] Docker Swarm 모드가 활성화되어 있습니다.

rem --- 2. Docker Secret 생성 (기존에 없다면) ---
echo.
echo [2/4] 데이터베이스 비밀번호용 Secret을 확인 및 생성합니다.
docker secret inspect db_root_password > nul 2>&1
if %errorlevel% neq 0 (
    echo  - Secret이 없으므로 새로 생성합니다.
    set /p DB_ROOT_PASSWORD="   - DB Root 비밀번호를 입력하세요: "
    set /p DB_PASSWORD="   - DB User 비밀번호를 입력하세요: "
    echo %DB_ROOT_PASSWORD% | docker secret create db_root_password - > nul
    echo %DB_PASSWORD% | docker secret create db_password - > nul
    echo      -> 'db_root_password'와 'db_password' Secret을 생성했습니다.
) else (
    echo  - 기존 Secret('db_root_password', 'db_password')을 사용합니다.
)

rem --- 3. Backend 이미지 빌드 확인 ---
for /f "tokens=2 delims==" %%a in ('findstr BACKEND_IMAGE_DEV .env') do set BACKEND_IMAGE_DEV=%%a
echo.
echo [3/4] Backend 이미지 준비 확인
echo.
echo ============================ 중요 ============================
echo.
echo   개발용 백엔드 이미지('%BACKEND_IMAGE_DEV%')를
echo   로컬에 빌드했는지 확인하세요. (Push는 필요 없습니다)
echo.
echo   예시 명령어:
echo   cd backend
echo   docker build -t my-backend:dev .
echo.
echo ==============================================================
pause

rem --- 4. 개발용 애플리케이션 스택 배포 ---
echo.
echo [4/4] 개발용 애플리케이션 스택을 배포합니다...
docker stack deploy -c docker-stack.dev.yml dev_stack
echo      -> 'dev_stack' 배포를 시작했습니다.

echo.
echo =================================================================
echo                개발 환경 설정이 완료되었습니다!
echo =================================================================
echo.
echo - 배포 상태 확인:
echo   docker stack ps dev_stack
echo.
echo - 개발용 애플리케이션 접속:
echo   웹 브라우저에서 http://localhost:8080 주소로 접속하세요.
echo.

endlocal
