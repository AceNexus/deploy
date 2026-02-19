@echo off
set DEPLOY_DIR=%~dp0deploy_configservice

echo [1/3] Stopping old containers...
docker stop deploy-rabbitmq-1 deploy-configservice-1 2>nul
docker rm deploy-rabbitmq-1 deploy-configservice-1 2>nul

echo [2/3] Building and starting services...
cd /d "%DEPLOY_DIR%"
docker compose up -d --build

echo [3/3] Checking health...
timeout /t 10 /nobreak >nul
curl -s http://localhost:8888/actuator/health

echo.
echo Done.
echo.
echo [4/4] Tailing configservice logs (Ctrl+C to stop)...
docker compose logs -f configservice
