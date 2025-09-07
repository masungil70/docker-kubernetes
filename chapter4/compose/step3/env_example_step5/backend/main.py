import os
import mysql.connector
from fastapi import FastAPI, HTTPException
from time import sleep

app = FastAPI()

# APP_MODE 환경 변수를 읽어 현재 실행 모드를 결정합니다. 기본값은 'development'입니다.
APP_MODE = os.getenv("APP_MODE", "development")

# Docker secret 파일의 내용을 읽어오는 함수입니다.
def get_secret(secret_name):
    try:
        # Docker secret은 컨테이너의 /run/secrets/ 경로에 파일로 마운트됩니다.
        with open(f'/run/secrets/{secret_name}', 'r') as secret_file:
            return secret_file.read().strip() # 파일 내용에서 앞뒤 공백을 제거하고 반환합니다.
    except IOError:
        # 파일을 찾지 못하거나 읽지 못할 경우 None을 반환합니다.
        return None

def get_db_connection():
    db_password = None
    # 현재 실행 모드에 따라 비밀번호를 가져오는 방식을 다르게 합니다.
    if APP_MODE == 'production':
        print("프로덕션 모드로 실행 중입니다. Secret에서 비밀번호를 읽습니다.")
        db_password = get_secret('db_password')
    else:
        print("개발 모드로 실행 중입니다. 환경 변수에서 비밀번호를 읽습니다.")
        db_password = os.getenv('DB_PASSWORD')

    if not db_password:
        print("DB_PASSWORD를 찾을 수 없습니다.")
        return None

    # 데이터베이스 연결을 최대 5번 재시도합니다.
    retries = 5
    while retries > 0:
        try:
            conn = mysql.connector.connect(
                host=os.getenv("DB_HOST"),
                user=os.getenv("DB_USER"),
                password=db_password,
                database=os.getenv("DB_NAME")
            )
            print("데이터베이스 연결에 성공했습니다!")
            return conn
        except mysql.connector.Error as err:
            print(f"데이터베이스 연결 실패: {err}")
            retries -= 1
            sleep(5) # 5초 대기 후 재시도
    return None

@app.get("/")
def read_root():
    # 현재 설정된 환경 변수들을 확인하기 위한 엔드포인트입니다.
    return {
        "message": "FastAPI 애플리케이션이 실행 중입니다!",
        "app_mode": APP_MODE,
        "db_host": os.getenv("DB_HOST"),
        "db_name": os.getenv("DB_NAME"),
        "db_user": os.getenv("DB_USER")
    }

@app.get("/db_check")
def db_check():
    # 데이터베이스 연결 상태를 확인하는 엔드포인트입니다.
    conn = get_db_connection()
    if conn:
        conn.close()
        return {"status": f"{APP_MODE} 모드에서 데이터베이스 연결에 성공했습니다."}
    else:
        raise HTTPException(status_code=500, detail="데이터베이스 연결에 실패했습니다.")