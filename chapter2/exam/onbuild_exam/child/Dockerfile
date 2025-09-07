# 1. 우리가 만든 빌더 이미지를 FROM으로 지정
FROM my-python-builder
  
# 2. 애플리케이션 실행 명령어만 지정
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]

