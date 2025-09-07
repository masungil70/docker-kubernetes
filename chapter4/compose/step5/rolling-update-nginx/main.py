from fastapi import FastAPI
import os
import socket

app = FastAPI()

# 환경 변수에서 버전 정보를 가져오고, 없으면 'v1.0'을 기본값으로 사용합니다.
version = os.environ.get('APP_VERSION', 'v1.0')

@app.get("/")
def read_root():
    # 현재 호스트의 이름을 가져옵니다.
    hostname = socket.gethostname()
    
    # Docker 컨테이너는 HOSTNAME 환경 변수에 컨테이너 ID를 설정합니다.
    # 이 값을 우선 사용하고, 없으면 일반 호스트 이름을 사용합니다.
    container_id = os.getenv("HOSTNAME", hostname)    
    return {
        "message": f"Hello from version: {version}",
        "container_id": container_id,
        "hostname": hostname
    }

# /health 엔드포인트는 healthcheck를 위해 200 OK를 반환합니다.
@app.get("/healthz")
def healthz():
    return {"status": "OK"}