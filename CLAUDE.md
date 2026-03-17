# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repo contains **K8s deployment manifests, Docker build contexts, and automation scripts** for the AceNexus microservices platform. There is no application source code here — all service source lives in sibling directories (`../configservice`, `../eurekaservice`, `../gatewayservice`, `../nexusbot`).

**K8s namespace**: `acenexus` (Docker Desktop Kubernetes, single-node)

## Directory Structure

```
k8s/                    # Kubernetes YAML manifests (one subdir per service)
  configservice/        # RabbitMQ PVC + Deployment + configservice Deployment + Services
  eurekaservice/        # Eureka Deployment + Service
  gatewayservice/       # Gateway Deployment + Service (LoadBalancer :8080)
  nexusbot/             # NexusBot Deployment + Service (LoadBalancer :5001)
  grafana/              # Grafana PVC + ConfigMap (datasource) + Deployment + Service (LoadBalancer :3000)
  tempo/                # Tempo tracing backend Deployment + Service
build_image_*/          # Docker build contexts — each contains just a Dockerfile; JAR must be copied in before build
deploy_ngrok/           # docker-compose.yml + .env.example + update_webhook.ps1
configs_aiclient/       # Persistent config volume for AIClient-2-API container (auto-created)
ngrok-tunnel.bat        # Start ngrok, update nexusbot NEXUSBOT_BASE_URL in K8s, update LINE webhooks
restart_k8s.bat         # Ordered restart: rabbitmq+config → eureka → gateway+nexusbot (waits for readiness)
start_deploy_aiclient.bat  # Run justlikemaki/aiclient-2-api Docker container on :3100
```

## Common Operations

### First-time deploy

```bash
kubectl create namespace acenexus

# Create secrets (see README.md for full --from-literal list per service)
kubectl create secret generic configservice-secret -n acenexus --from-literal=...
kubectl create secret generic eurekaservice-secret -n acenexus --from-literal=...
kubectl create secret generic gatewayservice-secret -n acenexus --from-literal=...
kubectl create secret generic nexusbot-secret -n acenexus --from-literal=...

# Apply manifests in dependency order
kubectl apply -f k8s/configservice/deployment.yaml -n acenexus
kubectl apply -f k8s/eurekaservice/deployment.yaml -n acenexus
kubectl apply -f k8s/gatewayservice/deployment.yaml -n acenexus
kubectl apply -f k8s/nexusbot/deployment.yaml -n acenexus

kubectl get pods -n acenexus -w   # wait for all 1/1 Running
```

### Rebuild image after code change

```bash
# 1. Build JAR in service source directory (e.g. D:\java\AceNexus\nexusbot)
$env:JAVA_HOME = 'C:\Users\User\.jdks\temurin-21.0.5'; .\gradlew bootJar  # Java 21 services
# nexusbot uses default Java 17 jdk — no JAVA_HOME override needed

# 2. Build Docker image (Dockerfile is in the service source directory)
docker build -t nexusbot:local .

# 3. Trigger rolling restart
kubectl rollout restart deployment/nexusbot -n acenexus
kubectl rollout status deployment/nexusbot -n acenexus
```

### Update config only (no rebuild needed)

```bash
# Edit configservice/configs/*-prod.yml in the configservice source repo, then:
kubectl exec -n acenexus deployment/configservice -- \
  wget -qO- -X POST "http://${SECURITY_USERNAME}:${SECURITY_PASSWORD}@localhost:8888/actuator/busrefresh"
# Note: only @RefreshScope beans are updated; datasource/eureka settings require pod restart
```

### Ordered restart (when Eureka registry must be preserved)

```bat
restart_k8s.bat
# Sequence: rabbitmq+configservice → eurekaservice → gatewayservice+nexusbot
# Each step waits for readiness before proceeding
```

Full cluster restart without ordering (normal case):
```bash
kubectl rollout restart deployment -n acenexus
kubectl rollout status deployment -n acenexus --timeout=180s
```

### Stop / resume all services

```bash
# Stop (Pods removed, PVCs and Secrets preserved)
kubectl scale deployment configservice eurekaservice gatewayservice nexusbot rabbitmq --replicas=0 -n acenexus

# Resume
kubectl scale deployment configservice eurekaservice gatewayservice nexusbot rabbitmq --replicas=1 -n acenexus
```

### ngrok + LINE webhook

```bash
# One-time setup: create deploy_ngrok/.env from example and fill in tokens
cp deploy_ngrok/.env.example deploy_ngrok/.env

# Every session start:
ngrok-tunnel.bat
# → starts ngrok container, fetches public URL, sets NEXUSBOT_BASE_URL in K8s, updates LINE webhook
# ERR_NGROK_108 = too many tunnels → visit https://dashboard.ngrok.com/agents to kill old sessions
```

### AIClient-2-API

```bat
start_deploy_aiclient.bat
# Runs justlikemaki/aiclient-2-api, mounts ./configs_aiclient for persistence
# Web UI: http://localhost:3100 (default password: admin123)
```

### Optional observability stack

```bash
kubectl apply -f k8s/tempo/     # Grafana Tempo tracing backend
kubectl apply -f k8s/grafana/   # Grafana UI at http://localhost:3000 (anonymous admin)

# Enable tracing on a service (set to 0.0 to disable):
kubectl set env deployment/nexusbot TRACING_SAMPLING_PROBABILITY=1.0 -n acenexus
```

## Key Architecture Details

### Service networking in K8s

- `gatewayservice` and `nexusbot` use **LoadBalancer** type (Docker Desktop maps these to `localhost:8080` / `localhost:5001` directly).
- `configservice`, `eurekaservice`, `rabbitmq` use **ClusterIP** — access via `kubectl port-forward` for local inspection.
- Services communicate by **K8s Service DNS name** (e.g., `rabbitmq:5672`, `configservice:8888`). Gateway routes to nexusbot by DNS, not Eureka.

### Critical env var quirk

`RABBITMQ_PORT` must be **explicitly set to `"5672"`** in all deployment YAMLs. K8s auto-injects `RABBITMQ_PORT=tcp://ip:port` (from the Service named `rabbitmq`), which breaks Spring Boot's integer parsing. The explicit env var overrides the auto-injection.

### nexusbot MySQL connection

nexusbot connects to MySQL on the **host machine** via `host.docker.internal:3306` (not a K8s service). The database must be running on the Windows host before nexusbot starts.

### initContainers dependency chain

Each service YAML uses `busybox` initContainers to TCP-probe its dependencies before starting the main container:
- `configservice` waits for `rabbitmq:5672`
- `eurekaservice` waits for `configservice:8888`
- `gatewayservice` waits for `configservice:8888` + `eurekaservice:8761`
- `nexusbot` waits for `configservice:8888` + `eurekaservice:8761` + `gatewayservice:8080`

### imagePullPolicy

- Local service images (`*:local`): `Never` — K8s will error if the image isn't present locally; always build before deploying.
- Public images (rabbitmq, busybox, grafana, ngrok): `IfNotPresent`.

### PVC persistence

RabbitMQ (`/var/lib/rabbitmq`) and Grafana (`/var/lib/grafana`) each have a 1Gi PVC. These survive Pod restarts and `kubectl rollout restart`. To reset data, manually delete the PVC.

## Commit Message Format

```
[type] 中文描述
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `config`
