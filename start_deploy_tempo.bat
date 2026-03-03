@echo off
set DEPLOY_DIR=%~dp0deploy_tempo

echo [1/4] Stopping old containers...
docker stop deploy_tempo-tempo-1 deploy_tempo-grafana-1 2>nul
docker rm deploy_tempo-tempo-1 deploy_tempo-grafana-1 2>nul

echo [2/4] Starting Tempo and Grafana...
cd /d "%DEPLOY_DIR%"
docker compose up -d

echo [3/4] Checking health...
timeout /t 15 /nobreak >nul
curl -s http://localhost:3200/ready

echo.
echo Done.
echo.
echo Tempo  : http://localhost:3200
echo Grafana: http://localhost:3000
echo.
echo [4/4] Tailing Tempo logs (Ctrl+C to stop)...
docker compose logs -f

echo.
pause
