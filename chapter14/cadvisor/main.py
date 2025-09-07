
from fastapi import FastAPI
import math

app = FastAPI()

@app.get("/")
def read_root():
    """기본 환영 메시지를 반환합니다."""
    return {"message": "Hello, FastAPI with Nginx and cAdvisor!"}

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
