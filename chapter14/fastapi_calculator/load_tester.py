import requests
import time
import random

# 쿠버네티스 서비스의 주소
# port-forward를 통해 로컬에서 접근할 것이므로 localhost를 사용합니다.
BASE_URL = "http://localhost:8080"

ENDPOINTS = ["add", "sub", "mul", "div"]

def run_load_test():
    print("Starting load test...")
    while True:
        try:
            endpoint = random.choice(ENDPOINTS)
            a = random.randint(1, 100)
            b = random.randint(1, 100)
            
            url = f"{BASE_URL}/{endpoint}?a={a}&b={b}"
            response = requests.get(url)
            
            if response.status_code == 200:
                print(f"SUCCESS: {url} -> {response.json()}")
            else:
                print(f"ERROR: {url} -> Status {response.status_code}")

        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}")
        
        time.sleep(0.5) # 0.5초 간격으로 요청

if __name__ == "__main__":
    run_load_test()
