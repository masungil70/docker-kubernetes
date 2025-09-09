#!/bin/bash

# This script automates the full teardown, reset, and redeployment process.

set -e

echo "--- STEP 1: DELETING ALL MARIADB RESOURCES ---"
kubectl delete statefulset,service,pvc,secret,configmap -l app=mariadb --ignore-not-found=true
echo "Waiting for MariaDB resources to terminate..."
sleep 15

echo "--- SCRIPT FINISHED ---"
