from fastapi import FastAPI
from redis import Redis
import socket

app = FastAPI()
# 접속 호스트를 서비스 이름 대신 별명(alias)으로 변경
redis = Redis(host='redis-db', port=6379)

@app.get("/")
def read_root():
    count = redis.incr('hits')
    hostname = socket.gethostname()
    return {
        "message": f"이 페이지는 {count}번 방문되었습니다.",
        "hostname": hostname
    }

