from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}

@app.get("/health")
def health_check():
    """
    Docker HEALTHCHECK를 위한 간단한 엔드포인트.
    성공적으로 응답하면 'ok' 상태를 반환합니다.
    """
    return {"status": "ok"}
