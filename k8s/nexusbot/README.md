# nexusbot

## 包含的 K8s 物件

| 物件         | 名稱         | 說明                       |
|------------|------------|--------------------------|
| Deployment | `nexusbot` | NexusBot 主應用容器（Java 17）  |
| Service    | `nexusbot` | NexusBot 網路入口（ClusterIP） |

---

## 部署步驟

### 步驟一：準備 build_image_nexusbot/ 目錄

確認 `build_image_nexusbot/` 已存在且包含 Dockerfile 與 JAR 檔。
若尚未建立，先執行 `./gradlew bootJar` 產生 JAR，再複製過來：

```bash
cp nexusbot/build/libs/nexusbot.jar build_image_nexusbot/
```

### 步驟二：建立 Secret

將敏感變數存入 K8s Secret，YAML 裡透過 `secretKeyRef` 引用。

```bash
kubectl create secret generic nexusbot-secret --namespace=acenexus --from-literal=config-server-username=admin --from-literal=config-server-password=password --from-literal=mysql-username=<MySQL帳號> --from-literal=mysql-password=<MySQL密碼> --from-literal=rabbitmq-username=admin --from-literal=rabbitmq-password=password --from-literal=line-bot-channel-token=<LINE_BOT_CHANNEL_TOKEN> --from-literal=line-bot-channel-secret=<LINE_BOT_CHANNEL_SECRET> --from-literal=groq-api-key=<GROQ_API_KEY> --from-literal=email-username=<Email帳號> --from-literal=email-password=<Email應用程式密碼> --from-literal=admin-password-seed=<密碼種子> --from-literal=gemini-proxy-api-key=<Gemini_Proxy_API_Key>
```

確認建立成功：

```bash
kubectl get secret -n acenexus
```

若需要重建：

```bash
kubectl delete secret nexusbot-secret -n acenexus
```

### 步驟三：Build Image

```bash
docker build -t nexusbot:local ./build_image_nexusbot/
```

確認：

```bash
docker images
```

### 步驟四：套用 YAML

```bash
kubectl apply -f k8s/nexusbot/deployment.yaml
```

確認 Pod 狀態變成 `1/1 Running`：

```bash
kubectl get pods -n acenexus -w
```

---

## NEXUSBOT_BASE_URL 更新

nexusbot 需要知道自己的對外 URL（ngrok 啟動後取得），可用以下指令動態更新：

```bash
kubectl set env deployment/nexusbot NEXUSBOT_BASE_URL=https://xxxx.ngrok-free.app -n acenexus
```

---

## 暫時暴露到本機（測試用）

```bash
kubectl port-forward svc/nexusbot 5001:5001 -n acenexus
```
