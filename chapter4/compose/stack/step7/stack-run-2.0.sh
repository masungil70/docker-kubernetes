#!/bin/bash
# 헬스체크 스택 배포 
docker stack deploy -c docker-compose-unhealthy-rollback.yml myappstack
