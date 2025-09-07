ARG VERSION=1.0
FROM python:${VERSION}

#빌드시 전달되는 인자 
ARG APP_HOME=/app
WORKDIR ${APP_HOME}

#환경변수 
ENV LOG_LEVEL=info

COPY . .

RUN echo "App Home is ${APP_HOME}"
