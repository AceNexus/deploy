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
deploy_ngrok/           # docker-compose.yml + ngrok.yml (tunnel 定義) + .env.example
                        #   sync_tunnels.ps1   啟動/沿用 tunnel 並同步 nexusbot + LINE webhook
                        #   status.ps1         唯讀狀態比對
                        #   notify.ps1         Windows 通知 (toast)
                        #   get_tunnel_url.ps1 依 upstream port 取 public URL
                        #   update_webhook.ps1 對 LINE API 寫入 webhook endpoint
ngrok-tunnel.bat        # (Windows) Start ngrok, update NEXUSBOT_BASE_URL in K8s, update LINE webhooks
ngrok-tunnel.sh         # (Linux)   同上
ngrok-status.bat        # (Windows) 唯讀：目前網址 + LINE webhook / nexusbot 是否跟得上
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

**同一個 agent 開兩個 tunnel**（free plan 只允許一個 agent session，開第二個容器會拿到
ERR_NGROK_108），定義在 `deploy_ngrok/ngrok.yml`，以 `start --all` 啟動：

| tunnel | upstream | 用途 |
|---|---|---|
| `gateway` | `host.docker.internal:8080` | gatewayservice —— LINE webhook 走這個 |
| `subgo` | `host.docker.internal:9000` | SubGo 字幕服務的網頁（`D:\SubGo`，另一個 compose 專案） |

⚠️ **取網址不可用 `tunnels[0]`** —— ngrok API 的回傳順序不保證（實測 subgo 排在 gateway
前面）。取錯不會報錯，而是把 LINE webhook 指到 SubGo 的網頁上：LINE 收到 200，bot 卻
永遠沒反應。兩支腳本改為依 upstream port 篩選（`get_tunnel_url.ps1` / jq `endswith`）。

#### 開機自動同步

Startup 資料夾的捷徑帶 `--boot` 參數（最小化執行、跑完不停留），結果以 Windows 通知顯示。
想隨時查目前狀態就跑 `ngrok-status.bat`（桌面有捷徑「ngrok 狀態」），它只讀不寫。

`--boot` 與手動執行的差別只有兩件事：等 Docker Desktop 與 K8s 就緒（各有逾時），以及
結束不 pause。**這個等待是必要的** —— Startup 捷徑在登入當下就執行，而 Docker Desktop
自己也還在啟動，`docker compose` / `kubectl` 一失敗就走進錯誤分支，同步靜靜地沒有發生。

另外兩個刻意的行為：

- **容器已在跑且兩個 tunnel 都在時「沿用」，不 down/up。** compose 設了 `restart: always`，
  Docker Desktop 一起來就會把容器帶起（並拿到新網址）；再 down/up 等於同一次開機換兩次
  網址，而且緊接著重連很容易撞上 ERR_NGROK_108。
- **只在目前值與新網址不同時才寫入。** `kubectl set env` 會觸發 nexusbot 滾動重啟，
  LINE 那側是對外部 API 的寫入 —— 兩者都不該每次開機都做一次。

⚠️ **`.bat` 一律保持純 ASCII。** cmd 會以 `chcp` 設定的 codepage 逐行重讀 batch 檔，
UTF-8 中文註解會讓 parser 的位元組位移跑掉，開始執行註解的片段 —— 症狀是
`'ershell' is not recognized`，而真正那行 `powershell` 從未執行。中文說明放在 `.ps1` 裡
（PowerShell 解得正確），batch 只留英文。

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
