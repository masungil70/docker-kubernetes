# 경량 베이스 이미지 사용
FROM alpine:latest

# 작업 디렉토리 설정
WORKDIR /app

# 스크립트 파일들을 컨테이너 안으로 복사
COPY app.sh .
COPY healthcheck.sh .

# 스크립트들이 실행 가능하도록 권한 부여
RUN chmod +x app.sh healthcheck.sh

# 컨테이너 상태를 검사하는 방법 정의
# --interval=10s: 10초마다 검사
# --timeout=3s: 검사 명령이 3초 안에 응답해야 함
# --start-period=5s: 컨테이너 시작 후 5초 뒤부터 상태 검사 시작
# --retries=3: 3번 연속 실패하면 'unhealthy' 상태로 변경
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
 CMD ./healthcheck.sh

# 컨테이너가 시작될 때 실행할 기본 명령어
CMD ["./app.sh"]