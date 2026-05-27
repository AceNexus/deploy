@echo off
setlocal

:: Fetch ArgoCD admin password dynamically
set "ARGOPW=password"
for /f "usebackq tokens=*" %%i in (`powershell -Command "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }" 2^>nul`) do set "ARGOPW=%%i"

echo ========================================
echo   ArgoCD UI
echo ========================================
echo   URL  : https://localhost:9090
echo   User : admin
echo   Pass : %ARGOPW%
echo ========================================
echo.
echo Opening browser...
start https://localhost:9090
echo Starting port-forward  (Ctrl+C to stop)
echo.

:loop
kubectl port-forward svc/argocd-server 9090:443 -n argocd
echo.
echo [argocd] Port-forward ended. Reconnecting in 3s...
timeout /t 3 /nobreak >nul
goto loop
