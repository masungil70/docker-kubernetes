import os
from fastapi import FastAPI, Response

# 애플리케이션 시작 시 환경 변수 'ECHO_TEXT'를 읽어옵니다.
# 환경 변수가 설정되지 않은 경우, 기본 메시지를 사용합니다.
echo_text = os.environ.get("ECHO_TEXT", "ECHO_TEXT environment variable is not set.")

app = FastAPI()

@app.get("/")
def read_root():
    """
    루트 경로로 GET 요청이 오면, 시작 시점에 저장된 echo_text를
    일반 텍스트(plain text)로 응답합니다.
    """
    return Response(content=f"{echo_text}\n", media_type="text/plain; charset=utf-8")

@app.get("/healthz")
def healthz_check():
    """
    서비스 상태를 확인하기 위한 헬스 체크 엔드포인트입니다.
    """
    return {"status": "ok"}
