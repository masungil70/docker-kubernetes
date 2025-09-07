#!/bin/bash

#master 에 등록한다 (아래 참조 : 실제 master1에서 kubeadm init 실행 결과 로 출력된 token 사용 실행 할 것)
#kubeadm join lb.example.com:6443 --token ntrvyj.q88z2kbpu3qaqlgz \
#        --discovery-token-ca-cert-hash sha256:e9882036587ca38377582d125eeb4338aa1a718d08bf9e0532e3acb5cf7a2776
#

#윈도우에서 개인인증서로 사전에 복사 .ssh에 복사하고 진행한다 
#scp -r ~/.ssh kosa@worker1:~/.ssh
#scp -r ~/.ssh kosa@worker2:~/.ssh
# worker node에서 kubectl 명령실행 할 수 있게 설정하는 방법 
mkdir -p $HOME/.kube
scp kosa@master:~/.kube/config $HOME/.kube/config

#
# 수동으로 추가한 노드일 경우 (예: kubeadm join 사용)
#
#  kubeadm 등을 사용하여 직접 클러스터에 참여시킨 노드는 다음 절차를 따릅니다.
#
#  1단계: 파드(Pod) 안전하게 제거 (Drain)
#
#  kubectl drain <node_name> --ignore-daemonsets
#
#  2단계: 클러스터에서 노드 정보 삭제
#
#  kubectl delete node <node_name>
#
# 3단계: 워커 노드 자체에서 초기화
#
# 삭제할 워커 노드에 직접 접속하여 다음 명령어로 k8s 관련 설정을 초기화합니다.
#
#  kubeadm reset
#
# 4단계: (필요시) 서버 종료
#
# 이제 해당 서버의 전원을 꺼도 됩니다
