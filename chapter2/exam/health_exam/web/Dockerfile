# 1. 베이스 이미지 설정
FROM python:3.9-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. 애플리케이션 코드 복사
COPY . .

# 5. HEALTHCHECK 설정
# --interval: 확인 간격 (기본값: 30초)
# --timeout: 응답 대기 시간 (기본값: 30초)
# --start-period: 컨테이너 시작 후 첫 확인까지의 유예 시간 (기본값: 0초)
# --retries: 실패 시 재시도 횟수 (기본값: 3번)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# 6. 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

