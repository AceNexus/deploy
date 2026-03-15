# Grafana + Tempo — K8s 部署說明

Grafana 視覺化 UI，搭配 Tempo 做分散式追蹤查詢。
Tempo datasource 在 Grafana 啟動時自動佈建，無需手動設定。

## 部署

```bash
# Tempo 必須先啟動
kubectl apply -f k8s/tempo/

# 再部署 Grafana
kubectl apply -f k8s/grafana/

# 確認兩個 Pod 都是 Running 1/1
kubectl get pods -n acenexus
```

## 開啟 Grafana UI

`http://localhost:3000` — 匿名 Admin，無需登入。

## 開啟 / 關閉追蹤

預設追蹤關閉（`0.0`）。對任一服務執行以下指令即可切換，K8s 自動滾動重啟 Pod：

```bash
# 開啟
kubectl set env deployment/nexusbot TRACING_SAMPLING_PROBABILITY=1.0 -n acenexus

# 關閉（避免效能開銷）
kubectl set env deployment/nexusbot TRACING_SAMPLING_PROBABILITY=0.0 -n acenexus
```

## 查看 Trace

1. 開啟 `http://localhost:3000`
2. 左側選單 → **Explore** → 資料源選 **Tempo**
3. 查詢方式：
    - **Search** tab → Service Name 選 `nexusbot` → Run query
    - **TraceID** tab → 貼上 Log 裡的 8 字元 TraceId

## 暫時暴露到本機（測試用）

Grafana 已是 LoadBalancer，`localhost:3000` 直接可用。
Tempo 是 ClusterIP（僅集群內部），需 port-forward 才能從本機直接查詢 Tempo API：

```bash
kubectl port-forward svc/tempo 3200:3200 -n acenexus
```

開著這個終端機視窗期間，`http://localhost:3200` 可直接呼叫 Tempo API。

## 包含的 K8s 物件

| 物件         | 名稱                    | 說明                             |
|------------|-----------------------|--------------------------------|
| ConfigMap  | `grafana-datasources` | Tempo datasource 自動佈建設定        |
| Deployment | `grafana`             | Grafana 容器（port 3000）          |
| Service    | `grafana`             | LoadBalancer，對應 localhost:3000 |
