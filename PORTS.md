# Port 使用清單

- 本文件記錄所有服務佔用的 Port，新增服務時請先確認無衝突。

## Port 清單 (依啟動順序排序)

| 服務                 | Port  | 協定   | 啟動方式                                        | 說明                               |
|:-------------------|:------|:-----|:--------------------------------------------|:---------------------------------|
| **Tempo**          | 3200  | HTTP | `kubectl apply -f k8s/tempo/`               | Tempo Trace 查詢 API               |
|                    | 4317  | gRPC | `kubectl apply -f k8s/tempo/`               | OTLP gRPC Receiver (服務送 trace 用) |
|                    | 4318  | HTTP | `kubectl apply -f k8s/tempo/`               | OTLP HTTP Receiver (服務送 trace 用) |
| **Grafana**        | 3000  | HTTP | `kubectl apply -f k8s/grafana/`             | Grafana 視覺化 UI                   |
| **configservice**  | 8888  | HTTP | `kubectl apply -f k8s/configservice/`       | Spring Cloud Config Server       |
|                    | 5672  | AMQP | `kubectl apply -f k8s/configservice/`       | RabbitMQ 訊息佇列 (Spring Cloud Bus) |
|                    | 15672 | HTTP | `kubectl apply -f k8s/configservice/`       | RabbitMQ 管理 UI                   |
| **eurekaservice**  | 8761  | HTTP | `kubectl apply -f k8s/eurekaservice/`       | 服務註冊中心 (Eureka)                  |
| **gatewayservice** | 8080  | HTTP | `kubectl apply -f k8s/gatewayservice/`      | API Gateway                      |
| **nexusbot**       | 5001  | HTTP | `kubectl apply -f k8s/nexusbot/`            | LINE Bot 主服務                     |
| **AIClient-2-API** | 3100  | HTTP | `start_deploy_aiclient.bat`       | AI Proxy Web UI (預設密碼: admin123) |
|                    | 1455  | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 8085  | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 8086  | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 8087  | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 19876 | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 19877 | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 19878 | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 19879 | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
|                    | 19880 | HTTP | `start_deploy_aiclient.bat`       | AI Proxy 內部服務 Port               |
| **ngrok**          | 4040  | HTTP | `ngrok-tunnel.bat`                | ngrok 本地管理 UI / API              |