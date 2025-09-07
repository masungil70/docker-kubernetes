# main_config.py
from fastapi import FastAPI, Request
import os
import socket
import json

app = FastAPI(title="FastAPI Whoami with Config")

# Config 파일을 읽는 함수
def get_config(config_path):
    try:
        with open(config_path, "r") as config_file:
            return json.load(config_file)
    except FileNotFoundError:
        return f"Config file '{config_path}' not found or not mounted."
    except json.JSONDecodeError as e:
        return f"Error decoding JSON from config '{config_path}': {e}"
    except Exception as e:
        return f"Error reading config '{config_path}': {e}"

@app.get("/")
async def read_root(request: Request):
    hostname = socket.gethostname()
    container_id = os.getenv("HOSTNAME", hostname)

    # Config 파일 읽기 (지정된 마운트 경로 사용)
    app_config = get_config("/app/config/my_app_config.json")

    return {
        "hostname": container_id,
        "ip_address": request.client.host,
        "headers": dict(request.headers),
        "method": request.method,
        "path": request.url.path,
        "query_params": dict(request.query_params),
        "message": f"Hello from {container_id}!",
        "app_configuration": app_config # Config 값 포함
    }

@app.get("/health")
async def health_check():
    return {"status": "ok"}
