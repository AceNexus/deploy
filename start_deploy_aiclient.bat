@echo off
set AICLIENT_DIR=%~dp0..\AIClient-2-API

echo [1/2] Starting AIClient-2-API...
cd /d "%AICLIENT_DIR%"

echo [2/2] Running npm start...
npm start
