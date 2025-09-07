# 베이스 이미지
FROM python:3.9-slim

# 의존성 설치
RUN pip install Flask

# --- COPY 명령어 예제 ---
# 파이썬 애플리케이션 파일을 컨테이너로 복사합니다.
# 단순한 파일을 복사할 때 권장되는 방식입니다.
WORKDIR /app
COPY app/main.py .

# --- ADD 명령어 예제 ---
# 예제 1: 로컬 압축 파일을 추가하고 자동으로 압축을 해제합니다.
# `static.tar.gz` 파일은 `/app/static` 디렉터리에 압축이 해제될 것입니다.
ADD assets/static.tar.gz /app/static/

# 예제 2 (주석 처리됨): URL로부터 파일을 추가합니다.
# 이 줄의 주석을 해제하면, Docker는 파일을 다운로드하여 컨테이너에 저장합니다.
# ADD https://www.docker.com/favicon.ico /app/static/docker-favicon.ico

# 앱이 실행되는 포트를 노출합니다.
EXPOSE 8080

# 애플리케이션 실행 명령어
CMD ["python", "main.py"]