FROM ubuntu:24.04

#환경 변수 선언 
ENV test=/home

#작업 폴더를 변경한다
WORKDIR $test

#환경 변수에 있는 값을 기준으로 해당 폴더에 mytouchfile이 없으면 생성하고, 있으면 시간을 최신 상태로 변경한다
RUN touch $test/mytouchfile

