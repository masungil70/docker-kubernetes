#!/bin/bash
set -e

# API 서비스 종료
kubectl delete -f api-service.yaml
# API 서버 종료
kubectl delete -f api-deployment.yaml

# helm으로 MariaDB Galera 종료
helm uninstall mariadb-galera 


