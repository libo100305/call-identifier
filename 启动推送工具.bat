@echo off
chcp 65001 >nul
cls
echo ================================================================
echo        GitHub 自动推送工具 - 启动中...
echo ================================================================
echo.

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Python，请先安装 Python
    echo.
    echo 下载地址: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo [信息] 正在启动本地服务器...
echo.

REM Start the Python server
python "%~dp0git-server.py"

pause
