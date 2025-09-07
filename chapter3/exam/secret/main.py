# main_secret.py
from fastapi import FastAPI, Request
import os
import socket

app = FastAPI(title="FastAPI Whoami with Secret")

# Secret 파일을 읽는 함수
def get_secret(secret_name):
    try:
        with open(f"/run/secrets/{secret_name}", "r") as secret_file:
            return secret_file.read().strip()
    except FileNotFoundError:
        return f"Secret '{secret_name}' not found or not mounted."
    except Exception as e:
        return f"Error reading secret '{secret_name}': {e}"

@app.get("/")
async def read_root(request: Request):
    hostname = socket.gethostname()
    container_id = os.getenv("HOSTNAME", hostname)

    db_password = get_secret("my_db_password") # Secret 읽기

    return {
        "hostname": container_id,
        "ip_address": request.client.host,
        "headers": dict(request.headers),
        "method": request.method,
        "path": request.url.path,
        "query_params": dict(request.query_params),
        "message": f"Hello from {container_id}!",
        "db_password_from_secret": db_password # Secret 값 포함
    }

@app.get("/health")
async def health_check():
    return {"status": "ok"}
