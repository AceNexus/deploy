# AceNexus K8s 部署指南

## 前置條件

- Docker Desktop 已啟動
- Docker Desktop → Settings → Kubernetes → Enable Kubernetes 已勾選

確認 K8s 正常運作：

```bash
kubectl get nodes
```

---

## 初始設定（只需執行一次）

### 建立 Namespace

Namespace 是 K8s 裡的資料夾，所有 AceNexus 的服務都放在 `acenexus` 裡。

```bash
kubectl create namespace acenexus
```

確認建立成功：應看到 acenexus Active，已存在的話會報錯 `already exists`，可以忽略。

```bash
kubectl get namespace
```

---

## 部署新服務的標準流程

每個服務的部署步驟都相同，只有設定內容不同。

### 步驟一：建立 build_image_{service}/ 目錄

放 Dockerfile 和 JAR 檔，專門用來 build image。

```
build_image_{service}/
├── Dockerfile
└── {service}.jar
```

範例（configservice）：

```bash
mkdir build_image_configservice
cp deploy_configservice/Dockerfile build_image_configservice/
cp deploy_configservice/configservice.jar build_image_configservice/
```

### 步驟二：建立 Secret

將敏感變數存入 K8s Secret，YAML 裡透過 `secretKeyRef` 引用。

```bash
kubectl create secret generic {service}-secret --namespace=acenexus --from-literal=key=value
```

確認建立成功：

```bash
kubectl get secret -n acenexus
```

若需要重建：

```bash
kubectl delete secret {service}-secret -n acenexus
```

### 步驟三：Build Image

```bash
docker build -t {service}:local ./build_image_{service}/
```

確認：

```bash
docker images
```

### 步驟四：建立 k8s/{service}/deployment.yaml

描述要跑哪些容器、環境變數、資源限制、健康檢查、依賴等待等。每個服務一個目錄：

```
k8s/
├── configservice/
│   └── deployment.yaml
├── eurekaservice/
│   └── deployment.yaml
└── ...
```

### 步驟五：套用 YAML

```bash
kubectl apply -f k8s/{service}/deployment.yaml
```

確認 Pod 狀態變成 `1/1 Running`：

```bash
kubectl get pods -n acenexus -w
```

---

## 常用指令

### 查看資源

查看所有 Pod：

```bash
kubectl get pods -n acenexus
```

查看所有 Service：

```bash
kubectl get svc -n acenexus
```

查看所有資源：

```bash
kubectl get all -n acenexus
```

持續監看：

```bash
kubectl get pods -n acenexus -w
```

### 查看詳細資訊與 Log

查看 Pod 詳細資訊（包含錯誤事件）：

```bash
kubectl describe pod <pod-name> -n acenexus
```

查看 Pod log：

```bash
kubectl logs <pod-name> -n acenexus
```

即時串流 log：

```bash
kubectl logs <pod-name> -n acenexus -f
```

只看最後 50 行：

```bash
kubectl logs <pod-name> -n acenexus --tail=50
```

### 部署 / 更新 / 刪除

套用 YAML（建立或更新）：

```bash
kubectl apply -f k8s/{service}/deployment.yaml
```

刪除 YAML 內的所有資源：

```bash
kubectl delete -f k8s/{service}/deployment.yaml
```

### 停止與恢復服務

停止服務（Pod 消失，Deployment 保留）：

```bash
kubectl scale deployment <service> --replicas=0 -n acenexus
```

恢復服務：

```bash
kubectl scale deployment <service> --replicas=1 -n acenexus
```

### 存取服務

將 K8s 內部 Service 暫時暴露到本機：

```bash
kubectl port-forward svc/<service> <local-port>:<service-port> -n acenexus
```
