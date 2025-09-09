
# step7: MariaDB +  FastAPI 예제

이 예제는 Kubernetes 환경에서 다음과 같은 구성 요소를 사용하여 확장 가능한 웹 애플리케이션을 배포하는 방법을 보여줍니다.

- **MariaDB**: Primary-Replica 구조의 데이터베이스. 쓰기 작업은 Primary에서, 읽기 작업은 Replica에서 처리됩니다.
- **FastAPI**: 비동기 웹 프레임워크를 사용한 간단한 REST API 서버입니다.

## 아키텍처

1.  **사용자 요청**: 사용자는 FastAPI 서비스에 HTTP 요청을 보냅니다.
2.  **FastAPI**: API 서버는 요청을 받아 처리합니다.
3.  **MariaDB**: Primary는 데이터를 변경하고, 이 변경 사항은 Replica에 복제됩니다. Replica는 읽기 요청을 처리합니다.

## 배포 방법

**주의**: `api-deployment.yaml` 파일의 `image` 필드를 자신의 Docker Hub 이미지 경로로 변경해야 합니다. 로컬에서만 테스트하는 경우, Minikube와 같은 환경에서는 추가 설정이 필요할 수 있습니다.

1.  **Docker 이미지 빌드 및 푸시**

    ```bash
    # 1. step7/api 디렉토리로 이동합니다.
    cd step7/api

    # 2. Docker 이미지를 빌드합니다. <your-dockerhub-username>을 자신의 Docker Hub ID로 변경하세요.
    docker build -t <your-dockerhub-username>/fastapi-item-api:latest .

    # 3. Docker Hub에 로그인합니다.
    docker login

    # 4. 이미지를 Docker Hub에 푸시합니다.
    docker push <your-dockerhub-username>/fastapi-item-api:latest
    ```

2.  **Kubernetes 리소스 배포**

    `step7` 디렉토리에서 다음 명령어를 순서대로 실행합니다.

    ```bash
    #0. calico CNI에 대한 권한 문제 추가해야함 
    kubectl apply -f calico-admin-binding-fix.yaml

    # 1. MariaDB Secret, ConfigMap, Service, StatefulSet을 배포합니다.
    kubectl apply -f secret.yaml
    kubectl apply -f configmap.yaml
    kubectl apply -f services.yaml
    kubectl apply -f statefulset.yaml


    # 3. (중요) api-deployment.yaml 파일의 image 필드를 1단계에서 푸시한 이미지 이름으로 수정합니다.
    # 예: image: <your-dockerhub-username>/fastapi-item-api:latest

    # 4. FastAPI Deployment와 Service를 배포합니다.
    kubectl apply -f api-deployment.yaml
    kubectl apply -f api-service.yaml
    ```

3.  **배포 확인**

    ```bash
    # Pod들이 모두 Running 상태가 될 때까지 기다립니다.
    kubectl get pods -w
    ```

## API 사용 방법

1.  **FastAPI 서비스의 외부 IP 확인**

    ```bash
    kubectl get svc fastapi-api-svc
    ```

    `EXTERNAL-IP` 주소를 확인합니다. (클라우드 환경이 아닌 경우 `pending` 상태일 수 있으며, 이 경우 `NodePort` 등을 사용해야 합니다.)

2.  **아이템 등록 (POST 요청)**

    ```bash
    curl -X POST "http://<FASTAPI_EXTERNAL_IP>/items/" \
    -H "Content-Type: application/json" \
    -d '{"name": "My First Item"}'
    ```

3.  **아이템 목록 조회 (GET 요청)**

    ```bash
    curl http://<FASTAPI_EXTERNAL_IP>/items/
    ```
