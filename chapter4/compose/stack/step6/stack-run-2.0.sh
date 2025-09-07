#!/bin/bash
# 스택 배포
docker stack deploy -c docker-compose-rolling-update.yml myappstack
