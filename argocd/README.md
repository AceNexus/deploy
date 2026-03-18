# ArgoCD 安裝與設定

## 安裝 ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 等待所有 Pod 就緒
kubectl get pods -n argocd -w
```

---

## 存取 ArgoCD UI

```bash
kubectl port-forward svc/argocd-server 8090:443 -n argocd
```

瀏覽器開啟 https://localhost:8090

取得初始密碼：

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

帳號：`admin`，密碼為上方指令輸出的字串。

---

## 設定 GitHub deploy repo 存取（Private repo）

ArgoCD 需要能讀取 `AceNexus/deploy` repo 的內容。

```bash
argocd login localhost:8090 --insecure --username admin --password <初始密碼>

argocd repo add https://github.com/AceNexus/deploy.git \
  --username <GitHub帳號> \
  --password <DEPLOY_REPO_PAT>
```

---

## 建立 GHCR imagePullSecret

K8s 拉取 GHCR private image 需要 Secret：

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<GitHub帳號> \
  --docker-password=<DEPLOY_REPO_PAT> \
  -n acenexus
```

---

## 套用 ArgoCD Application

```bash
kubectl apply -f argocd/aiclient.yaml
kubectl apply -f argocd/configservice.yaml
kubectl apply -f argocd/eurekaservice.yaml
kubectl apply -f argocd/gatewayservice.yaml
kubectl apply -f argocd/nexusbot.yaml
```

確認 Application 狀態：

```bash
kubectl get application -n argocd
```

全部顯示 `Synced` + `Healthy` 即完成。

---

## 完整流程驗證

```
1. 在 source repo 改程式碼，merge to main
2. GitHub Actions CI 執行（build → scan → push GHCR → 更新 deploy repo image tag）
3. ArgoCD 輪詢 deploy repo（每 3 分鐘）偵測到 image tag 變動
4. ArgoCD 自動 kubectl apply → K8s 滾動更新
5. ArgoCD UI 顯示 Synced + Healthy
```

---

## 回滾

```bash
# 方式一：ArgoCD UI → 選服務 → History → 點選舊版本 → Rollback
# 方式二：git revert deploy repo 的 commit → ArgoCD 自動同步
```
