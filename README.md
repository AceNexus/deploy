# AceNexus — K8s 部署 & CI/CD 指南

本 repo 是 AceNexus 微服務平台的 **部署中心**，包含：

- K8s YAML manifests（`k8s/`）
- ArgoCD Application 設定（`argocd/`）
- 本機操作腳本（`*.bat`）

> 程式碼與業務邏輯請見各服務 repo：`nexusbot` / `configservice` / `eurekaservice` / `gatewayservice`

---

## 目錄

- [架構總覽](#架構總覽)
- [CI/CD 流程說明](#cicd-流程說明)
- [首次建置步驟](#首次建置步驟)
- [日常操作](#日常操作)
- [更新部署](#更新部署)
- [回滾](#回滾)
- [常用指令](#常用指令)

---

## 架構總覽

```
開發者 push code
    │
    ▼
GitHub Actions CI（各服務 repo）
    │  build → test → Trivy scan → push image
    ▼
GHCR（ghcr.io/acenexus/<service>:<sha>）
    │  更新 deploy repo image tag
    ▼
AceNexus/deploy repo（本 repo）
    │  ArgoCD 每 3 分鐘輪詢
    ▼
ArgoCD → kubectl apply
    │
    ▼
Kubernetes（namespace: acenexus）
  nexusbot · configservice · eurekaservice · gatewayservice · rabbitmq · aiclient
```

**流量路徑：**

```
LINE Webhook → ngrok → gatewayservice :8080 → nexusbot :5001
```

---

## CI/CD 流程說明

### CI — 各服務 repo 各自負責

每個服務 repo（nexusbot / configservice / eurekaservice / gatewayservice）都有：

```
.github/workflows/ci.yml
```

#### 觸發條件

| 事件           | 執行內容                             |
|--------------|----------------------------------|
| PR → main    | test job（build + test），PR 通過才可合併 |
| push to main | test job → release job（完整流程）     |

#### 兩個 Job 的分工

**Job 1：test**（PR + main 都執行）

```
① checkout source
② chmod +x gradlew
③ setup Java（nexusbot=17, 其他=21）
④ ./gradlew build    ← compile + 單元測試，失敗即中止
```

**Job 2：release**（僅 main，needs: test）

```
① checkout source + checkout deploy repo（DEPLOY_REPO_PAT）
② 計算 SHORT_SHA（git sha 前 8 碼）
③ ./gradlew bootJar  ← 只打包 JAR，不重跑測試
④ docker build -t ghcr.io/acenexus/<service>:<sha> .
⑤ Trivy 掃描         ← HIGH/CRITICAL 漏洞中止，不 push
⑥ docker push ghcr.io/acenexus/<service>:<sha>
   docker push ghcr.io/acenexus/<service>:latest
⑦ sed 更新 deploy repo k8s/<service>/deployment.yaml image tag
   git commit "[skip ci] update <service> to <sha>"
   git push → AceNexus/deploy
```

### CD — 本 repo（deploy）負責

ArgoCD 監聽本 repo，每 3 分鐘輪詢：

```
偵測到 k8s/<service>/deployment.yaml image tag 變動
    → kubectl apply
    → K8s rolling update
    → ArgoCD UI 顯示 Synced + Healthy
```

### 安全防線

```
gradle build 失敗   → release job 不啟動，cluster 不動
Trivy 掃描失敗      → image 不 push，deploy repo 不更新
deploy repo 不更新  → ArgoCD 不動，cluster 維持現有版本
```

### 端對端時間

```
push to main → test（2–3 min）→ release（3–5 min）→ ArgoCD 輪詢（最多 3 min）→ rollout

總計：最多約 8–11 分鐘完成部署
```

---

## 首次建置步驟

### Step 1：建立 K8s namespace

```bash
kubectl create namespace acenexus
```

### Step 2：建立 K8s Secrets

**configservice-secret**

```bash
kubectl create secret generic configservice-secret -n acenexus \
  --from-literal=security-username=<帳號> \
  --from-literal=security-password=<密碼> \
  --from-literal=encrypt-key=<JCE加密金鑰> \
  --from-literal=rabbitmq-user=<RabbitMQ帳號> \
  --from-literal=rabbitmq-pass=<RabbitMQ密碼>
```

**eurekaservice-secret**

```bash
kubectl create secret generic eurekaservice-secret -n acenexus \
  --from-literal=security-username=<帳號> \
  --from-literal=security-password=<密碼> \
  --from-literal=config-server-username=<configservice帳號> \
  --from-literal=config-server-password=<configservice密碼> \
  --from-literal=rabbitmq-username=<RabbitMQ帳號> \
  --from-literal=rabbitmq-password=<RabbitMQ密碼>
```

**gatewayservice-secret**

```bash
kubectl create secret generic gatewayservice-secret -n acenexus \
  --from-literal=security-username=<帳號> \
  --from-literal=security-password=<密碼> \
  --from-literal=config-server-username=<configservice帳號> \
  --from-literal=config-server-password=<configservice密碼> \
  --from-literal=rabbitmq-username=<RabbitMQ帳號> \
  --from-literal=rabbitmq-password=<RabbitMQ密碼> \
  --from-literal=jwt-secret=<JWT簽章金鑰>
```

**nexusbot-secret**

```bash
kubectl create secret generic nexusbot-secret -n acenexus \
  --from-literal=config-server-username=<configservice帳號> \
  --from-literal=config-server-password=<configservice密碼> \
  --from-literal=mysql-username=<MySQL帳號> \
  --from-literal=mysql-password=<MySQL密碼> \
  --from-literal=rabbitmq-username=<RabbitMQ帳號> \
  --from-literal=rabbitmq-password=<RabbitMQ密碼> \
  --from-literal=line-bot-channel-token=<LINE Channel Token> \
  --from-literal=line-bot-channel-secret=<LINE Channel Secret> \
  --from-literal=groq-api-key=<Groq API Key> \
  --from-literal=email-username=<Gmail帳號> \
  --from-literal=email-password=<Gmail應用程式密碼> \
  --from-literal=admin-password-seed=<管理員密碼種子> \
  --from-literal=gemini-proxy-api-key=<Gemini Proxy Key>
```

**ghcr-secret**（K8s 從 GHCR 拉取 private image 用）

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<GitHub帳號> \
  --docker-password=<GitHub PAT> \
  -n acenexus
```

確認所有 Secret 已建立：

```bash
kubectl get secret -n acenexus
```

### Step 3：初次套用 K8s YAML

```bash
kubectl apply -f k8s/aiclient/deployment.yaml -n acenexus
kubectl apply -f k8s/configservice/deployment.yaml -n acenexus
kubectl apply -f k8s/eurekaservice/deployment.yaml -n acenexus
kubectl apply -f k8s/gatewayservice/deployment.yaml -n acenexus
kubectl apply -f k8s/nexusbot/deployment.yaml -n acenexus

kubectl get pods -n acenexus -w   # 等待全部 1/1 Running
```

### Step 4：安裝 ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd -w   # 等待全部 Running
```

### Step 5：設定 ArgoCD 存取 deploy repo

```bash
# 下載 argocd CLI（Windows，在 Git Bash 執行）
curl -sL https://github.com/argoproj/argo-cd/releases/latest/download/argocd-windows-amd64.exe -o /tmp/argocd.exe

# 開啟 ArgoCD UI（另開一個終端機保持 port-forward 運行）
kubectl port-forward svc/argocd-server 9090:443 -n argocd
```

取得初始密碼（PowerShell）：

```powershell
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

```bash
# 登入並設定 deploy repo（Git Bash）
/tmp/argocd.exe login localhost:9090 --insecure --username admin --password <初始密碼>
/tmp/argocd.exe repo add https://github.com/AceNexus/deploy.git \
  --username <GitHub帳號> \
  --password <GitHub PAT>
```

### Step 6：套用 ArgoCD Application

> ⚠️ 須在首次 CI 執行成功（GHCR 已有 image）後才執行，
> 否則 K8s 會因 image 不存在（ImagePullBackOff）中斷現有服務。

```bash
kubectl apply -f argocd/aiclient.yaml
kubectl apply -f argocd/configservice.yaml
kubectl apply -f argocd/eurekaservice.yaml
kubectl apply -f argocd/gatewayservice.yaml
kubectl apply -f argocd/nexusbot.yaml

kubectl get application -n argocd   # 全部 Synced + Healthy 即完成
```

### Step 7：設定各服務 repo 的 GitHub Secret

每個服務 repo（nexusbot / configservice / eurekaservice / gatewayservice）需要：

```
Settings → Secrets and variables → Actions → New repository secret

名稱：DEPLOY_REPO_PAT
值：<擁有 AceNexus/deploy Contents:write 權限的 GitHub PAT>
```

### Step 8：啟動 ngrok

```bash
# 一次性設定
cp deploy_ngrok/.env.example deploy_ngrok/.env
# 填入 NGROK_AUTHTOKEN 與 LINE_CHANNEL_ACCESS_TOKEN

# 每次啟動
ngrok-tunnel.bat
# 自動取得 public URL → 更新 K8s NEXUSBOT_BASE_URL → 更新 LINE webhook
```

驗證整條鏈路：

```bash
curl http://localhost:8080/actuator/health
curl https://<ngrok-url>/api/linebot/actuator/health -H "ngrok-skip-browser-warning: true"
# 兩者都回傳 {"status":"UP"} 即完成
```

---

## 日常操作

### 啟動所有服務

```bash
kubectl scale deployment aiclient configservice eurekaservice gatewayservice nexusbot rabbitmq \
  --replicas=1 -n acenexus
```

### 停止所有服務

```bash
kubectl scale deployment aiclient configservice eurekaservice gatewayservice nexusbot rabbitmq \
  --replicas=0 -n acenexus
```

### 有序重啟（rabbitmq → configservice → eureka → gateway → nexusbot）

```bat
restart_k8s.bat
```

### 全體重啟（無順序，一般情況用）

```bash
kubectl rollout restart deployment -n acenexus
kubectl rollout status deployment -n acenexus --timeout=180s
```

---

## 更新部署

### 情境一：改了程式碼（自動）

```bash
git push origin main   # 在各服務 repo 執行
```

GitHub Actions 自動執行完整 CI/CD，最多 11 分鐘後 K8s 跑起新版本。

### 情境二：只改了設定檔（`*-prod.yml`）

```bash
# 編輯 configservice/configs/*-prod.yml 並 push 後：
kubectl exec -n acenexus deployment/configservice -- \
  wget -qO- -X POST \
  "http://${SECURITY_USERNAME}:${SECURITY_PASSWORD}@localhost:8888/actuator/busrefresh"
# 只更新 @RefreshScope Bean，不需重啟 Pod
```

> datasource / eureka 等啟動時讀取的設定需重啟：
> ```bash
> kubectl rollout restart deployment/<service> -n acenexus
> ```

### 情境三：改了 K8s YAML

```bash
kubectl apply -f k8s/<service>/deployment.yaml -n acenexus
```

### 情境四：更新 Secret

```bash
kubectl delete secret <secret-name> -n acenexus
kubectl create secret generic <secret-name> -n acenexus --from-literal=key=value ...
kubectl rollout restart deployment/<service> -n acenexus
```

---

## 回滾

| 情境           | 操作                                                |
|--------------|---------------------------------------------------|
| 新版本有問題，回到上一版 | `git revert` deploy repo 的 Bot commit，ArgoCD 自動同步 |
| 回到任意歷史版本     | ArgoCD UI → 選服務 → History → Rollback              |
| CI build 失敗  | 不需操作，cluster 維持現有版本                               |

```bash
# 或直接在 deploy repo 還原 image tag
git revert HEAD
git push
```

---

## 常用指令

### 查看狀態

```bash
kubectl get pods -n acenexus              # Pod 狀態
kubectl get pods -n acenexus -w           # 持續監看
kubectl get application -n argocd         # ArgoCD 同步狀態
```

### 查看 Log

```bash
kubectl logs -n acenexus deployment/<service> -f        # 即時串流
kubectl logs -n acenexus deployment/<service> --tail=50 # 最後 50 行
```

### 偵錯

```bash
kubectl describe pod -n acenexus -l app=<service>       # 啟動失敗事件
kubectl exec -it -n acenexus deployment/<service> -- sh # 進入容器
```

### AIClient Web UI（AI 模型與帳號設定）

AIClient Service 為 LoadBalancer，直接從瀏覽器存取：

```
http://localhost:3100   （預設密碼：admin123）
```

在 Web UI 可設定：AI 提供商帳號、模型對應、failover 優先順序、帳號池。
設定存入 PVC（`aiclient-config-pvc`，1Gi），Pod 重啟後不遺失。

### MySQL（獨立安裝，不在 K8s 內）

MySQL 獨立安裝在 host 上，nexusbot 透過 `host.docker.internal:3306` 連線。

```bash
# Ubuntu 安裝
sudo apt install mysql-server
sudo systemctl enable mysql

# 建立資料庫與帳號
mysql -u root -p
CREATE DATABASE nexusbot CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '<帳號>'@'%' IDENTIFIED BY '<密碼>';
GRANT ALL PRIVILEGES ON nexusbot.* TO '<帳號>'@'%';
FLUSH PRIVILEGES;
```

> Ubuntu 上 `host.docker.internal` 不可用，需將 `k8s/nexusbot/deployment.yaml` 的
> `MYSQL_HOST` 改為 Ubuntu host IP（通常為 `172.17.0.1` 或實際網卡 IP）。

### Port Forward（存取內部服務）

```bash
kubectl port-forward svc/configservice  8888:8888 -n acenexus
kubectl port-forward svc/eurekaservice  8761:8761 -n acenexus
kubectl port-forward svc/rabbitmq      15672:15672 -n acenexus
kubectl port-forward svc/argocd-server  8090:443   -n argocd
```

### ArgoCD UI

```bat
argocd-ui.bat
```

或手動執行：
```bash
kubectl port-forward svc/argocd-server 9090:443 -n argocd
# 瀏覽器：https://localhost:9090（帳號：admin）
```

### 可選：觀測性服務

```bash
kubectl apply -f k8s/tempo/    # Grafana Tempo（分散式追蹤）
kubectl apply -f k8s/grafana/  # Grafana UI（http://localhost:3000）

# 開啟追蹤（預設關閉）
kubectl set env deployment/nexusbot TRACING_SAMPLING_PROBABILITY=1.0 -n acenexus
```
