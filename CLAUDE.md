# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repo contains **K8s deployment manifests, ArgoCD Application definitions, and automation scripts** for the AceNexus microservices platform. There is no application source code here — all service source lives in sibling directories (`../configservice`, `../eurekaservice`, `../gatewayservice`, `../nexusbot`).

**K8s namespace**: `acenexus` (Docker Desktop Kubernetes or Ubuntu k3s, single-node)

## Directory Structure

```
k8s/                    # Kubernetes YAML manifests (one subdir per service)
  configservice/        # RabbitMQ PVC + Deployment + configservice Deployment + Services
  eurekaservice/        # Eureka Deployment + Service
  gatewayservice/       # Gateway Deployment + Service (LoadBalancer :8080)
  nexusbot/             # NexusBot Deployment + Service (LoadBalancer :5001)
  aiclient/             # AIClient-2-API PVC + Deployment + Service (LoadBalancer :3100)
  grafana/              # Grafana PVC + ConfigMap (datasource) + Deployment + Service (LoadBalancer :3000)
  tempo/                # Tempo tracing backend Deployment + Service
argocd/                 # ArgoCD Application CRDs (one per service) + README
deploy_ngrok/           # docker-compose.yml + .env.example + update_webhook.ps1
ngrok-tunnel.bat        # (Windows) Start ngrok, update NEXUSBOT_BASE_URL in K8s, update LINE webhooks
ngrok-tunnel.sh         # (Linux)   同上
restart_k8s.bat         # (Windows) Ordered restart: rabbitmq+config → eureka → gateway+nexusbot
restart_k8s.sh          # (Linux)   同上
```

## CD Flow (GitOps)

```
CI (service repo) → push image to GHCR → update k8s/<service>/deployment.yaml image tag
    → ArgoCD polls deploy repo every 3 min → kubectl apply → K8s rolling update
```

ArgoCD Application YAMLs live in `argocd/`. Each uses `automated: {prune: true, selfHeal: true}`.
See `argocd/README.md` for ArgoCD install and repo access setup.

## Common Operations

### First-time deploy

```bash
kubectl create namespace acenexus
# Create secrets (see README.md for full --from-literal list per service)
kubectl apply -f k8s/aiclient/deployment.yaml -n acenexus
kubectl apply -f k8s/configservice/deployment.yaml -n acenexus
kubectl apply -f k8s/eurekaservice/deployment.yaml -n acenexus
kubectl apply -f k8s/gatewayservice/deployment.yaml -n acenexus
kubectl apply -f k8s/nexusbot/deployment.yaml -n acenexus
kubectl get pods -n acenexus -w
```

### Stop / resume all services

```bash
kubectl scale deployment aiclient configservice eurekaservice gatewayservice nexusbot rabbitmq \
  --replicas=0 -n acenexus  # stop
kubectl scale deployment aiclient configservice eurekaservice gatewayservice nexusbot rabbitmq \
  --replicas=1 -n acenexus  # resume
```

### Ordered restart

```bat
# Windows
restart_k8s.bat
# Linux
bash restart_k8s.sh
# Sequence: rabbitmq+configservice → eurekaservice → gatewayservice+nexusbot
```

Full cluster restart (normal case):
```bash
kubectl rollout restart deployment -n acenexus
kubectl rollout status deployment -n acenexus --timeout=180s
```

### Update config only (no rebuild needed)

```bash
kubectl exec -n acenexus deployment/configservice -- \
  wget -qO- -X POST "http://${SECURITY_USERNAME}:${SECURITY_PASSWORD}@localhost:8888/actuator/busrefresh"
# Only @RefreshScope beans are updated; datasource/eureka settings require pod restart
```

### ngrok + LINE webhook

```bash
# Windows
ngrok-tunnel.bat
# Linux（依賴：docker compose、curl、jq）
bash ngrok-tunnel.sh
# → starts ngrok container, fetches public URL, sets NEXUSBOT_BASE_URL in K8s, updates LINE webhook
# ERR_NGROK_108 = too many tunnels → visit https://dashboard.ngrok.com/agents to kill old sessions
```

### Optional observability stack

```bash
kubectl apply -f k8s/tempo/     # Grafana Tempo tracing backend
kubectl apply -f k8s/grafana/   # Grafana UI at http://localhost:3000 (anonymous admin)
kubectl set env deployment/nexusbot TRACING_SAMPLING_PROBABILITY=1.0 -n acenexus  # enable tracing
```

## Key Architecture Details

### Service networking in K8s

- **LoadBalancer**:
  - Docker Desktop → 自動對應至 `localhost`
  - Ubuntu k3s → 內建 ServiceLB，自動對應至 node IP（`kubectl get nodes -o wide` 查看）
  - 服務：`gatewayservice:8080`, `nexusbot:5001`, `aiclient:3100`
- **ClusterIP** (internal only, use port-forward): `configservice:8888`, `eurekaservice:8761`, `rabbitmq:5672/15672`
- Services communicate by K8s Service DNS name. Gateway routes to nexusbot by DNS, not Eureka.

### MySQL

MySQL runs on the **host machine** (not in K8s).

| 環境 | `MYSQL_HOST` 設定 |
|------|-----------------|
| Docker Desktop | `host.docker.internal`（預設值，自動解析） |
| Ubuntu k3s | 宿主機實際 IP（`kubectl get nodes -o wide` → INTERNAL-IP） |

Ubuntu k3s 上線後更新方式：
```bash
HOST_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
kubectl set env deployment/nexusbot MYSQL_HOST="$HOST_IP" -n acenexus
```

### AIClient-2-API

Runs in K8s (`aiclient` Deployment). Web UI accessible at `http://localhost:3100` (default password: `admin123`).
Config persisted via PVC (`aiclient-config-pvc`, 1Gi). nexusbot reaches it via `http://aiclient:3100/v1`.

### Critical env var quirk

`RABBITMQ_PORT` must be **explicitly set to `"5672"`** in all deployment YAMLs. K8s auto-injects `RABBITMQ_PORT=tcp://ip:port` (from the Service named `rabbitmq`), which breaks Spring Boot's integer parsing.

### initContainers dependency chain

Each service uses `busybox` initContainers to TCP-probe dependencies:
- `configservice` → waits for `rabbitmq:5672`
- `eurekaservice` → waits for `configservice:8888`
- `gatewayservice` → waits for `configservice:8888` + `eurekaservice:8761`
- `nexusbot` → waits for `configservice:8888` + `eurekaservice:8761` + `gatewayservice:8080`

### imagePullPolicy

- GHCR images (`ghcr.io/acenexus/*`): `Always` — ensures rolling update always pulls the new SHA tag.
- Public images (rabbitmq, busybox, grafana, aiclient, mysql): `IfNotPresent`.

### PVC persistence

RabbitMQ (`/var/lib/rabbitmq`, 1Gi), Grafana (`/var/lib/grafana`, 1Gi), AIClient (`/app/configs`, 1Gi).
On Docker Desktop, PVC data lives inside the Docker Desktop VM. On Ubuntu k3s, data is at `/var/lib/rancher/k3s/storage/`.

## Commit Message Format

```
[type] 中文描述
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `config`
