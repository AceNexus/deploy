@echo off
setlocal
chcp 65001 >nul

REM Show the current ngrok URLs and whether LINE webhook / nexusbot agree.
REM Read-only; safe to double-click at any time.
REM Logic lives in deploy_ngrok\status.ps1.
REM
REM Keep this file pure ASCII -- see the note in ngrok-tunnel.bat.
REM
REM Author: MinHao
REM History:
REM     2026-08-25 MinHao initial version

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy_ngrok\status.ps1"
set "RC=%ERRORLEVEL%"

pause
exit /b %RC%
