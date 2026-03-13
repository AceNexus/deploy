# gatewayservice

## 包含的 K8s 物件

| 物件         | 名稱               | 說明                      |
|------------|------------------|-------------------------|
| Deployment | `gatewayservice` | API Gateway 容器          |
| Service    | `gatewayservice` | Gateway 網路入口（ClusterIP） |

---

## 部署步驟

### 步驟一：準備 build_image_gatewayservice/ 目錄

確認 `build_image_gatewayservice/` 已存在且包含 Dockerfile 與 JAR 檔。
若尚未建立，先執行 `./gradlew bootJar` 產生 JAR，再複製過來：

```bash
cp gatewayservice/build/libs/gatewayservice.jar build_image_gatewayservice/
```

### 步驟二：建立 Secret

將敏感變數存入 K8s Secret，YAML 裡透過 `secretKeyRef` 引用。

`jwt-secret` 需至少 32 bytes（256 bits）才符合 HMAC-SHA256 規範，請以下方指令產生：

```bash
openssl rand -base64 32
```

```bash
kubectl create secret generic gatewayservice-secret --namespace=acenexus --from-literal=security-username=admin --from-literal=security-password=password --from-literal=config-server-username=admin --from-literal=config-server-password=password --from-literal=rabbitmq-username=admin --from-literal=rabbitmq-password=password --from-literal=jwt-secret=<openssl rand -base64 32 產生的金鑰>
```

確認建立成功：

```bash
kubectl get secret -n acenexus
```

若需要重建：

```bash
kubectl delete secret gatewayservice-secret -n acenexus
```

### 步驟三：Build Image

```bash
docker build -t gatewayservice:local ./build_image_gatewayservice/
```

確認：

```bash
docker images
```

### 步驟四：套用 YAML

```bash
kubectl apply -f k8s/gatewayservice/deployment.yaml
```

確認 Pod 狀態變成 `1/1 Running`：

```bash
kubectl get pods -n acenexus -w
```

---

## 暫時暴露到本機（測試用）

```bash
kubectl port-forward svc/gatewayservice 8080:8080 -n acenexus
```
