#!/bin/bash
# 서버 URL 테스트 실행
for i in {1..1000}
do
  printf "Test $i 시작\n"
  curl localhost
  printf "\nTest $i 종료\n"
  sleep 1
done
