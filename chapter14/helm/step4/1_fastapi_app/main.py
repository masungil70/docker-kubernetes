from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
import uvicorn
import math

# 프로메테우스 미들웨어 및 메트릭 엔드포인트 추가
from starlette_prometheus import metrics, PrometheusMiddleware

app = FastAPI()

# 프로메테우스 미들웨어 추가
app.add_middleware(PrometheusMiddleware)
# /metrics 엔드포인트를 앱에 추가
app.add_route("/metrics", metrics)

# 기본 경로
@app.get("/")
def read_root():
    return {"message": "Calculator API is running"}

# 덧셈
@app.get("/add")
def add(a: float, b: float):
    return {"result": a + b}

# 뺄셈
@app.get("/subtract")
def subtract(a: float, b: float):
    return {"result": a - b}

# 곱셈
@app.get("/multiply")
def multiply(a: float, b: float):
    return {"result": a * b}

# 나눗셈
@app.get("/divide")
def divide(a: float, b: float):
    if b == 0:
        return {"error": "Division by zero is not allowed"}
    return {"result": a / b}

@app.get("/calculate")
def calculate(iterations: int = 20000, inner_iterations: int = 1000):
    """
    의도적으로 CPU 부하를 80% 이상으로 높이기 위해 복잡한 연산을 수행합니다.
    (iterations * inner_iterations) 만큼의 연산이 수행됩니다.
    """
    result = 0
    # 0으로 나누거나 로그를 취하는 것을 피하기 위해 1부터 시작합니다.
    for i in range(1, iterations + 1):
        for j in range(1, inner_iterations + 1):
            # 좀 더 복잡하고 무거운 연산 수행
            result += math.log(i) * math.sin(j) - math.sqrt(j) * math.cos(i)
    
    return {"message": f"Heavy calculation finished after {iterations}x{inner_iterations} iterations."}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)