  FROM ubuntu:24.04

  # 일반 사용자 생성
  RUN useradd -m appuser

  # 작업 디렉토리 설정
  WORKDIR /app

  # 파일 생성 및 권한 설정
  RUN echo "hello" > test.html && \
      chown -R appuser:appuser /app

  # 이후 명령을 appuser 권한으로 실행
  USER appuser
