@echo off
set DEPLOY_DIR=%~dp0deploy_nexusbot

:: 從 .env 讀取 SERVER_PORT（預設 5001）
set SERVER_PORT=5001
for /f "usebackq eol=# tokens=1* delims==" %%a in ("%DEPLOY_DIR%\.env") do (
    if /i "%%a"=="SERVER_PORT" set "SERVER_PORT=%%b"
)

echo [1/6] Waiting for Config Server to be accessible...
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

echo [2/6] Waiting for Eureka Server to be accessible...
set RETRY=0
:WAIT_EUREKA
curl -f -s --max-time 5 -u admin:password http://localhost:8761/actuator/health >nul 2>&1
if errorlevel 1 (
    set /a RETRY+=1
    if %RETRY% geq 30 (
        echo [ERROR] Eureka Server 等待逾時，請確認 eurekaservice 是否正常執行
        pause
        exit /b 1
    )
    echo 等待 Eureka Server 啟動中... [%RETRY%/30]
    timeout /t 10 /nobreak >nul
    goto WAIT_EUREKA
)
echo Eureka Server OK.

echo [3/6] Stopping old containers...
cd /d "%DEPLOY_DIR%"
docker compose down

echo [4/6] Building and starting services...
docker compose up -d --build

echo [5/6] Waiting for nexusbot to be healthy...
set RETRY=0
:WAIT_NEXUSBOT
curl -f -s --max-time 5 http://localhost:%SERVER_PORT%/actuator/health >nul 2>&1
if errorlevel 1 (
    set /a RETRY+=1
    if %RETRY% geq 30 (
        echo [ERROR] nexusbot 健康檢查逾時，請確認服務是否正常執行
        echo [INFO]  可執行以下指令查看日誌: docker compose logs nexusbot
        pause
        exit /b 1
    )
    echo 等待 nexusbot 啟動中... [%RETRY%/30]
    timeout /t 10 /nobreak >nul
    goto WAIT_NEXUSBOT
)
echo nexusbot OK.

echo [6/6] Health status:
curl -s http://localhost:%SERVER_PORT%/actuator/health

echo.
echo Done.
echo.
echo [Tailing] nexusbot logs (Ctrl+C to stop)...
docker compose logs -f nexusbot
