
  1. Taints(테인트)와 Tolerations(톨러레이션)란?

   * Taints (테인트): 노드에 적용되는 속성으로, 해당 노드가 특정 파드를 "밀어낸다(repel)"는 의미를 가집니다. 즉, 테인트가 있는 노드에는 특별한 허용(Toleration)이 없는 한 파드가 스케줄링되지 않습니다.
       * "이 노드는 특별한 목적을 가지고 있으니, 아무나 들어오지 마세요!"
   * Tolerations (톨러레이션): 파드에 적용되는 속성으로, 특정 테인트를 "허용한다(tolerate)"는 의미를 가집니다. 톨러레이션이 있는 파드는 해당 테인트가 있는 노드에 스케줄링될 수 있습니다.
       * "저는 이 노드의 특별한 목적을 이해하고 있으니, 저를 받아주세요!"

  핵심 개념: 노드에 테인트를 적용하고, 해당 테인트를 허용하는 톨러레이션을 파드에 추가함으로써, 특정 파드만 특정 노드에 스케줄링되도록 하거나, 특정 노드에 파드가 스케줄링되지 않도록 할 수 있습니다.

  ---

  2. Taints와 Tolerations를 사용하는 이유 (활용 사례)

   * 전용 노드 (Dedicated Nodes): 특정 팀이나 특정 애플리케이션(예: 데이터베이스, 머신러닝 워크로드)만을 위한 노드를 만들 때 사용합니다. 해당 노드에 테인트를 적용하고, 해당 파드에만 톨러레이션을 부여하여 다른 파드가 스케줄링되는 것을 방지합니다.
   * 특수 하드웨어 노드: GPU와 같은 특수 하드웨어가 장착된 노드에 해당 하드웨어를 사용하는 파드만 스케줄링되도록 합니다.
   * 문제 있는 노드 격리: 노드에 문제가 발생했을 때(예: 네트워크 문제, 디스크 오류), 해당 노드에 테인트를 적용하여 새로운 파드가 스케줄링되는 것을 막고, 기존 파드를 안전하게 다른 노드로 이동시킬 수 있습니다. (쿠버네티스 자체적으로도 노드 상태에 따라
     테인트를 추가하기도 합니다.)
   * 비용 최적화: 온디맨드 인스턴스와 스팟 인스턴스를 혼합하여 사용할 때, 스팟 인스턴스 노드에 테인트를 적용하고, 스팟 인스턴스에서 실행될 수 있는 파드에만 톨러레이션을 부여하여 비용 효율적인 스케줄링을 구현할 수 있습니다.

  ---

  3. Taints(테인트)의 작동 방식

  테인트는 key=value:effect 형식으로 구성됩니다.

   * `key`: 테인트의 이름 (예: dedicated, gpu)
   * `value`: 테인트의 값 (선택 사항, 예: team-a, nvidia)
   * `effect`: 테인트가 파드 스케줄링에 미치는 영향. 세 가지 주요 효과가 있습니다:

       * `NoSchedule`:
           * 가장 일반적인 효과.
           * 이 테인트를 허용하지 않는 파드는 해당 노드에 스케줄링되지 않습니다.
           * 이미 해당 노드에서 실행 중인 파드에는 영향을 미치지 않습니다.
           * 새로운 파드의 진입만 막습니다.
           * 예: kubectl taint nodes node1 key=value:NoSchedule

       * `PreferNoSchedule`:
           * NoSchedule보다 "부드러운" 버전입니다.
           * 이 테인트를 허용하지 않는 파드는 해당 노드에 스케줄링되는 것을 최대한 피하려고 합니다.
           * 하지만 다른 노드에 스케줄링할 공간이 없으면, 이 노드에 스케줄링될 수도 있습니다.
           * 예: kubectl taint nodes node1 key=value:PreferNoSchedule

       * `NoExecute`:
           * 가장 강력한 효과.
           * 이 테인트를 허용하지 않는 파드는 해당 노드에 스케줄링되지 않습니다.
           * 이미 해당 노드에서 실행 중인 파드 중 이 테인트를 허용하지 않는 파드는 즉시 해당 노드에서 축출(evict)됩니다.
           * 파드에 tolerationSeconds가 설정되어 있으면, 해당 시간 동안 축출을 유예할 수 있습니다.
           * 예: kubectl taint nodes node1 key=value:NoExecute

  ---

  4. Tolerations(톨러레이션)의 작동 방식

  톨러레이션은 파드 정의의 spec.tolerations 필드에 배열 형태로 정의됩니다.
