
Kubernetes의 HPA(Horizontal Pod Autoscaler)는 워크로드의 수요에 따라 파드(Pod)의 복제본(replica) 수를 자동으로 조절하여 애플리케이션의 가용성과 효율성을 높이는 핵심 기능입니다. "수평적"이라는 의미는 파드의 수를 늘리거나 줄이는 방식(스케일 아웃/인)을 사용한다는 뜻입니다.

  1. HPA(Horizontal Pod Autoscaler)란?

  HPA는 쿠버네티스 클러스터 내에서 실행되는 컨트롤러(Controller) 중 하나입니다. 주기적으로 지정된 메트릭(Metric)을 모니터링하고, 이 메트릭이 설정된 임계값(Threshold)을 초과하거나 미달할 경우, 연결된 Deployment, ReplicaSet, StatefulSet 또는 ReplicationController의 파드 복제본 수를 자동으로 늘리거나 줄입니다.

  주요 목표:
   * 리소스 효율성: 사용량이 적을 때는 파드 수를 줄여 리소스를 절약하고, 사용량이 많을 때는 파드 수를 늘려 성능을 유지합니다.
   * 가용성: 트래픽 급증 시 자동으로 파드를 추가하여 서비스 중단을 방지합니다.

  2. HPA 작동 방식

   1. 메트릭 수집: HPA 컨트롤러는 주기적으로 (기본 15초마다) 메트릭 서버(Metrics Server)나 다른 메트릭 API(Custom Metrics API, External Metrics API)로부터 대상 워크로드(예: Deployment)의 메트릭 데이터를 가져옵니다.
   2. 현재 값과 목표 값 비교: 수집된 메트릭의 현재 값과 HPA 정의에 설정된 목표 값(Target Value)을 비교합니다.
   3. 필요 복제본 수 계산: 현재 메트릭 값과 목표 메트릭 값을 기반으로 필요한 파드 복제본 수를 계산합니다.
       * desiredReplicas = ceil[currentReplicas * (currentMetricValue / desiredMetricValue)]
   4. 스케일링 요청: 계산된 desiredReplicas가 현재 복제본 수와 다르면, HPA는 대상 워크로드(예: Deployment)의 replicas 필드를 업데이트하도록 API 서버에 요청합니다.
   5. 워크로드 컨트롤러 작동: Deployment 컨트롤러와 같은 워크로드 컨트롤러는 replicas 필드의 변경을 감지하고, 이에 따라 새로운 파드를 생성하거나 기존 파드를 종료하여 실제 파드 수를 조절합니다.

  3. HPA가 사용하는 메트릭 종류

  HPA는 다양한 종류의 메트릭을 사용하여 스케일링을 결정할 수 있습니다.

  가. 리소스 메트릭 (Resource Metrics)
  가장 일반적이고 기본적인 메트릭입니다.
   * CPU 사용률 (CPU Utilization): 파드의 CPU 사용률이 특정 비율(예: 50%)을 초과하면 스케일 아웃, 미달하면 스케일 인.
       * 필수 조건: 파드에 resources.requests.cpu가 반드시 설정되어 있어야 합니다. HPA는 (현재 CPU 사용량) / (CPU 요청량)으로 사용률을 계산합니다.
       * 필수 구성: 클러스터에 Metrics Server가 배포되어 있어야 합니다.
   * 메모리 사용률 (Memory Utilization): 파드의 메모리 사용률이 특정 비율을 초과하면 스케일 아웃.
       * 필수 조건: 파드에 resources.requests.memory가 반드시 설정되어 있어야 합니다.
       * 주의: 메모리 기반 스케일링은 CPU보다 복잡합니다. 메모리 사용량은 쉽게 줄어들지 않기 때문에 스케일 인이 잘 일어나지 않거나, OOM(Out Of Memory) 문제가 발생할 수 있습니다.

  나. 커스텀 메트릭 (Custom Metrics)
  애플리케이션의 특성에 맞는 메트릭을 사용합니다.
   * 예시: 초당 요청 수(RPS), 큐(Queue)의 메시지 수, 특정 API 응답 시간 등.
   * 필수 구성: Prometheus와 같은 모니터링 시스템과 함께 Custom Metrics API Adapter (예: Prometheus Adapter)가 필요합니다.
   * 유형:
       * Pods 메트릭: 파드당 평균 메트릭 값 (예: http_requests_per_second의 파드당 평균이 100을 넘으면 스케일 아웃).
       * Object 메트릭: 특정 쿠버네티스 오브젝트(예: Ingress)의 메트릭 값 (예: Ingress의 총 요청 수가 1000을 넘으면 스케일 아웃).

  다. 외부 메트릭 (External Metrics)
  쿠버네티스 클러스터 외부의 시스템에서 발생하는 메트릭을 사용합니다.
   * 예시: AWS SQS 큐의 메시지 수, Kafka 토픽의 컨슈머 랙(lag), 데이터베이스 연결 수 등.
   * 필수 구성: External Metrics API Adapter가 필요합니다. (예: KEDA는 다양한 외부 메트릭 소스를 지원하며 HPA와 연동됩니다.)

  4. HPA 설정 방법 (YAML 예시)

  가장 일반적인 CPU 사용률 기반 HPA 설정 예시입니다.

  1. Deployment 정의 (파드에 리소스 요청량 설정 필수)
