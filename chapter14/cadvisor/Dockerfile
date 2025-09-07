# Python 3.9 버전을 기반으로 이미지를 생성합니다.
FROM python:3.9-slim

# 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# requirements.txt를 먼저 복사하고 라이브러리를 설치합니다.
# (코드 변경 시 라이브러리를 다시 설치하지 않도록 하여 빌드 속도를 높입니다.)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 현재 디렉토리의 모든 파일을 /app 디렉토리로 복사합니다.
COPY . .

# 8000번 포트를 외부에 노출합니다.
EXPOSE 8000

# 컨테이너가 시작될 때 uvicorn 서버를 실행합니다.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
