from fastapi import FastAPI
import os

app = FastAPI()

# 환경 변수에서 버전 정보를 가져오고, 없으면 'v1.0'을 기본값으로 사용합니다.
version = os.environ.get('APP_VERSION', 'v1.0')

@app.get("/")
def read_root():
    return {"message": f"Hello from version: {version}"}

# /health 엔드포인트는 healthcheck를 위해 200 OK를 반환합니다.
@app.get("/healthz")
def healthz():
    return {"status": "OK"}