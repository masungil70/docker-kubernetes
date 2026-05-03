# ArgoCD란?

**ArgoCD**는 Kubernetes 환경에서 사용하는 대표적인 **GitOps 기반 CD(Continuous Delivery) 도구**입니다. 쉽게 말하면:

👉 *“Git에 있는 설정 그대로 Kubernetes를 자동으로 맞춰주는 도구”* 입니다.

---

## 🔷 1. ArgoCD 핵심 개념

### ✅ GitOps란?

* Git 저장소를 **단일 진실(Source of Truth)** 로 사용
* 클러스터 상태 = Git 상태와 항상 동일해야 함

👉 즉,

* Git에 YAML 수정 → 자동으로 Kubernetes 반영

---

## 🔷 2. ArgoCD의 역할

ArgoCD는 다음을 자동으로 처리합니다:

### 📌 1) 배포 자동화

* Git repo에 있는 Kubernetes YAML / Helm / Kustomize 읽음
* 클러스터에 자동 배포

### 📌 2) 상태 동기화 (Sync)

* Git 상태 vs 실제 클러스터 상태 비교
* 다르면 자동 수정

👉 예:

* 누가 kubectl로 몰래 수정 → ArgoCD가 다시 원래대로 복구

### 📌 3) Drift 감지

* “원래 상태와 다른지” 지속적으로 감시

---

## 🔷 3. 구성 요소

### 주요 컴포넌트

| 구성 요소              | 역할                |
| ---------------------- | -----------------   |
| API Server             | UI / CLI / API 제공 |
| Repository Server      | Git repo 가져오기   |
| Application Controller | 실제 상태 동기화    |
| Redis                  | 캐싱                |

---

## 🔷 4. 동작 흐름

```
1. Git에 YAML push
2. ArgoCD가 변경 감지
3. Kubernetes 적용
4. 상태 계속 모니터링
```

---

## 🔷 5. 배포 방식 예시

### Git repo 구조

```
app_exam/
├── deployment.yaml        # K8s Deployment
├── svc.yaml               # K8s Service
└── echo-hostname/
    ├── Dockerfile
    ├── build.sh
    ├── main.py
    └── requirements.txt
```

---

## 6. 전체 아키텍처 구조 (중요)

```
Git Repo (app_exam)
   ↓
ArgoCD (Git 감시)
   ↓
Kubernetes Cluster
   ↓
Deployment / Service 생성
   ↓
Pod 실행 (echo-hostname)
```

---

## 7. 1단계: Docker 이미지 빌드 준비

### 7-1. Dockerfile 확인 (echo-hostname)

예시 (FastAPI or Flask or simple Python)

```dockerfile
# Stage 1: 빌더 스테이지
FROM python:3.9-slim AS builder

# curl 및 빌드 필수 패키지 설치
# apt 캐시를 정리하여 이미지 용량을 줄입니다.
RUN apt-get update && apt-get install -y --no-install-recommends curl build-essential libc6-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 파이썬 의존성 설치 의존성을 먼저 설치하여 Docker 빌드 캐시를 활용합니다.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: 실행 스테이지
FROM python:3.9-slim

# 최종 이미지에서 헬스 체크를 위한 curl 및 필요한 런타임 라이브러리 설치
# apt 캐시를 정리하여 이미지 용량을 줄입니다.
RUN apt-get update && apt-get install -y --no-install-recommends curl libgcc1 libstdc++6 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 빌더 스테이지에서 설치된 의존성 복사
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# 애플리케이션 코드 복사


COPY . .

# 포트 노출
EXPOSE 8000

# FastAPI 애플리케이션 실행
# uvicorn을 사용하여 main.py 파일의 app 변수를 실행합니다.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

```

---

### 7-2. 이미지 빌드

```bash
cd echo-hostname

docker build -t masungil/echo-hostname:1.0 .
```

---

### 7-3. Docker Hub push

```bash
docker login

docker push masungil/echo-hostname:1.0
```

---

## 8. 2단계: Kubernetes manifest 수정

### 8-1. deployment.yaml 예시

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostname-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      name: my-webserver
      labels:
        app: webserver
    spec:
      imagePullSecrets:          #docker hub 관련 정보 추가
      - name: dockerhub-secret #docker hub 관련 정보 추가
      containers:
      - name: my-webserver
        image: masungil/echo-hostname:1.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8000

```

---

### 8-2. svc.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: echo-hostname-svc
spec:
  ports:
    - name: web-port
      port: 8080
      targetPort: 8000  #echo-hostname 컨테이너의 포트를 의미한것 이며,
  selector:
    app: webserver    #echo-hostname-pod.yaml에서 정의한 echo-hostname 컨테이너의 레이블을 의미합니다.  
                      #이 레이블을 가진 Pod로 요청을 전달합니다.
                      #echo-hostname 컨테이너가 8000번 포트로 요청을 수신합니다.
  
  type: ClusterIP     #서비스가 클러스터 내부에서만 접근 가능하도록 설정합니다.

```

