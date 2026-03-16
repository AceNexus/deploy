# Port 使用清單

- 本文件記錄所有服務佔用的 Port，新增服務時請先確認無衝突。

## Port 清單 (依啟動順序排序)

> ClusterIP 欄位有指令的服務，無法直接從本機存取，需先執行該 `kubectl port-forward` 指令。

| 服務                 | Port  | 協定   | 啟動方式                                   | 說明                               | Port-Forward (ClusterIP)                                       |
|:-------------------|:------|:-----|:---------------------------------------|:---------------------------------|:---------------------------------------------------------------|
| **Tempo**          | 3200  | HTTP | `kubectl apply -f k8s/tempo/`          | Tempo Trace 查詢 API               | `kubectl port-forward svc/tempo 3200:3200 -n acenexus`         |
|                    | 4317  | gRPC | `kubectl apply -f k8s/tempo/`          | OTLP gRPC Receiver (服務送 trace 用) | `kubectl port-forward svc/tempo 4317:4317 -n acenexus`         |
|                    | 4318  | HTTP | `kubectl apply -f k8s/tempo/`          | OTLP HTTP Receiver (服務送 trace 用) | `kubectl port-forward svc/tempo 4318:4318 -n acenexus`         |
| **Grafana**        | 3000  | HTTP | `kubectl apply -f k8s/grafana/`        | Grafana 視覺化 UI                   | —（LoadBalancer，直接開 localhost:3000）                             |
| **configservice**  | 8888  | HTTP | `kubectl apply -f k8s/configservice/`  | Spring Cloud Config Server       | `kubectl port-forward svc/configservice 8888:8888 -n acenexus` |
|                    | 5672  | AMQP | `kubectl apply -f k8s/configservice/`  | RabbitMQ 訊息佇列 (Spring Cloud Bus) | `kubectl port-forward svc/rabbitmq 5672:5672 -n acenexus`      |
|                    | 15672 | HTTP | `kubectl apply -f k8s/configservice/`  | RabbitMQ 管理 UI                   | `kubectl port-forward svc/rabbitmq 15672:15672 -n acenexus`    |
| **eurekaservice**  | 8761  | HTTP | `kubectl apply -f k8s/eurekaservice/`  | 服務註冊中心 (Eureka)                  | `kubectl port-forward svc/eurekaservice 8761:8761 -n acenexus` |
| **gatewayservice** | 8080  | HTTP | `kubectl apply -f k8s/gatewayservice/` | API Gateway                      | —（LoadBalancer，直接開 localhost:8080）                             |
| **nexusbot**       | 5001  | HTTP | `kubectl apply -f k8s/nexusbot/`       | LINE Bot 主服務                     | —（LoadBalancer，直接開 localhost:5001）                             |
| **AIClient-2-API** | 3100  | HTTP | `start_deploy_aiclient.bat`            | AI Proxy Web UI (預設密碼: admin123) | —（Docker，直接開 localhost:3100）                                   |
|                    | 1455  | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 8085  | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 8086  | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 8087  | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 19876 | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 19877 | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 19878 | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 19879 | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
|                    | 19880 | HTTP | `start_deploy_aiclient.bat`            | AI Proxy 內部服務 Port               | —                                                              |
| **ngrok**          | 4040  | HTTP | `ngrok-tunnel.bat`                     | ngrok 本地管理 UI / API              | —（Docker，直接開 localhost:4040）                                   |
