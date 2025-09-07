import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import mysql.connector
import random

app = FastAPI()

DB_USER = os.getenv("DB_USER", "kosa")
DB_PASSWORD = os.getenv("DB_PASSWORD", "1004")
DB_NAME = os.getenv("DB_NAME", "kosa_db")

# Use the Kubernetes service names for master and headless service for replicas
PRIMARY_HOST = "mariadb-master" # Service for mariadb-0
REPLICA_HOSTS = ["mariadb-1.mariadb-headless", "mariadb-2.mariadb-headless"] # Specific pod names via headless service
DB_PORT = 3306

def get_db_connection(read_only: bool = False):
    host = ""
    if read_only:
        host = random.choice(REPLICA_HOSTS)
    else:
        host = PRIMARY_HOST

    try:
        conn = mysql.connector.connect(
            host=host,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            port=DB_PORT
        )
        return conn
    except mysql.connector.Error as err:
        print(f"Error connecting to database {host}: {err}")
        return None

class Item(BaseModel):
    name: str

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI Item API with Read/Write Splitting"}

@app.post("/items/")
def create_item(item: Item):
    conn = get_db_connection(read_only=False)
    if conn is None:
        raise HTTPException(status_code=503, detail="Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute("INSERT INTO items (name) VALUES (%s)", (item.name,))
        conn.commit()
        return {"message": f"Item '{item.name}' created successfully."}
    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

@app.get("/items/")
def read_items():
    conn = get_db_connection(read_only=True)
    if conn is None:
        raise HTTPException(status_code=503, detail="Database connection failed")

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, name FROM items LIMIT 10")
        items = cursor.fetchall()
        return items
    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

@app.delete("/items/")
def delete_all_items():
    conn = get_db_connection(read_only=False)
    if conn is None:
        raise HTTPException(status_code=503, detail="Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute("TRUNCATE TABLE items")
        conn.commit()
        return {"message": "All items deleted successfully."}
    except mysql.connector.Error as err:
        raise HTTPException(status_code=500, detail=f"Database error: {err}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
