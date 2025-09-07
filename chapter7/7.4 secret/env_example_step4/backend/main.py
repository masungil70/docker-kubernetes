import os
import mysql.connector
from fastapi import FastAPI, HTTPException
from time import sleep

app = FastAPI()

# Docker secret 파일의 내용을 읽어오는 함수
def get_secret(secret_name):
    try:
        # Docker secret은 컨테이너의 /run/secrets/ 경로에 파일 형태로 마운트됩니다.
        with open(f'/run/secrets/{secret_name}', 'r') as secret_file:
            return secret_file.read().strip() # 파일 내용에서 앞뒤 공백을 제거하고 반환
    except IOError:
        # 로컬 개발 등 secret이 없는 환경을 위해 환경 변수를 대체 사용하도록 할 수 있습니다.
        return os.getenv(secret_name.upper())

# 데이터베이스 연결을 시도하는 함수
def get_db_connection():
    retries = 5
    # Docker secret을 먼저 읽고, 없으면 환경 변수에서 비밀번호를 가져옵니다.
    db_password = get_secret('db_password') or os.getenv('DB_PASSWORD')

    while retries > 0:
        try:
            print("데이터베이스 연결을 시도합니다...")
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
            sleep(5)
    return None

@app.on_event("startup")
def startup_event():
    conn = get_db_connection()
    if conn is None:
        print("데이터베이스 연결을 최종적으로 실패했습니다.")
        return

    cursor = conn.cursor()
    try:
        print("테이블이 없는 경우 생성합니다...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS items (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL
            )
        """)
        conn.commit()
        print("'items' 테이블이 준비되었습니다.")
    except mysql.connector.Error as err:
        print(f"테이블 생성 실패: {err}")
    finally:
        cursor.close()
        conn.close()

@app.get("/")
def read_root():
    db_host = os.getenv("DB_HOST")
    return {"message": f"FastAPI (Docker Secrets 사용)! DB 호스트: {db_host}"}

@app.get("/db_check")
def db_check():
    conn = get_db_connection()
    if conn:
        conn.close()
        return {"status": "secret을 이용한 데이터베이스 연결 성공"}
    else:
        raise HTTPException(status_code=500, detail="데이터베이스 연결 실패")