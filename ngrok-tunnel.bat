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
echo [提示] 正在進入監控模式 (按 Ctrl+C 退出)...
echo ----------------------------------------
docker compose logs -f ngrok
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
