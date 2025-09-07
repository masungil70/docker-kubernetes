#!/bin/bash

# 이 스크립트는 10분 동안 20초마다 FastAPI 서비스에 부하를 발생시킵니다.
# 총 30번의 요청을 보냅니다. (10분 * 60초/분 / 20초/요청 = 30번)

URL="http://localhost:8080/calculate"
ITERATIONS=300
SLEEP_INTERVAL=2 # 초

echo "Starting load test on $URL for 10 minutes..."

for i in $(seq 1 $ITERATIONS)
do
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Sending request #$i..."
    
    # -s: silent mode (진행률 숨김)
    # -o /dev/null: 응답 내용을 버려서 터미널이 지저분해지지 않도록 함
    curl -s -o /dev/null $URL
    
    # 마지막 요청 후에는 대기하지 않음
    if [ $i -lt $ITERATIONS ]; then
        sleep $SLEEP_INTERVAL
    fi
done

echo "Load test finished."
