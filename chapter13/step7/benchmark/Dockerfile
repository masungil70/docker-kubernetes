
# step7/benchmark/Dockerfile
# 공식 Python 런타임 이미지를 기반으로 합니다.
FROM python:3.9-slim

# bash 셸을 설치합니다. (slim 이미지에는 기본적으로 포함되지 않을 수 있음)
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# 컨테이너 내의 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# requirements.txt 파일을 /app 디렉토리로 복사합니다.
COPY requirements.txt .

# requirements.txt에 명시된 모든 Python 패키지를 설치합니다.
RUN pip install --no-cache-dir -r requirements.txt

# benchmark.py와 run_benchmark.sh 스크립트를 /app 디렉토리로 복사합니다.
COPY benchmark.py .

# 컨테이너가 시작될 때 실행될 기본 명령어를 정의합니다.
# 이렇게 하면 Docker run 명령에 전달된 모든 인자가 benchmark.py 스크립트로 전달됩니다.
ENTRYPOINT ["python", "benchmark.py"]
