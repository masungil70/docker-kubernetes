FROM python:3.11-slim

WORKDIR /app
COPY main.py .

RUN pip install fastapi uvicorn

ENV LOG_LEVEL=info

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8000 --log-level ${LOG_LEVEL:-info} ${DEBUG:+--reload}"]

