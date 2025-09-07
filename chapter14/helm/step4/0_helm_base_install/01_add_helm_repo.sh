#!/bin/bash

echo "Adding Prometheus Community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

echo "Updating Helm repositories..."
helm repo update

echo "Helm repository setup complete."
