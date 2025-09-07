
# FastAPI 성능 테스트

이 디렉토리에는 FastAPI 애플리케이션의 성능을 테스트하기 위한 스크립트와 설정 파일이 포함되어 있습니다.

## 준비 사항

1.  **Python 환경**: 스크립트를 실행하기 위해 Python 3.7 이상이 필요합니다.
2.  **의존성 설치**: 테스트를 실행하기 전에 필요한 Python 패키지를 설치해야 합니다.

    ```bash
    pip install -r requirements.txt
    ```

## 실행 방법

`benchmark.py` 스크립트는 커맨드라인 인자를 통해 테스트를 설정합니다.

-   `url`: (필수) 테스트할 FastAPI 서비스의 주소입니다.
-   `-n` 또는 `--num_requests`: 보낼 총 요청의 수 (기본값: 1000)
-   `-c` 또는 `--concurrency`: 동시에 보낼 요청의 수 (기본값: 100)

### 예제

1.  **FastAPI 서비스의 외부 IP 확인**

    먼저, 배포된 FastAPI 서비스의 IP와 포트를 확인해야 합니다. `NodePort`로 서비스를 배포했다면, 노드의 IP와 서비스의 `NodePort`를 사용합니다.

    ```bash
    # 서비스 목록과 포트 확인
    kubectl get svc fastapi-api-svc
    ```

    예를 들어, 노드 IP가 `192.168.1.10`이고 `NodePort`가 `31234`라면, 테스트 URL은 `http://192.168.1.10:31234`가 됩니다.

2.  **성능 테스트 스크립트 실행**

    `benchmark` 디렉토리에서 아래 명령어를 실행합니다.

    ```bash
    # 기본 설정(요청 1000개, 동시성 100개)으로 테스트 실행
    python benchmark.py http://<FASTAPI_SERVICE_URL>

    # 요청 5000개, 동시성 200개로 테스트 실행
    python benchmark.py http://<FASTAPI_SERVICE_URL> -n 5000 -c 200
    ```

### 출력 결과

스크립트를 실행하면 쓰기(POST) 테스트와 읽기(GET) 테스트 각각에 대한 결과가 표 형태로 출력됩니다. 결과를 통해 다음 정보를 확인할 수 있습니다.

-   총 요청 수
-   성공/실패한 요청 수
-   총 소요 시간
-   초당 요청 수 (RPS, Requests Per Second)
