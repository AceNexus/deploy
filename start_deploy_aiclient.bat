@echo off
set CONTAINER_NAME=aiclient2api
set IMAGE_NAME=justlikemaki/aiclient-2-api
set CONFIGS_DIR=%~dp0configs_aiclient

echo [0/3] Stopping existing container '%CONTAINER_NAME%' if running...
docker stop %CONTAINER_NAME% >nul 2>&1
docker rm %CONTAINER_NAME% >nul 2>&1
echo Done.

echo [1/3] Ensuring configs directory exists: %CONFIGS_DIR%
if not exist "%CONFIGS_DIR%" mkdir "%CONFIGS_DIR%"

echo [2/3] Starting AIClient-2-API via Docker...
docker run -d ^
  -p 3000:3000 ^
  -p 8085-8087:8085-8087 ^
  -p 1455:1455 ^
  -p 19876-19880:19876-19880 ^
  --restart=always ^
  -v "%CONFIGS_DIR%:/app/configs" ^
  --name %CONTAINER_NAME% ^
  %IMAGE_NAME%

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to start container. Is Docker running?
    pause
    exit /b 1
)

echo [3/3] Container started. Web UI: http://localhost:3000  (default password: admin123)
echo Streaming logs (Ctrl+C to stop watching, container keeps running)...
echo.
docker logs -f %CONTAINER_NAME%
