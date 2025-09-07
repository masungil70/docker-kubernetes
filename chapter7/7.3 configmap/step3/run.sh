
kubectl apply -f configmap.yaml

export checksum=$(kubectl get configmap my-app-config -o yaml | sha256sum | awk '{print $1}')

kubectl patch deployment my-app-deployment -p \
  '{"spec":{"template":{"metadata":{"annotations":{"checksum/config": "'$checksum'"}}}}}'

# 이 스크립트는 ConfigMap이 변경된 후에 실행해야 합니다.
