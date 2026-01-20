#!/bin/bash
set -e

# data-mariadb-galera pvc 삭제 
kubectl delete $(kubectl get pvc -o name | grep data-mariadb-galera)
# data-mariadb-galera pv 삭제
kubectl get pv -o custom-columns=NAME:.metadata.name,CLAIM:.spec.claimRef.name | grep data-mariadb-galera | awk '{print $1}' | xargs kubectl delete pv --dry-run=client