```
   1 tolerations:
   2 - key: "key"
   3   operator: "Equal" # 또는 "Exists"
   4   value: "value"    # operator가 "Exists"일 경우 생략 가능
   5   effect: "NoSchedule" # 또는 "NoExecute", "PreferNoSchedule"
   6   tolerationSeconds: 3600 # effect가 NoExecute일 경우, 축출 유예 시간 (초)
```
   * `key`: 허용할 테인트의 키.
   * `operator`:
       * `Equal`: key와 value가 정확히 일치하는 테인트를 허용합니다. (기본값)
       * `Exists`: key가 일치하고 value는 어떤 값이든 상관없는 테인트를 허용합니다. 이 경우 value 필드는 생략해야 합니다.
   * `value`: operator가 Equal일 때, 허용할 테인트의 값.
   * `effect`: 허용할 테인트의 효과. 테인트의 effect와 정확히 일치해야 합니다. 이 필드를 생략하면 해당 키를 가진 모든 효과의 테인트를 허용합니다.
   * `tolerationSeconds`: effect가 NoExecute인 테인트에만 적용됩니다. 파드가 해당 테인트를 가진 노드에서 축출되기 전까지 얼마나 오래 머무를 수 있는지 초 단위로 지정합니다. 이 필드가 없으면 즉시 축출됩니다.

  예시:

   * key: "dedicated", operator: "Exists": dedicated 키를 가진 모든 테인트를 허용합니다.
   * key: "gpu", operator: "Equal", value: "nvidia", effect: "NoSchedule": gpu=nvidia:NoSchedule 테인트를 허용합니다.

  ---

  5. Taints 관리하기 (kubectl 명령어)

  5.1. 노드에 테인트 추가하기
```
   kubectl taint nodes <노드-이름> <키>=<값>:<효과>
```
  예시:
   * node1에 dedicated=team-a:NoSchedule 테인트 추가:
```
   kubectl taint nodes node1 dedicated=team-a:NoSchedule
```
   * node2에 gpu=nvidia:NoExecute 테인트 추가:
```
   kubectl taint nodes node2 gpu=nvidia:NoExecute
```
  
  5.2. 노드에서 테인트 제거하기

  테인트를 제거하려면 테인트 정의 뒤에 하이픈(-)을 붙입니다.

```
  kubectl taint nodes <노드-이름> <키>:<효과>-
```

  예시:
   * node1에서 dedicated=team-a:NoSchedule 테인트 제거:
```   
   kubectl taint nodes node1 dedicated:NoSchedule-
```
      (값은 제거 시 명시하지 않아도 됩니다.)
   * node2에서 gpu=nvidia:NoExecute 테인트 제거:
```
   kubectl taint nodes node2 gpu:NoExecute-
```
  ---

  6. 파드에 Tolerations 추가하기 (YAML 예제)

  node1에 dedicated=team-a:NoSchedule 테인트가 있고, node2에 gpu=nvidia:NoExecute 테인트가 있다고 가정합니다.

  예제 1: `dedicated=team-a:NoSchedule` 테인트를 허용하는 파드
```
apiVersion: v1
kind: Pod
metadata:
  name: my-team-a-app
spec:
  containers:
  - name: my-app
    image: nginx
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "team-a"
    effect: "NoSchedule"
```   
  이 파드는 dedicated=team-a:NoSchedule 테인트가 있는 node1에 스케줄링될 수 있습니다.

  예제 2: `gpu=nvidia:NoExecute` 테인트를 허용하고 축출 유예 시간을 두는 파드

