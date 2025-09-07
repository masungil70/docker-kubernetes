# Dockerfile
# Python 3.10 slim-buster 이미지를 기본 이미지로 사용합니다.
FROM python:3.10-slim-buster

# 컨테이너 내부의 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# 현재 디렉토리의 requirements.txt 파일을 컨테이너의 /app 디렉토리로 복사합니다.
COPY requirements.txt .
# 복사된 requirements.txt에 명시된 Python 의존성 패키지들을 설치합니다.
# --no-cache-dir 옵션은 캐시 디렉토리를 사용하지 않아 이미지 크기를 줄입니다.
RUN pip install --no-cache-dir -r requirements.txt

# 현재 디렉토리의 main.py 파일을 컨테이너의 /app 디렉토리로 복사합니다.
COPY main.py .

# 컨테이너가 8000번 포트를 외부에 노출할 것임을 선언합니다.
# 이는 문서화 목적이며, 실제 포트 매핑은 'docker run -p' 또는 'docker service create --publish'에서 이루어집니다.
EXPOSE 8000

# Uvicorn을 사용하여 FastAPI 애플리케이션을 실행합니다.
# "main:app"은 main.py 파일의 app 객체를 의미합니다.
# --host 0.0.0.0은 모든 네트워크 인터페이스에서 접근 가능하게 합니다.
# --port 8000은 8000번 포트로 서비스를 제공합니다.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

