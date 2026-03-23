@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   AceNexus Services
echo ========================================
echo.
echo   configservice    Config Server + RabbitMQ Bus
echo     http://localhost:8888/actuator/health
echo.
echo   eurekaservice    Service Registry (Eureka Dashboard)
echo     http://localhost:8761
echo.
echo   gatewayservice   API Gateway (JWT auth, request logging)
echo     http://localhost:8080/actuator/health
echo.
echo   nexusbot         LINE Bot main service (AI, reminders)
echo     http://localhost:5001/actuator/health
echo.
echo   rabbitmq         Message Queue Management UI
echo     http://localhost:15672
echo.
echo   aiclient         AI Proxy - Gemini/Claude/Qwen (default pw: admin123)
echo     http://localhost:3100
echo.
echo   grafana          Observability dashboard - view distributed traces here
echo     http://localhost:3000
echo.
echo   tempo            Distributed tracing backend (Grafana datasource)
echo     API only - no UI, view traces via Grafana above
echo.
echo   argocd           GitOps CD platform (user: admin / pw: password)
echo     https://localhost:9090
echo.
echo   ngrok            HTTPS tunnel to LINE webhook
echo     http://localhost:4040  - run ngrok-tunnel.bat separately
echo.
echo ========================================
echo   Starting port-forwards...
echo ========================================
echo.

wt new-tab --title "configservice" cmd /k kubectl port-forward svc/configservice 8888:8888 -n acenexus ^; new-tab --title "eurekaservice" cmd /k kubectl port-forward svc/eurekaservice 8761:8761 -n acenexus ^; new-tab --title "rabbitmq" cmd /k kubectl port-forward svc/rabbitmq 15672:15672 -n acenexus ^; new-tab --title "tempo" cmd /k kubectl port-forward svc/tempo 3200:3200 -n acenexus ^; new-tab --title "argocd" cmd /k kubectl port-forward svc/argocd-server 9090:443 -n argocd

echo Done. To stop: close the corresponding tab.
echo.
pause
