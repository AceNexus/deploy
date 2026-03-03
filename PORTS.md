# Port 使用清單

- 本文件記錄所有服務佔用的 Port，新增服務時請先確認無衝突。

## Port 清單 (依啟動腳本順序排序)

| 服務                 | Port  | 協定   | 啟動腳本                              | 說明                               |
|:-------------------|:------|:-----|:----------------------------------|:---------------------------------|
| **Tempo**          | 3000  | HTTP | `start_deploy_tempo.bat`          | Grafana 視覺化 UI                   |
|                    | 3200  | HTTP | `start_deploy_tempo.bat`          | Tempo Trace 查詢 API               |
|                    | 4317  | gRPC | `start_deploy_tempo.bat`          | OTLP gRPC Receiver (服務送 trace 用) |
|                    | 4318  | HTTP | `start_deploy_tempo.bat`          | OTLP HTTP Receiver (服務送 trace 用) |
| **configservice**  | 8888  | HTTP | `start_deploy_configservice.bat`  | Spring Cloud Config Server       |
|                    | 5672  | AMQP | `start_deploy_configservice.bat`  | RabbitMQ 訊息佇列 (Spring Cloud Bus) |
|                    | 15672 | HTTP | `start_deploy_configservice.bat`  | RabbitMQ 管理 UI                   |
| **eurekaservice**  | 8761  | HTTP | `start_deploy_eurekaservice.bat`  | 服務註冊中心 (Eureka)                  |
| **gatewayservice** | 8080  | HTTP | `start_deploy_gatewayservice.bat` | API Gateway                      |
| **nexusbot**       | 5001  | HTTP | `start_deploy_nexusbot.bat`       | LINE Bot 主服務                     |
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