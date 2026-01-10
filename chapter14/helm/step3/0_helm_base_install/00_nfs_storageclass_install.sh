#!/bin/bash

kubectl apply -f ./nfs-provisioner.yaml
kubectl apply -f ./nfs-storageclass.yaml
echo "NFS StorageClass applied."