---

## 9. 3단계: Kubernetes 클러스터 준비

확인:

```bash
kubectl get nodes
```

---

## 10. 4단계: ArgoCD 설치

### 10-1. namespace 생성

```bash
kubectl create namespace argocd
```

---

### 10-2. ArgoCD 설치

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

### 10-3. ArgoCD UI 접속 설정

NodePort로 변경:

```bash
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "NodePort"}}'
```

확인:

```bash
kubectl get svc -n argocd
```

---

### 10-4. 초기 비밀번호 확인

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

---

### 10-5. 접속

```
https://<NODE_IP>:<NODE_PORT>
```

```
ID : admin
PW : 10-4. 초기 비밀번호 확인
```

---

## 11. 5단계: ArgoCD Application 생성 (핵심)

### 방법 1: UI로 생성 (추천)

ArgoCD → NEW APP

### 설정

| 항목               | 값              |
| ---------------- | -------------- |
| Application Name | echo-hostname  |
| Project          | default        |
| Sync Policy      | Automatic (선택) |

---

### SOURCE

| 항목     | 값               |
| -------- | --------------   |
| Repo URL | GitHub repo 주소 |
| Path     | .                |
| Branch   | main             |

---

### DESTINATION

| 항목      | 값                                                               |
| --------- | ---------------------------------------------------------------- |
| Cluster   | [https://kubernetes.default.svc](https://kubernetes.default.svc) |
| Namespace | default                                                          |

---

## 12. argocd 프로그램 다운로드 후 설치

### 12-1. Linux (Ubuntu / Server 기준)

```bash
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
```

권한 부여:

```bash
chmod +x argocd
```

이동 (전역 사용):

```bash
sudo mv argocd /usr/local/bin/
```

확인:

```bash
argocd version
```

---

### 12-2. ArgoCD 로그인 먼저 해야 함

CLI sync 전에 반드시 로그인 필요

### 12-3. ArgoCD 서버 IP 확인

```bash
kubectl get svc -n argocd
```

예:

```
argocd-server NodePort  192.168.0.10:30443
```

---

### 12-4. 로그인

```bash
argocd login 192.168.80.165:30118 --insecure
```

---

### 12-5. 초기 비밀번호

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

---

### 12-6. 로그인 예시

```bash
Username: admin
Password: <위에서 나온 값>
```

---

### 12-7. 이제 sync 가능

```bash
argocd app sync echo-hostname
결과 : 
 argocd app sync echo-hostname
TIMESTAMP                  GROUP        KIND   NAMESPACE                  NAME    STATUS   HEALTH        HOOK  MESSAGE
2026-05-03T11:21:49+00:00            Service     default     echo-hostname-svc    Synced  Healthy
2026-05-03T11:21:49+00:00   apps  Deployment     default   hostname-deployment    Synced  Healthy
2026-05-03T11:21:50+00:00            Service     default     echo-hostname-svc    Synced  Healthy              service/echo-hostname-svc unchanged
2026-05-03T11:21:50+00:00   apps  Deployment     default   hostname-deployment    Synced  Healthy              deployment.apps/hostname-deployment unchanged

Name:               argocd/echo-hostname
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                https://192.168.80.165:30118/applications/echo-hostname
Source:
- Repo:             https://github.com/masungil70/argocd_exam
  Target:           main
  Path:             .
SyncWindow:         Sync Allowed
Sync Policy:        Automated
Sync Status:        Synced to main (f28fa07)
Health Status:      Healthy

Operation:          Sync
Sync Revision:      f28fa0747de4ebaf7efb09e047c83aad29744e44
Phase:              Succeeded
Start:              2026-05-03 11:21:49 +0000 UTC
Finished:           2026-05-03 11:21:50 +0000 UTC
Duration:           1s
Message:            successfully synced (all tasks run)

GROUP  KIND        NAMESPACE  NAME                 STATUS  HEALTH   HOOK  MESSAGE
       Service     default    echo-hostname-svc    Synced  Healthy        service/echo-hostname-svc unchanged
apps   Deployment  default    hostname-deployment  Synced  Healthy        deployment.apps/hostname-deployment unchanged

```

---

# GitHub push시 빌드 후 자동 배포 

GitHub push → Docker 이미지 자동 빌드 → Registry push → ArgoCD 자동 배포 하는 과정을 구현 합니다

---

## 0. 전체 구조

```text id="gk8x1p"
GitHub Push
   ↓
GitHub Actions (CI)
   ↓
Docker Build
   ↓
Docker Hub / GHCR Push
   ↓
Kubernetes Manifest Update (image tag 변경)
   ↓
Git Push (manifest repo)
   ↓
ArgoCD (자동 감지)
   ↓
Kubernetes 자동 배포
```

---

# 1. 가장 중요한 설계

## 🔥 반드시 “2 Repo 구조”로 해야 함


### ✔ 1) ArgoCD의 폴더 구조는 아래와 같이 구성 해야 됩니다

argocd_exam
├── echo-hostname   ← (프로그램 소스 repo)  
│    ├── Dockerfile
│    ├── build.sh
│    ├── main.py
│    └── requirements.txt
└──  app_exam-k8s   ← (ArgoCD가 보는 repo)
     ├── k8s
     │   ├── deployment.yaml
     │   └── svc.yaml
     └── argocd
        └── echo-hostname.yaml  

### ✔ 2) Manifest Repo (ArgoCD가 보는 GitOps repo)

원본 프로젝트에 있던 k8s 관련 파일 *.yaml을 app_exam-k8s 폴더를 생성하고 이동 합니다 

```
#폴더 생성
mkdir -p app_exam-k8s/k8s

#파일 이동합니다
mv deployment.yaml app_exam-k8s/k8s
mv svc.yaml app_exam-k8s/k8s

```

👉 ArgoCD는 이 repo(app_exam-k8s)만 본다

---

# 2. 전체 핵심 전략

| 단계              | 역할           |
| ----------------- | ----------     |
| GitHub Actions    | CI (빌드/푸시) |
| Docker Hub / GHCR | 이미지 저장    |
| ArgoCD            | CD (배포)      |
| Kubernetes        | 실행           |

---

# 3. Docker Hub 준비

## 로그인

```bash id="nq9x4p"
docker login
```

---

## 이미지 네이밍

```text id="3qk8lm"
masungil/echo-hostname
```

---

# 4. GitHub Actions 설정

## 📁 위치

```
.github/workflows/deploy.yml
```

---

## 🔥 전체 YAML (실무 표준)

```yaml id="c9v2a1"
name: CI-CD Pipeline

permissions:
  contents: write

on:
  push:
    branches:
      - main

env:
  IMAGE_NAME: masungil/echo-hostname

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Login to DockerHub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build Docker image
      run: |
        docker build -t $IMAGE_NAME:${{ github.sha }} echo-hostname/.

    - name: Push Docker image
      run: |
        docker push $IMAGE_NAME:${{ github.sha }}
```

---

# 5. GitHub Secrets 설정 (필수)

GitHub → Settings → Secrets

```
DOCKER_USERNAME = your docker id
DOCKER_PASSWORD = your password
```

---

# 6. Kubernetes manifest 자동 업데이트 (중요)

---

## 방법 sed 방식

추가 step:

.github/workflows/deploy.yml 파일 하단에 아래 내용 추가

```yaml id="w1k9e3"
    - name: Update Kubernetes manifest
      run: |
        git clone https://github.com/masungil70/argocd_exam.git
        cd app_exam-k8s/k8s/

        sed -i "s|image:.*|image: $IMAGE_NAME:${{ github.sha }}|g" deployment.yaml

        git config user.name "github-actions"
        git config user.email "github-actions@github.com"

        git add .
        git commit -m "update image tag ${{ github.sha }}"
        git push https://x-access-token:${{ secrets.GH_TOKEN }}@github.com/masungil70/argocd_exam.git```

---

# 7. ArgoCD 자동 배포 조건

ArgoCD 설정:

파일 : argocd/echo-hostname.yaml

```yaml id="7n2p1q"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: echo-hostname
  namespace: argocd

spec:
  project: default

  source:
    repoURL: https://github.com/masungil70/app_exam-k8s.git
    targetRevision: main
    path: app_exam-k8s/k8s   # 여기가 중요 (deployment 위치)

  destination:
    server: https://kubernetes.default.svc
    namespace: default

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

👉 이게 있어야 자동 배포됨

---

# 8. 전체 흐름 최종 구조

```text id="x8m2kq"
1. 코드 push
2. GitHub Actions 실행
3. Docker build
4. Docker Hub push
5. manifest repo update
6. ArgoCD 감지
7. Kubernetes 자동 배포
```

---

# 9. 실제 동작 테스트 방법

## 1) 코드 수정

```python id="p1m8qz"
print("version 2")
```

---

## 2) git hub에 push 한다

## 3) 자동 발생

```text id="v9q2lp"
GitHub Actions → 실행
ArgoCD → sync
Pod → 자동 재배포
```

##  argocd 프로젝트의 상태를 확인

```bash
app get echo-hostname

결과 :

Name:               argocd/echo-hostname
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                https://192.168.80.165:30118/applications/echo-hostname
Source:
- Repo:             https://github.com/masungil70/argocd_exam
  Target:           main
  Path:             app_exam-k8s/k8s
SyncWindow:         Sync Allowed
Sync Policy:        Automated
Sync Status:        Synced to main (c796417)
Health Status:      Healthy

GROUP  KIND        NAMESPACE  NAME                 STATUS  HEALTH   HOOK  MESSAGE
       Service     default    echo-hostname-svc    Synced  Healthy        service/echo-hostname-svc created
apps   Deployment  default    hostname-deployment  Synced  Healthy        deployment.apps/hostname-deployment created

```

## 수동으로 동기화 하기

```
argocd app sync echo-hostname --prune
```