# main.py
from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "message": "안녕하세요. FastAPI입니다5566888654!",
        "log_level": os.getenv("LOG_LEVEL", "info"),
        "debug_mode": "enabled" if os.getenv("DEBUG") else "disabled"
    }

