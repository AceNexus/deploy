@echo off
set DEPLOY_DIR=%~dp0deploy_nexusbot
set NEXUSBOT_DIR=%~dp0..\nexusbot

echo [1/5] Waiting for Config Server to be accessible...
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

echo [2/5] Waiting for Eureka Server to be accessible...
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

echo [3/5] Building nexusbot JAR...
cd /d "%NEXUSBOT_DIR%"
call gradlew.bat bootJar
if errorlevel 1 (
    echo [ERROR] JAR 編譯失敗
    pause
    exit /b 1
)

set JAR_FILE=
for %%f in ("%NEXUSBOT_DIR%\build\libs\nexusbot-*.jar") do set JAR_FILE=%%f
if "%JAR_FILE%"=="" (
    echo [ERROR] 找不到編譯產出的 JAR 檔案
    pause
    exit /b 1
)
echo 複製 JAR: %JAR_FILE%
copy /Y "%JAR_FILE%" "%DEPLOY_DIR%\nexusbot.jar" >nul

echo [4/5] Deploying nexusbot container...
cd /d "%DEPLOY_DIR%"
docker compose down
docker compose up -d --build

echo [5/5] Checking health...
timeout /t 30 /nobreak >nul
curl -s http://localhost:5001/actuator/health

echo.
echo Done.
echo.
echo [Tailing] nexusbot logs (Ctrl+C to stop)...
docker compose logs -f nexusbot
