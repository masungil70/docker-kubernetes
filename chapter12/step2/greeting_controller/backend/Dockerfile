FROM python:3.9-slim

WORKDIR /app

COPY greeting_controller.py .

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080

CMD ["python", "-m", "kopf", "run", "/app/greeting_controller.py", "--verbose"]