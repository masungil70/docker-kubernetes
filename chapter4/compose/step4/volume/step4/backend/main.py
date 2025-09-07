import os
import mysql.connector
from fastapi import FastAPI, HTTPException
from time import sleep

app = FastAPI()

# 데이터베이스 연결을 시도하는 함수
def get_db_connection():
    # 컨테이너 시작 순서에 따라 DB가 아직 준비되지 않았을 수 있으므로, 재시도 로직을 추가합니다.
    retries = 5
    while retries > 0:
        try:
            print("데이터베이스 연결을 시도합니다...")
            # os.getenv() 함수를 사용하여 환경 변수 값을 읽어옵니다.
            conn = mysql.connector.connect(
                host=os.getenv("DB_HOST"),
                user=os.getenv("DB_USER"),
                password=os.getenv("DB_PASSWORD"),
                database=os.getenv("DB_NAME")
            )
            print("데이터베이스 연결에 성공했습니다!")
            return conn
        except mysql.connector.Error as err:
            print(f"데이터베이스 연결 실패: {err}")
            retries -= 1
            sleep(5) # 5초 대기 후 재시도
    return None

# FastAPI 애플리케이션 시작 시 실행될 이벤트
@app.on_event("startup")
def startup_event():
    conn = get_db_connection()
    if conn is None:
        print("데이터베이스 연결을 최종적으로 실패했습니다.")
        return

    cursor = conn.cursor()
    try:
        # 'items' 테이블이 없으면 생성합니다.
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
    return {"message": f"FastAPI 애플리케이션입니다! DB 호스트: {db_host}"}

@app.get("/insert_test")
def insert_test():
    conn = get_db_connection()
    if conn is None:
        print("데이터베이스 연결을 최종적으로 실패했습니다.")
        return

    cursor = conn.cursor()
    try:
        # 'items' 테이블이 없으면 생성합니다.
        print("items 테이블에 자료를 등록합니다 ...")
        for i in range(1, 4):
            cursor.execute(f"insert into items (name) values ('test_item{i}')")
        conn.commit()
    except mysql.connector.Error as err:
        print(f"테이블에 자료 등록 실패: {err}")
    finally:
        cursor.close()
        conn.close()
    return {"message": f"items 테이블에 자료를 등록했습니다."}

# 아이템 등록 API
@app.post("/items")
def insert_items(name: str):
    conn = get_db_connection()
    if conn is None:
        print("데이터베이스 연결을 최종적으로 실패했습니다.")
        # 실패 시 명확한 값을 반환하도록 수정
        return {"message": "데이터베이스 연결 실패", "generated_id": None}
    
    cursor = conn.cursor()
    inserted_id = None  # 생성된 ID를 저장할 변수
    try:
        # 1. SQL Injection 방지를 위해 파라미터화된 쿼리 방식
        query = "INSERT INTO items (name) VALUES (%s)"
        cursor.execute(query, (name,))

        # 2. 실행 직후, cursor.lastrowid 속성으로 마지막 INSERT의 ID를 가져옴
        inserted_id = cursor.lastrowid
        cursor.close()
        conn.commit()
    except mysql.connector.Error as err:
        print(f"테이블에 자료 등록 실패: {err}")
        # 에러 발생 시 롤백을 추가하는 것이 안전합니다.
        conn.rollback()
    finally:
        conn.close()

    # 3. 성공적으로 ID를 가져온 경우, 해당 ID를 포함하여 반환
    if inserted_id is not None:
        return {"message": f"items 테이블에 '{name}'을(를) 등록했습니다.", "id": inserted_id}
    else:
        return {"message": f"'{name}' 등록에 실패했습니다.", "id": None}


@app.get("/items")
def read_items():
    conn = get_db_connection()
    if conn is None:
        print("데이터베이스 연결을 최종적으로 실패했습니다.")
        return

    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM items")
        items = cursor.fetchall()
        cursor.close()
        conn.close()
        return {"items": items}
    except mysql.connector.Error as err:
        print(f"데이터 조회 실패: {err}")
        conn.rollback()
        raise HTTPException(status_code=500, detail="데이터 조회 실패")

@app.get("/db_check")
def db_check():
    conn = get_db_connection()
    if conn:
        conn.close()
        return {"status": "데이터베이스 연결 성공"}
    else:
        raise HTTPException(status_code=500, detail="데이터베이스 연결 실패")