```
# my-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
spec:
  replicas: 1 # 초기 파드 수
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: nginx:latest # 예시 이미지
        ports:
        - containerPort: 80
        resources:
          requests: # HPA가 CPU 사용률을 계산하기 위해 반드시 필요
            cpu: "100m" # 0.1 CPU core
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
```
  2. HPA 정의
```
# my-app-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef: # HPA가 스케일링할 대상 워크로드
    apiVersion: apps/v1
    kind: Deployment
    name: my-app-deployment
  minReplicas: 1 # 최소 파드 수
  maxReplicas: 10 # 최대 파드 수
  metrics: # 스케일링 기준이 되는 메트릭
  - type: Resource # 리소스 메트릭 (CPU, Memory)
    resource:
      name: cpu # CPU 사용률을 기준으로 함
      target:
        type: Utilization # 사용률 (requests 대비 비율)
        averageUtilization: 50 # 파드당 평균 CPU 사용률이 50%를 넘으면 스케일 아웃
  # - type: Resource # 메모리 사용률을 기준으로 할 경우 (선택 사항)
  #   resource:
  #     name: memory
  #     target:
  #       type: Utilization
  #       averageUtilization: 70 # 파드당 평균 메모리 사용률이 70%를 넘으면 스케일 아웃
  # - type: Pods # 커스텀 메트릭 (파드당 평균) 예시
  #   pods:
  #     metric:
  #       name: http_requests_per_second # 파드당 초당 HTTP 요청 수
  #     target:
  #       type: AverageValue
  #       averageValue: "100" # 파드당 평균 100 요청/초를 넘으면 스케일 아웃
  # - type: Object # 커스텀 메트릭 (특정 오브젝트) 예시
  #   object:
  #     metric:
  #       name: requests_total # Ingress의 총 요청 수
  #     describedObject:
  #       apiVersion: networking.k8s.io/v1
  #       kind: Ingress
  #       name: my-ingress
  #     target:
  #       type: Value
  #       value: "1000" # Ingress의 총 요청 수가 1000을 넘으면 스케일 아웃
```

  3. HPA 배포 및 확인
```
# 1. Metrics Server가 설치되어 있는지 확인 (설치되어 있지 않다면 설치 필요)
# kubectl get apiservice v1beta1.metrics.k8s.io -o yaml

# 1-2. Metrics Server가 설치
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 1-3. Metrics Server 설치 확인
# kubectl get pods -n kube-system | grep metrics-server

# 1-4 https 보안 문제로 실행시 오류 발생 metrics-server Deployment 아래와 같이 수정
# kubectl edit deployment metrics-server -n kube-system
# args 부분을 확인하고 아래와 같이 수정하고 저장 합니다. 잠시 후 Metrics Server 설치 확인을 다시 해봅니다 
# args:
#  - --cert-dir=/tmp
#  - --secure-port=10250
#  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
#  - --kubelet-use-node-status-port
#  - --metric-resolution=15s
#  - --kubelet-insecure-tls
#


# 2. Deployment 배포
kubectl apply -f my-app-deployment.yaml

# 3. HPA 배포
kubectl apply -f my-app-hpa.yaml

# 4. HPA 상태 확인
kubectl get hpa
# NAME           REFERENCE                     TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
# my-app-hpa     Deployment/my-app-deployment   0%/50%    1         10        1          10s

# 5. 상세 정보 확인
kubectl describe hpa my-app-hpa
```

  5. HPA 스케일링 테스트 (CPU 부하 유발)

  간단한 BusyBox 파드를 사용하여 my-app-deployment에 CPU 부하를 유발할 수 있습니다.
```
# 부하를 유발할 파드 생성 (my-app-service가 있다고 가정)
kubectl run -it --rm --restart=Never busybox --image=busybox -- /bin/sh

# 파드 내부에서 다음 명령 실행 (Ctrl+C로 종료)
# while true; do wget -q -O- http://my-app-service; done
# 또는 CPU를 많이 사용하는 작업 실행 (예: yes > /dev/null)
# while true; do dd if=/dev/zero of=/dev/null; done
```

  부하가 발생하면 kubectl get hpa를 주기적으로 확인하여 TARGETS 값이 증가하고 REPLICAS 수가 늘어나는 것을 볼 수 있습니다. 부하가 사라지면 REPLICAS 수가 다시 minReplicas로 줄어듭니다.

  6. HPA 고급 설정: 스케일링 동작 (Behavior)

  Kubernetes 1.18+ 버전부터는 HPA의 스케일링 동작을 더 세밀하게 제어할 수 있습니다.

