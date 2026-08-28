@echo off
setlocal
chcp 65001 >nul

REM Start (or reuse) the ngrok tunnels and sync nexusbot + LINE webhooks.
REM
REM The real logic lives in deploy_ngrok\sync_tunnels.ps1 -- see that file for
REM the reasoning (in Chinese). This wrapper only decides "boot mode" and
REM "whether to keep the window open".
REM
REM Usage:
REM   ngrok-tunnel.bat           manual run; stops at pause when finished
REM   ngrok-tunnel.bat --boot    boot mode; waits for Docker/K8s, no pause
REM                              (the Startup folder shortcut passes this)
REM
REM IMPORTANT: keep this file pure ASCII. cmd re-reads a batch file with the
REM codepage set by chcp; with UTF-8 multi-byte comments the parser loses its
REM byte offset and starts executing fragments of comment lines -- the symptom
REM is "'ershell' is not recognized" and the powershell call never runs.
REM Chinese belongs in the .ps1 files, which PowerShell decodes correctly.
REM
REM Author: MinHao
REM History:
REM     2026-08-25 MinHao delegate to sync_tunnels.ps1; add --boot

set "BOOT_ARG="
if /i "%~1"=="--boot" set "BOOT_ARG=-Boot"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy_ngrok\sync_tunnels.ps1" %BOOT_ARG%
set "RC=%ERRORLEVEL%"

REM Boot mode does not pause: nobody closes that window, and the URLs have
REM already been delivered as a Windows notification.
if not defined BOOT_ARG pause
exit /b %RC%
