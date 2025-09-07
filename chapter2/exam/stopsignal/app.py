import signal
import time
import sys
import os # os 모듈 추가

# 종료 시그널을 받았을 때 실행될 함수
def graceful_shutdown(signum, frame):
    print(f"Received signal: {signal.Signals(signum).name}. Starting graceful shutdown...")
    # 여기에 실제 정리 작업(DB 연결 종료, 파일 저장 등)을 넣습니다.
    print("Cleaning up complete.")
    sys.exit(0)

# SIGINT (Ctrl+C) 시그널에 대한 핸들러 등록
signal.signal(signal.SIGINT, graceful_shutdown)

# SIGTERM 시그널에 대한 핸들러 등록
signal.signal(signal.SIGTERM, graceful_shutdown)

# os.getpid()를 사용하여 올바르게 PID를 가져옵니다.
print(f"Application started. Waiting for signals... (PID: {os.getpid()})")

# 애플리케이션이 계속 실행되도록 루프를 만듭니다.
try:
    while True:
        print("Working...")
        time.sleep(2)
except KeyboardInterrupt:
    # 이 부분은 컨테이너 환경에서 직접 호출되지 않을 수 있습니다.
    print("KeyboardInterrupt received.")

