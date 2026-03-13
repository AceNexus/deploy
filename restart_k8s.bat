@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ========================================
echo   AceNexus K8s 有序重啟腳本
echo ========================================
echo.
echo 必須按順序重啟，否則 Eureka registry 會遺失。
echo.

:: ── 步驟 1：configservice + rabbitmq ──────────────────────────
echo [1/3] 重啟 configservice + rabbitmq...
kubectl rollout restart deployment/configservice deployment/rabbitmq -n acenexus
kubectl rollout status deployment/configservice -n acenexus --timeout=120s
if %ERRORLEVEL% neq 0 goto :ERROR
kubectl rollout status deployment/rabbitmq -n acenexus --timeout=120s
if %ERRORLEVEL% neq 0 goto :ERROR
echo [OK] configservice + rabbitmq 就緒。
echo.

:: ── 步驟 2：eurekaservice ─────────────────────────────────────
echo [2/3] 重啟 eurekaservice...
kubectl rollout restart deployment/eurekaservice -n acenexus
kubectl rollout status deployment/eurekaservice -n acenexus --timeout=120s
if %ERRORLEVEL% neq 0 goto :ERROR
echo [OK] eurekaservice 就緒。
echo.

:: ── 步驟 3：gatewayservice + nexusbot ─────────────────────────
echo [3/3] 重啟 gatewayservice + nexusbot...
kubectl rollout restart deployment/gatewayservice deployment/nexusbot -n acenexus
kubectl rollout status deployment/gatewayservice -n acenexus --timeout=120s
if %ERRORLEVEL% neq 0 goto :ERROR
kubectl rollout status deployment/nexusbot -n acenexus --timeout=120s
if %ERRORLEVEL% neq 0 goto :ERROR
echo [OK] gatewayservice + nexusbot 就緒。
echo.

echo ========================================
echo   全部重啟完成！
echo ========================================
goto :EXIT

:ERROR
echo.
echo [錯誤] 重啟失敗，請執行以下指令查看詳情：
echo   kubectl get pods -n acenexus
echo   kubectl logs -n acenexus deployment/<service-name>
pause
exit /b 1

:EXIT
pause
exit /b 0
