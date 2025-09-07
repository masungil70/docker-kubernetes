# 1. 기본 이미지 선택
# Ubuntu 24.04를 기반으로 이미지를 생성합니다.
FROM ubuntu:24.04
  # 2. 패키지 목록 업데이트 및 stress 설치
# RUN 명령어는 셸 명령을 실행합니다.
# apt-get update: 패키지 목록을 최신 상태로 업데이트합니다.
# apt-get install -y stress: 'stress' 패키지를 설치합니다. '-y' 옵션은 모든 프롬프트에 자동으로 'yes'를 입력합니다.
# && apt-get clean: 설치 후 불필요한 파일을 정리하여 이미지 크기를 줄입니다.
RUN apt-get update &&     apt-get install -y stress &&     apt-get clean
