# configservice + RabbitMQ

## 包含的 K8s 物件

| 物件                    | 名稱                  | 說明                              |
|-----------------------|---------------------|---------------------------------|
| PersistentVolumeClaim | `rabbitmq-data-pvc` | RabbitMQ 資料持久化                  |
| Deployment            | `rabbitmq`          | RabbitMQ 容器                     |
| Service               | `rabbitmq`          | RabbitMQ 內部網路入口（ClusterIP）      |
| Deployment            | `configservice`     | Config Server 容器                |
| Service               | `configservice`     | Config Server 內部網路入口（ClusterIP） |

---

## 部署步驟

### 步驟一：建立 build_image_configservice/ 目錄

放 Dockerfile 和 JAR 檔，專門用來 build image。

```bash
mkdir build_image_configservice
cp deploy_configservice/Dockerfile build_image_configservice/
cp deploy_configservice/configservice.jar build_image_configservice/
```

### 步驟二：建立 Secret

將敏感變數存入 K8s Secret，YAML 裡透過 `secretKeyRef` 引用。

```bash
kubectl create secret generic configservice-secret --namespace=acenexus --from-literal=security-username=<帳號> --from-literal=security-password=<密碼> --from-literal=encrypt-key=<加密金鑰> --from-literal=rabbitmq-user=<RabbitMQ帳號> --from-literal=rabbitmq-pass=<RabbitMQ密碼>
```

確認建立成功：

```bash
kubectl get secret -n acenexus
```

若需要重建：

```bash
kubectl delete secret configservice-secret -n acenexus
```

### 步驟三：Build Image

```bash
docker build -t configservice:local ./build_image_configservice/
```

確認：

```bash
docker images
```

### 步驟四：套用 YAML

```bash
kubectl apply -f k8s/configservice/deployment.yaml
```

確認 Pod 狀態變成 `1/1 Running`：

```bash
kubectl get pods -n acenexus -w
```

---

## 暫時暴露到本機（測試用）

```bash
kubectl port-forward svc/configservice 8888:8888 -n acenexus
```

```bash
kubectl port-forward svc/rabbitmq 15672:15672 -n acenexus
```
