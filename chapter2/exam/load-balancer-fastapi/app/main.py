
from fastapi import FastAPI
import socket

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "message": "Hello from FastAPI",
        "host": socket.gethostname()
    }
