# eurekaservice

## 包含的 K8s 物件

| 物件         | 名稱              | 說明                                 |
|------------|-----------------|------------------------------------|
| Deployment | `eurekaservice` | Eureka Server 容器                   |
| Service    | `eurekaservice` | Eureka Server 內部網路入口（ClusterIP） |

---

## 部署步驟

### 步驟一：建立 build_image_eurekaservice/ 目錄

放 Dockerfile 和 JAR 檔，專門用來 build image。

```bash
mkdir build_image_eurekaservice
cp deploy_eurekaservice/Dockerfile build_image_eurekaservice/
cp deploy_eurekaservice/eurekaservice.jar build_image_eurekaservice/
```

### 步驟二：建立 Secret

將敏感變數存入 K8s Secret，YAML 裡透過 `secretKeyRef` 引用。

```bash
kubectl create secret generic eurekaservice-secret --namespace=acenexus --from-literal=security-username=<帳號> --from-literal=security-password=<密碼> --from-literal=config-server-username=<configservice帳號> --from-literal=config-server-password=<configservice密碼> --from-literal=rabbitmq-username=<RabbitMQ帳號> --from-literal=rabbitmq-password=<RabbitMQ密碼>
```

確認建立成功：

```bash
kubectl get secret -n acenexus
```

若需要重建：

```bash
kubectl delete secret eurekaservice-secret -n acenexus
```

### 步驟三：Build Image

```bash
docker build -t eurekaservice:local ./build_image_eurekaservice/
```

確認：

```bash
docker images
```

### 步驟四：套用 YAML

```bash
kubectl apply -f k8s/eurekaservice/deployment.yaml
```

確認 Pod 狀態變成 `1/1 Running`：

```bash
kubectl get pods -n acenexus -w
```

---

## 暫時暴露到本機（測試用）

```bash
kubectl port-forward svc/eurekaservice 8761:8761 -n acenexus
```
