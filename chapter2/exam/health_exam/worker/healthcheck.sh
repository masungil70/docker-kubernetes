#!/bin/sh
echo "Running health check..."
# 'sleep infinity' 문자열을 포함하는 프로세스가 실행 중인지 확인합니다.
if pgrep -f "sleep infinity"; then
  echo "Health check PASSED: Process is running."
  exit 0
else
  echo "Health check FAILED: Process is not running."
  exit 1
fi
