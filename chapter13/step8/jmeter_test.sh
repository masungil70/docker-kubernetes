#!/bin/bash

# JMeter CLI(non-GUI) 모드로 부하 테스트를 실행합니다.

# 사전 준비:
# step8.jmx에서 HTTPSampler.path 속성의 값에 IP 주소를 확인하고 수정하세요.
# 예: https://<IP_ADDRESS>:8000/items

# --- 변수 설정 ---
# JMETER_HOME 변수가 설정되어 있지 않다면, JMeter가 설치된 경로를 직접 지정하세요.
JMETER_BIN="${JMETER_HOME}/bin"
TEST_PLAN_PATH="step8.jmx"
RESULT_FILE="step8.jtl"
LOG_FILE="step8.log"

# ------------------

if [ -z "${JMETER_HOME}" ]; then
    echo "Error: JMETER_HOME environment variable is not set."
    echo "Please set it to your JMeter installation directory."
    exit 1
fi

# 이전 결과 파일 삭제
rm -f ${RESULT_FILE} ${LOG_FILE}

echo "Starting JMeter load test..."
echo "Test Plan: ${TEST_PLAN_PATH}"
echo "Results will be saved to: ${RESULT_FILE}"

# JMeter 실행
"${JMETER_BIN}/jmeter" -n -t "${TEST_PLAN_PATH}" -l "${RESULT_FILE}" -j "${LOG_FILE}"

echo "\nJMeter test finished."
echo "You can view the results in '${RESULT_FILE}' or generate an HTML report from it."
