from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
import uvicorn

app = FastAPI()

# FastAPI 앱을 위한 프로메테우스 계측기 설정
Instrumentator().instrument(app).expose(app)

@app.get("/add")
def add(a: float, b: float):
    return {"result": a + b}

@app.get("/sub")
def sub(a: float, b: float):
    return {"result": a - b}

@app.get("/mul")
def mul(a: float, b: float):
    return {"result": a * b}

@app.get("/div")
def div(a: float, b: float):
    if b == 0:
        return {"error": "Division by zero"}
    return {"result": a / b}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
