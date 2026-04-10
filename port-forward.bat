@echo off
setlocal

if not "%~1"=="" goto watch_mode

:: ---------- Main mode -------------------------------------------------------
echo ========================================
echo   AceNexus Services
echo ========================================
echo.
echo   configservice    Config Server + RabbitMQ Bus
echo     http://localhost:8888/actuator/health
echo     http://localhost:15672  (RabbitMQ Management UI)
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
echo   aiclient         AI Proxy - Gemini/Claude/Qwen (default pw: admin123)
echo     http://localhost:3100
echo.
echo   phpmyadmin       MySQL Web UI (user: root / pw: password)
echo     http://localhost:8081
echo.
echo   grafana          Observability dashboard + Tempo tracing backend
echo     http://localhost:3000  (view distributed traces here)
echo     Tempo: API only - no UI, view traces via Grafana above
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

set "SELF=%~f0"

wt new-tab --title "configservice" cmd /k "%SELF% configservice 8888:8888 acenexus" ^; new-tab --title "eurekaservice" cmd /k "%SELF% eurekaservice 8761:8761 acenexus" ^; new-tab --title "rabbitmq" cmd /k "%SELF% rabbitmq 15672:15672 acenexus" ^; new-tab --title "tempo" cmd /k "%SELF% tempo 3200:3200 acenexus" ^; new-tab --title "argocd" cmd /k "%SELF% argocd-server 9090:443 argocd"

echo Done. To stop: close the corresponding tab.
echo.
pause
goto :eof

:: ---------- Watch mode (called internally by each tab) ----------------------
:watch_mode
set "NAME=%~1"
set "PORTS=%~2"
set "NS=%~3"

:watch_loop
echo [%NAME%] Waiting for deployment to be available...
kubectl rollout status deployment/%NAME% -n %NS% --timeout=300s 2>nul
if %ERRORLEVEL% neq 0 (
    echo [%NAME%] Deployment not ready or not found, retrying in 5s...
    timeout /t 5 /nobreak >nul
    goto watch_loop
)
echo [%NAME%] Starting port-forward %PORTS%...
kubectl port-forward svc/%NAME% %PORTS% -n %NS%
echo.
echo [%NAME%] Port-forward ended. Reconnecting in 3s...
timeout /t 3 /nobreak >nul
goto watch_loop
