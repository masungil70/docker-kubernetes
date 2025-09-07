@ECHO OFF
REM JMeter CLI(non-GUI) 모드로 부하 테스트를 실행합니다.

REM --- 변수 설정 ---
REM JMETER_HOME 변수가 설정되어 있지 않다면, JMeter가 설치된 경로를 직접 지정하세요.
SET "JMETER_BIN=%JMETER_HOME%\bin"
SET "TEST_PLAN_PATH=CalculatorTest.jmx"
SET "RESULT_FILE=result.jtl"
SET "LOG_FILE=jmeter.log"

REM ------------------

IF NOT DEFINED JMETER_HOME (
    ECHO Error: JMETER_HOME environment variable is not set.
    ECHO Please set it to your JMeter installation directory.
    EXIT /B 1
)

REM 이전 결과 파일 삭제
DEL /Q "%RESULT_FILE%" "%LOG_FILE%"

ECHO Starting JMeter load test...
ECHO Test Plan: %TEST_PLAN_PATH%
ECHO Results will be saved to: %RESULT_FILE%

REM JMeter 실행
"%JMETER_BIN%\jmeter.bat" -n -t "%TEST_PLAN_PATH%" -l "%RESULT_FILE%" -j "%LOG_FILE%"

ECHO.
ECHO JMeter test finished.
ECHO You can view the results in '%RESULT_FILE%' or generate an HTML report from it.
