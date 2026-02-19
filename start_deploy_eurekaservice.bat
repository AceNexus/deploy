@echo off
set DEPLOY_DIR=%~dp0deploy_eurekaservice

echo [1/4] Waiting for Config Server to be accessible...
set RETRY=0
:WAIT_CONFIG
curl -f -s --max-time 5 -u admin:password http://localhost:8888/actuator/health >nul 2>&1
if errorlevel 1 (
    set /a RETRY+=1
    if %RETRY% geq 30 (
        echo [ERROR] Config Server 等待逾時，請確認 configservice 是否正常執行
        pause
        exit /b 1
    )
    echo 等待 Config Server 啟動中... [%RETRY%/30]
    timeout /t 10 /nobreak >nul
    goto WAIT_CONFIG
)
echo Config Server OK.

echo [2/4] Stopping old containers...
cd /d "%DEPLOY_DIR%"
docker compose down

echo [3/4] Building and starting services...
docker compose up -d --build

echo [4/4] Checking health...
timeout /t 15 /nobreak >nul
curl -s -u admin:password http://localhost:8761/actuator/health

echo.
echo Done.
echo.
echo [Tailing] eurekaservice logs (Ctrl+C to stop)...
docker compose logs -f eurekaservice
