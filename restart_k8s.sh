#!/usr/bin/env bash
# AceNexus K8s 有序重啟腳本（Linux / Ubuntu）
# 用法：bash restart_k8s.sh

set -euo pipefail

echo "========================================"
echo "  AceNexus K8s 有序重啟腳本"
echo "========================================"
echo
echo "必須按順序重啟，否則 Eureka registry 會遺失。"
echo

# ── 步驟 1：configservice + rabbitmq ──────────────────────────
echo "[1/3] 重啟 configservice + rabbitmq..."
kubectl rollout restart deployment/configservice deployment/rabbitmq -n acenexus
kubectl rollout status deployment/rabbitmq    -n acenexus --timeout=120s
kubectl rollout status deployment/configservice -n acenexus --timeout=120s
echo "[OK] configservice + rabbitmq 就緒。"
echo

# ── 步驟 2：eurekaservice ─────────────────────────────────────
echo "[2/3] 重啟 eurekaservice..."
kubectl rollout restart deployment/eurekaservice -n acenexus
kubectl rollout status deployment/eurekaservice -n acenexus --timeout=120s
echo "[OK] eurekaservice 就緒。"
echo

# ── 步驟 3：gatewayservice + nexusbot ─────────────────────────
echo "[3/3] 重啟 gatewayservice + nexusbot..."
kubectl rollout restart deployment/gatewayservice deployment/nexusbot -n acenexus
kubectl rollout status deployment/gatewayservice -n acenexus --timeout=120s
kubectl rollout status deployment/nexusbot       -n acenexus --timeout=120s
echo "[OK] gatewayservice + nexusbot 就緒。"
echo

echo "========================================"
echo "  全部重啟完成！"
echo "========================================"
echo

# ── ArgoCD UI Port-Forward ────────────────────────────────────
echo "啟動 ArgoCD UI port-forward（背景執行）..."
kubectl port-forward svc/argocd-server 9090:443 -n argocd &>/dev/null &
echo "ArgoCD UI：https://localhost:9090（帳號：admin）"
echo "（停止 port-forward：kill \$(lsof -ti:9090)）"
