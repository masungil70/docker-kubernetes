# Dockerfile.cmd: CMD만 사용하는 경우
FROM alpine
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh

# 기본 실행 명령어로 app.sh를 지정하고 기본 파라미터로 "default-cmd-arg"를 전달
CMD ["./app.sh", "default-cmd-arg"]
