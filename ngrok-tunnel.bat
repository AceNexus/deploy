@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "DEPLOY_DIR=%~dp0deploy_ngrok"

echo [資訊] 正在清理環境...
taskkill /f /im ngrok.exe >nul 2>&1

if not exist "%DEPLOY_DIR%\.env" (
    echo [錯誤] 找不到 .env 檔案！
    pause
    exit /b 1
)

pushd "%DEPLOY_DIR%"

:: 從 .env 讀取 LINE Bot 設定
for /f "usebackq eol=# tokens=1* delims==" %%a in ("%DEPLOY_DIR%\.env") do (
    if /i "%%a"=="LINE_CHANNEL_ACCESS_TOKEN"      set "LINE_TOKEN=%%b"
    if /i "%%a"=="LINE_WEBHOOK_PATH"              set "LINE_WEBHOOK_PATH=%%b"
    if /i "%%a"=="LINE_CHANNEL_ACCESS_TOKEN_TEST" set "LINE_TOKEN_TEST=%%b"
    if /i "%%a"=="LINE_WEBHOOK_PATH_TEST"         set "LINE_WEBHOOK_PATH_TEST=%%b"
)
if "!LINE_WEBHOOK_PATH!"==""      set "LINE_WEBHOOK_PATH=/api/linebot/webhook"
if "!LINE_WEBHOOK_PATH_TEST!"=="" set "LINE_WEBHOOK_PATH_TEST=/api/linebot-test/webhook"

echo [資訊] 正在啟動 ngrok 容器...
docker compose down >nul 2>&1
docker compose up -d --force-recreate

echo [資訊] 正在等待 ngrok 啟動...
timeout /t 5 /nobreak >nul

:: 檢查是否有連線數已滿的錯誤
docker compose logs ngrok --tail 20 | findstr "ERR_NGROK_108" >nul
if %ERRORLEVEL% equ 0 goto :ERROR_108

:: 從 ngrok 本地 API 取得動態網址
set "FINAL_URL="
for /f "delims=" %%a in ('powershell -Command "(Invoke-WebRequest -Uri 'http://localhost:4040/api/tunnels' -UseBasicParsing | ConvertFrom-Json).tunnels[0].public_url" 2^>nul') do set "FINAL_URL=%%a"

if "!FINAL_URL!"=="" (
    echo [錯誤] 無法取得 ngrok 網址，正在重試...
    timeout /t 5 /nobreak >nul
    for /f "delims=" %%a in ('powershell -Command "(Invoke-WebRequest -Uri 'http://localhost:4040/api/tunnels' -UseBasicParsing | ConvertFrom-Json).tunnels[0].public_url" 2^>nul') do set "FINAL_URL=%%a"
)

if "!FINAL_URL!"=="" (
    echo [錯誤] 無法取得 ngrok 網址，請確認容器是否正常啟動。
    docker compose logs ngrok --tail 30
    goto :EXIT_ERROR
)

echo.
echo ========================================
echo   ngrok 啟動成功！
echo ========================================
echo   您的網址： !FINAL_URL!
echo ========================================
echo.

echo !FINAL_URL! | clip
echo [成功] 網址已複製到剪貼簿。

:: 更新 nexusbot NEXUSBOT_BASE_URL（K8s）
echo [資訊] 正在更新 nexusbot NEXUSBOT_BASE_URL（K8s）...
kubectl set env deployment/nexusbot NEXUSBOT_BASE_URL=!FINAL_URL! -n acenexus
if %ERRORLEVEL% equ 0 (
    echo [成功] nexusbot NEXUSBOT_BASE_URL 已更新，K8s 將自動滾動重啟 Pod。
) else (
    echo [警告] kubectl set env 失敗，請確認 K8s 叢集是否正常運行。
)

:: 更新 LINE Bot 1 Webhook（nexusbot :5001）
if "!LINE_TOKEN!"=="" goto :SKIP_LINE1
if "!LINE_TOKEN!"=="your_line_channel_access_token_here" goto :SKIP_LINE1

echo [資訊] 正在更新 LINE Bot 1 Webhook...
set "TEMP_LINE_TOKEN=!LINE_TOKEN!"
set "TEMP_WEBHOOK_URL=!FINAL_URL!!LINE_WEBHOOK_PATH!"
powershell -ExecutionPolicy Bypass -File "%DEPLOY_DIR%\update_webhook.ps1"
goto :UPDATE_BOT2

:SKIP_LINE1
echo [提示] 未設定 LINE_CHANNEL_ACCESS_TOKEN，跳過 Bot 1 Webhook 更新。

:UPDATE_BOT2
:: 更新 LINE Bot 2 Webhook（test bot，同樣透過 gateway :8080 → /api/linebot-test/webhook）
if "!LINE_TOKEN_TEST!"=="" goto :SKIP_LINE2
if "!LINE_TOKEN_TEST!"=="your_test_bot_line_channel_access_token_here" goto :SKIP_LINE2

echo [資訊] 正在更新 LINE Bot 2 (test) Webhook...
set "TEMP_LINE_TOKEN=!LINE_TOKEN_TEST!"
set "TEMP_WEBHOOK_URL=!FINAL_URL!!LINE_WEBHOOK_PATH_TEST!"
powershell -ExecutionPolicy Bypass -File "%DEPLOY_DIR%\update_webhook.ps1"
goto :MONITOR

:SKIP_LINE2
echo [提示] 未設定 LINE_CHANNEL_ACCESS_TOKEN_TEST，跳過 Bot 2 Webhook 更新。

:MONITOR
echo ----------------------------------------
docker compose logs ngrok --tail 30
echo ----------------------------------------
echo.
echo   完整資訊與流量監控請至：
echo   http://localhost:4040/
echo.
goto :EXIT

:ERROR_108
echo.
echo ----------------------------------------
echo [警告] 偵測到 ERR_NGROK_108 (連線數已滿)
echo ----------------------------------------
echo 原因：ngrok 伺服器端認為您還有另一個連線。
echo 解決方法：
echo 1. 請等待 5 分鐘讓伺服器自動斷開舊連線。
echo 2. 或至 https://dashboard.ngrok.com/agents 手動檢查。
echo ----------------------------------------
docker compose down >nul 2>&1
goto :EXIT_ERROR

:EXIT_ERROR
popd
pause
exit /b 1

:EXIT
popd
pause
exit /b 0
