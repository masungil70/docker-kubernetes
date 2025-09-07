# Stage 1: 빌더 스테이지
FROM python:3.9-slim AS builder

# curl 및 빌드 필수 패키지 설치
# apt 캐시를 정리하여 이미지 용량을 줄입니다.
RUN apt-get update && apt-get install -y --no-install-recommends curl build-essential libc6-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 파이썬 의존성 설치 의존성을 먼저 설치하여 Docker 빌드 캐시를 활용합니다.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: 실행 스테이지
FROM python:3.9-slim

# 최종 이미지에서 헬스 체크를 위한 curl 및 필요한 런타임 라이브러리 설치
# apt 캐시를 정리하여 이미지 용량을 줄입니다.
RUN apt-get update && apt-get install -y --no-install-recommends curl libgcc1 libstdc++6 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 빌더 스테이지에서 설치된 의존성 복사
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# 애플리케이션 코드 복사


COPY . .

# 포트 노출
EXPOSE 8000

# FastAPI 애플리케이션 실행
# uvicorn을 사용하여 main.py 파일의 app 변수를 실행합니다.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]