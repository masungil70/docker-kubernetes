# 파이썬 베이스 이미지
FROM python:3.9-slim

# 컨테이너 내의 작업 디렉터리 설정
WORKDIR /app

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY . .

# 외부에 노출할 포트 설정 및 애플리케이션 실행
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]