```
apiVersion: v1
kind: Pod
metadata:
  name: my-gpu-app
spec:
  containers:
  - name: gpu-worker
    image: nvidia/cuda:11.0-base
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "nvidia"
    effect: "NoExecute"
    tolerationSeconds: 300 # 노드에 문제가 생겨 NoExecute 테인트가 추가되면, 300초 동안 축출을 유예합니다.
```
  이 파드는 gpu=nvidia:NoExecute 테인트가 있는 node2에 스케줄링될 수 있습니다. 만약 node2에 gpu=nvidia:NoExecute 테인트가 동적으로 추가되면, 이 파드는 300초 동안 해당 노드에 머무른 후 축출됩니다.

  예제 3: 모든 테인트를 허용하는 파드 (주의!)
```
apiVersion: v1
kind: Pod
metadata:
  name: tolerate-all-taints
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
  tolerations:
  - operator: "Exists" # key와 effect를 명시하지 않으면 모든 키와 모든 효과의 테인트를 허용합니다.
```
  이 파드는 어떤 테인트가 있는 노드에도 스케줄링될 수 있습니다. 일반적으로 권장되지 않으며, 특정 상황에서만 사용해야 합니다.

  ---

  7. Taints와 Tolerations의 관계 (Node Selectors/Affinity와의 차이점)

   * Taints/Tolerations: 노드가 파드를 "밀어내는" 방식입니다. 노드에 테인트를 적용하여 특정 파드의 스케줄링을 방지합니다. 파드는 해당 테인트를 허용하는 톨러레이션을 가져야만 스케줄링될 수 있습니다.
   * Node Selectors/Affinity: 노드가 파드를 "끌어당기는" 방식입니다. 파드에 nodeSelector나 nodeAffinity를 정의하여 특정 레이블을 가진 노드에 파드를 유치합니다.

  이 둘은 상호 보완적으로 사용될 수 있습니다. 예를 들어, 특정 팀을 위한 전용 노드를 만들려면:
   1. 해당 노드에 dedicated=team-a:NoSchedule 테인트를 적용합니다.
   2. 해당 노드에 dedicated=team-a 레이블을 추가합니다.
   3. team-a의 파드에는 dedicated=team-a 톨러레이션과 nodeSelector: {dedicated: team-a}를 모두 추가합니다.
       * 테인트는 다른 팀의 파드가 실수로 이 노드에 스케줄링되는 것을 막고,
       * nodeSelector는 team-a의 파드가 이 노드에 스케줄링되도록 유도합니다.

  ---

  8. 모범 사례 및 고려 사항

   * 노드 격리에 주로 사용: Taints와 Tolerations는 주로 노드를 특정 워크로드로부터 격리하거나, 특정 워크로드만 허용하는 데 사용됩니다.
   * `NoExecute` 효과의 이해: NoExecute는 이미 실행 중인 파드에도 영향을 미치므로, 사용 시 주의해야 합니다. 특히 tolerationSeconds를 사용하여 정상적인 종료 시간을 확보하는 것이 중요합니다.
   * 자동 테인트: 쿠버네티스 자체적으로도 노드에 문제가 발생했을 때(예: 네트워크 연결 끊김, 메모리 부족) 자동으로 테인트를 추가하여 해당 노드에 새로운 파드가 스케줄링되는 것을 막고, 기존 파드를 축출하기도 합니다.
   * 클러스터 오토스케일러와의 연동: 클러스터 오토스케일러는 테인트와 톨러레이션을 고려하여 노드를 확장하거나 축소합니다.

  Taints와 Tolerations를 올바르게 이해하고 사용하면 쿠버네티스 클러스터의 스케줄링 유연성과 안정성을 크게 향상시킬 수 있습니다.
