# AceNexus K8s 部署指南

## 目錄

- [架構說明](#架構說明)
- [前置條件](#前置條件)
- [首次部署](#首次部署)
- [日常操作](#日常操作)
- [更新部署](#更新部署)
- [常用指令](#常用指令)

---

## 架構說明

```
LINE Webhook
  → ngrok (HTTPS)
    → gatewayservice :8080  [JWT 驗證、請求日誌]
      → nexusbot :5001      [K8s Service DNS 直連，不走 Eureka]
```

**服務清單**

| 服務             | Image                        | Port         | 說明                                  |
|----------------|------------------------------|--------------|-------------------------------------|
| rabbitmq       | rabbitmq:3-management-alpine | 5672 / 15672 | 訊息佇列，Spring Cloud Bus 用             |
| configservice  | configservice:local          | 8888         | 設定中心，從 K8s ConfigMap 提供設定檔          |
| eurekaservice  | eurekaservice:local          | 8761         | 服務註冊（監控用，非路由關鍵路徑）                   |
| gatewayservice | gatewayservice:local         | 8080         | API Gateway，直連 nexusbot K8s Service |
| nexusbot       | nexusbot:local               | 5001         | LINE Bot 主程式                        |

**設定檔管理**：所有服務的設定檔（`*-prod.yml`）集中在 `k8s/configs/configmap.yaml`，
更新後 `kubectl apply` 即可，不需重建 image 也不需 push 到 GitHub。

---

## 前置條件

- Docker Desktop 已啟動，並在 Settings → Kubernetes → Enable Kubernetes 已勾選

```bash
kubectl get nodes   # 應看到 docker-desktop Ready
```

---

## 首次部署

### 步驟 1：建立 Namespace

```bash
kubectl create namespace acenexus
```

---

### 步驟 2：建立 Secret

將所有敏感資訊存入 K8s Secret，部署 YAML 透過 `secretKeyRef` 引用。

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

確認所有 Secret 已建立：

```bash
kubectl get secret -n acenexus
```

---

### 步驟 3：Build Docker Image

各服務 JAR 需先在各自的服務目錄用 Gradle 建置，再複製到 `build_image_*/` 目錄後 build image。

> **注意**：Windows 系統 Java 預設指向 Java 8，Spring Boot 3.4.x 需要 Java 21：
> ```powershell
> $env:JAVA_HOME = 'C:\Users\User\.jdks\temurin-21.0.5'; .\gradlew bootJar
> ```

**configservice**

```bash
# 在 D:\java\AceNexus\configservice 執行
./gradlew bootJar
cp build/libs/configservice.jar ../windows_start/build_image_configservice/
cd ../windows_start
docker build -t configservice:local ./build_image_configservice/
```

**eurekaservice**

```bash
# 在 D:\java\AceNexus\eurekaservice 執行
./gradlew bootJar
cp build/libs/eurekaservice.jar ../windows_start/build_image_eurekaservice/
cd ../windows_start
docker build -t eurekaservice:local ./build_image_eurekaservice/
```

**gatewayservice**

```bash
# 在 D:\java\AceNexus\gatewayservice 執行
./gradlew bootJar
cp build/libs/gatewayservice.jar ../windows_start/build_image_gatewayservice/
cd ../windows_start
docker build -t gatewayservice:local ./build_image_gatewayservice/
```

**nexusbot**

```bash
# 在 D:\java\AceNexus\nexusbot 執行
./gradlew bootJar
cp build/libs/nexusbot.jar ../windows_start/build_image_nexusbot/
cd ../windows_start
docker build -t nexusbot:local ./build_image_nexusbot/
```

---

### 步驟 4：套用所有服務 YAML

```bash
cd windows_start

# RabbitMQ + configservice
kubectl apply -f k8s/configservice/deployment.yaml -n acenexus

# eurekaservice
kubectl apply -f k8s/eurekaservice/deployment.yaml -n acenexus

# gatewayservice
kubectl apply -f k8s/gatewayservice/deployment.yaml -n acenexus

# nexusbot
kubectl apply -f k8s/nexusbot/deployment.yaml -n acenexus
```

監看所有 Pod 啟動：

```bash
kubectl get pods -n acenexus -w
```

全部變成 `1/1 Running` 後完成。

---

### 步驟 5：啟動 ngrok

#### 5-1. 建立 ngrok `.env`（只需執行一次）

```bash
cp deploy_ngrok/.env.example deploy_ngrok/.env
```

編輯 `deploy_ngrok/.env`，填入以下內容：

```env
# 取得網址：https://dashboard.ngrok.com/get-started/your-authtoken
NGROK_AUTHTOKEN=<你的 ngrok authtoken>

# LINE Bot 主要頻道
# 取得網址：https://developers.line.biz/console/ → Messaging API → Channel access token
LINE_CHANNEL_ACCESS_TOKEN=<LINE Channel Access Token>
LINE_WEBHOOK_PATH=/api/linebot/webhook

# LINE Bot 測試頻道（選填，沒有第二個 Bot 可留空）
LINE_CHANNEL_ACCESS_TOKEN_TEST=
LINE_WEBHOOK_PATH_TEST=/api/linebot-test/webhook
```

#### 5-2. 每次啟動 ngrok

執行 `ngrok-tunnel.bat`，腳本會自動：

1. 啟動 ngrok Docker 容器，將 `localhost:8080`（gateway）對外暴露為 HTTPS 網址
2. 從 `localhost:4040` 取得動態公開網址並複製到剪貼簿
3. 執行 `kubectl set env deployment/nexusbot NEXUSBOT_BASE_URL=<url>` 更新 K8s 環境變數
4. 呼叫 LINE API 自動更新 Bot 的 Webhook 網址

完成後流量路徑：

```
LINE → https://<ngrok>.ngrok-free.app → localhost:8080 → gatewayservice → nexusbot
```

監控介面：http://localhost:4040

> **常見錯誤**：`ERR_NGROK_108` = tunnel 數量已滿，
> 請至 https://dashboard.ngrok.com/agents 手動關閉舊 session 或等待 5 分鐘。

---

### 步驟 6：驗證整個鏈路

```bash
# 直接打 gateway
curl http://localhost:8080/actuator/health

# 透過 ngrok 打到 nexusbot（完整路徑）
curl https://<ngrok-url>/api/linebot/actuator/health -H "ngrok-skip-browser-warning: true"
```

兩個都回傳 `{"status":"UP"}` 即部署完成。

---

## 日常操作

### 全體重啟

```bash
kubectl rollout restart deployment -n acenexus
```

不需要按順序，gateway 改走 K8s DNS 直連後，重啟順序不再影響服務可用性。

重啟後確認：

```bash
kubectl rollout status deployment -n acenexus --timeout=180s
```

---

### 停止 / 恢復所有服務

```bash
# 停止（Pod 消失，設定保留）
kubectl scale deployment configservice eurekaservice gatewayservice nexusbot rabbitmq \
  --replicas=0 -n acenexus

# 恢復
kubectl scale deployment configservice eurekaservice gatewayservice nexusbot rabbitmq \
  --replicas=1 -n acenexus
```

---

## 更新部署

### 情境一：只改了服務設定（*-prod.yml）

編輯 `configservice/configs/` 下的設定檔並 push 到 GitHub，然後：

```bash
# 透過 Spring Cloud Bus 即時刷新（不需重啟 Pod）
kubectl exec -n acenexus deployment/configservice -- \
  wget -qO- -X POST "http://${SECURITY_USERNAME}:${SECURITY_PASSWORD}@localhost:8888/actuator/busrefresh"
```

> busrefresh 只更新 `@RefreshScope` 的 Bean，
> 若改的是 datasource / eureka 等啟動時才讀的設定，需要重啟對應服務：
> ```bash
> kubectl rollout restart deployment/<service> -n acenexus
> ```

---

### 情境二：改了程式碼（需要重建 image）

以 nexusbot 為例：

```bash
# 1. 建置 JAR
cd D:\java\AceNexus\nexusbot
./gradlew bootJar

# 2. 複製到 build_image 目錄
cp build/libs/nexusbot.jar ../windows_start/build_image_nexusbot/

# 3. 重建 image（tag 不變，直接覆蓋）
cd ../windows_start
docker build -t nexusbot:local ./build_image_nexusbot/

# 4. 重啟 Pod 載入新 image
kubectl rollout restart deployment/nexusbot -n acenexus
kubectl rollout status deployment/nexusbot -n acenexus
```

---

### 情境三：改了 K8s YAML（Deployment / Service）

```bash
kubectl apply -f k8s/<service>/deployment.yaml -n acenexus
```

若只是調整 env var 或 resource limits，K8s 會自動觸發滾動更新。

---

### 情境四：更新 Secret

```bash
# 刪除舊的再重建
kubectl delete secret <secret-name> -n acenexus
kubectl create secret generic <secret-name> -n acenexus --from-literal=key=value ...

# 重啟使用該 Secret 的服務
kubectl rollout restart deployment/<service> -n acenexus
```

---

## 常用指令

### 查看狀態

```bash
kubectl get pods -n acenexus          # 所有 Pod 狀態
kubectl get pods -n acenexus -w       # 持續監看
kubectl get svc -n acenexus           # 所有 Service
kubectl get all -n acenexus           # 所有資源
```

### 查看 Log

```bash
kubectl logs -n acenexus deployment/<service>           # 最新 log
kubectl logs -n acenexus deployment/<service> -f        # 即時串流
kubectl logs -n acenexus deployment/<service> --tail=50 # 最後 50 行
```

### 偵錯

```bash
# 查看 Pod 詳細事件（啟動失敗時用）
kubectl describe pod -n acenexus -l app=<service>

# 進入容器執行指令
kubectl exec -it -n acenexus deployment/<service> -- sh
```

### 暫時開放內部 Service 到本機

```bash
kubectl port-forward svc/eurekaservice 8761:8761 -n acenexus   # Eureka 管理介面
kubectl port-forward svc/rabbitmq 15672:15672 -n acenexus      # RabbitMQ 管理介面
kubectl port-forward svc/configservice 8888:8888 -n acenexus   # Config Server
```