```
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  # ... (scaleTargetRef, minReplicas, maxReplicas, metrics) ...
  behavior:
    scaleDown: # 스케일 인(Pod 감소) 동작 설정
      stabilizationWindowSeconds: 300 # 5분 동안 메트릭이 낮게 유지되어야 스케일 인 시작
      policies:
      - type: Percent # 현재 파드 수의 100%까지 감소 가능
        value: 100
        periodSeconds: 60 # 60초마다 최대 100% 감소
      - type: Pods # 1분마다 최대 5개의 파드 감소
        value: 5
        periodSeconds: 60
    scaleUp: # 스케일 아웃(Pod 증가) 동작 설정
      stabilizationWindowSeconds: 0 # 스케일 아웃은 즉시 반응 (기본값)
      policies:
      - type: Percent # 60초마다 현재 파드 수의 100%까지 증가 가능
        value: 100
        periodSeconds: 60
      - type: Pods # 60초마다 최대 4개의 파드 증가
        value: 4
        periodSeconds: 60
```

   * `stabilizationWindowSeconds`: 스케일링 결정을 내리기 전에 메트릭이 안정화될 때까지 기다리는 시간입니다. 특히 스케일 다운 시 "스래싱(Thrashing)" (파드가 빠르게 늘었다 줄었다 하는 현상)을 방지하는 데 중요합니다.
   * `policies`: 특정 기간 동안 얼마나 많은 파드를 늘리거나 줄일지 정의합니다. Pods (절대값) 또는 Percent (비율)로 지정할 수 있습니다.

  7. HPA 사용 시 고려사항 및 베스트 프랙티스

   * 리소스 요청(Requests) 설정 필수: CPU/메모리 기반 HPA를 사용하려면 파드에 resources.requests를 반드시 설정해야 합니다. 없으면 HPA가 제대로 작동하지 않습니다.
   * Metrics Server 설치: CPU/메모리 사용률 기반 HPA를 사용하려면 클러스터에 Metrics Server가 배포되어 있어야 합니다.
   * 적절한 `minReplicas` 및 `maxReplicas` 설정:
       * minReplicas: 최소한의 가용성을 보장하고, 콜드 스타트(Cold Start) 시간을 줄이기 위해 설정합니다.
       * maxReplicas: 클러스터 리소스 고갈을 방지하고, 비용을 제어하기 위해 설정합니다.
   * 메트릭 선택의 중요성:
       * CPU 사용률은 가장 흔하지만, 항상 애플리케이션의 실제 부하를 정확히 반영하지 않을 수 있습니다. (예: I/O 바운드 애플리케이션)
       * 가능하다면 애플리케이션의 핵심 비즈니스 로드(예: 초당 요청 수, 큐 길이)를 반영하는 커스텀 메트릭을 사용하는 것이 더 정확한 스케일링을 제공합니다.
   * 스케일 다운 안정화: stabilizationWindowSeconds를 사용하여 스케일 다운 시 파드가 너무 자주 생성/삭제되는 것을 방지하세요.
   * Graceful Shutdown 구현: 파드가 종료될 때 현재 처리 중인 요청을 안전하게 마무리할 수 있도록 애플리케이션에 Graceful Shutdown 로직을 구현해야 합니다. preStop 훅과 terminationGracePeriodSeconds를 활용하세요.
   * 모니터링 및 튜닝: HPA가 예상대로 작동하는지 지속적으로 모니터링하고, 메트릭 임계값과 스케일링 정책을 튜닝하여 최적의 성능을 찾아야 합니다.
   * 다른 오토스케일러와의 관계:
       * VPA (Vertical Pod Autoscaler): 파드의 리소스(CPU, Memory) 요청/제한 값을 자동으로 조절합니다. HPA와 VPA는 동시에 사용하기 어렵습니다 (서로 충돌할 수 있음).
       * Cluster Autoscaler: 클러스터의 노드 수를 자동으로 조절합니다. HPA가 파드를 더 이상 스케일 아웃할 수 없을 때 (노드 리소스 부족), Cluster Autoscaler가 새로운 노드를 추가하여 HPA가 파드를 더 생성할 수 있도록 돕습니다.

  HPA는 쿠버네티스에서 매우 강력하고 유용한 기능이지만, 애플리케이션의 특성과 클러스터 환경에 맞춰 신중하게 설정하고 모니터링하는 것이 중요합니다.
