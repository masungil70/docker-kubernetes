# Stage 1: Builder Stage - To install python dependencies on Alpine
FROM python:3.9-alpine AS builder

# C 확장 모듈 컴파일이 필요한 경우를 대비하여 빌드 의존성 설치
RUN apk add --no-cache build-base

WORKDIR /app

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Final Stage - The actual runtime image on Alpine
FROM python:3.9-alpine

WORKDIR /app

# healthcheck를 위한 curl 설치
RUN apk add --no-cache curl

# builder 스테이지에서 설치한 패키지 복사
COPY --from=builder /root/.local /root/.local

# 애플리케이션 코드만 복사
COPY main.py .

# PATH 환경 변수에 로컬 bin 디렉토리 추가
ENV PATH=/root/.local/bin:$PATH

# 애플리케이션이 사용하는 포트 노출
EXPOSE 8000

# 애플리케이션이 정상적으로 실행 중인지 확인하는 Healthcheck
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8000/healthz || exit 1

# 애플리케이션 실행 명령어
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
