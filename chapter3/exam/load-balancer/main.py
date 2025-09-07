# main.py
from fastapi import FastAPI, Request
import os
import socket

# FastAPI 애플리케이션 인스턴스를 생성합니다.
app = FastAPI(title="FastAPI Whoami")

@app.get("/")
async def read_root(request: Request):
    """
    호스트 및 수신 요청에 대한 정보를 반환합니다.
    """
    
    # 현재 호스트의 이름을 가져옵니다.
    hostname = socket.gethostname()
    
    # Docker 컨테이너는 HOSTNAME 환경 변수에 컨테이너 ID를 설정합니다.
    # 이 값을 우선 사용하고, 없으면 일반 호스트 이름을 사용합니다.
    container_id = os.getenv("HOSTNAME", hostname)

    # 요청 정보를 포함하는 딕셔너리를 반환합니다.
    return {
        "hostname"    : container_id,                 # 컨테이너의 호스트명 (ID)
        "ip_address"  : request.client.host,          # 요청을 보낸 클라이언트의 IP 주소
        "headers"     : dict(request.headers),        # 모든 HTTP 헤더
        "method"      : request.method,               # HTTP 요청 메서드 (GET, POST 등)
        "path"        : request.url.path,             # 요청 경로
        "query_params": dict(request.query_params),   # 쿼리 파라미터
        "message"     : f"Hello from {container_id}!" # 환영 메시지
    }

@app.get("/health")
async def health_check():
    """
    간단한 헬스 체크 엔드포인트입니다.
    """
    return {"status": "ok"}


