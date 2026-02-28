@echo off
chcp 65001 >nul
echo ========================================
echo GitHub 推送与自动构建脚本
echo ========================================
echo.

REM 检查是否已配置远程仓库
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo 请在 GitHub 上创建仓库后，将仓库 URL 粘贴到下方
    echo 例如: https://github.com/你的用户名/call-identifier.git
    echo.
    set /p REPO_URL="请输入仓库 URL: "
    
    echo.
    echo 添加远程仓库...
    git remote add origin %REPO_URL%
)

REM 获取当前分支名称
for /f "tokens=*" %%a in ('git branch --show-current') do set BRANCH=%%a

echo.
echo 当前分支: %BRANCH%
echo.

REM 添加所有更改
echo 添加更改到暂存区...
git add .

REM 提交更改
echo.
set /p COMMIT_MSG="请输入提交说明（直接回车使用默认）: "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=更新应用代码

git commit -m "%COMMIT_MSG%"

REM 推送到 GitHub
echo.
echo 推送到 GitHub...
git push -u origin %BRANCH%

echo.
echo ========================================
echo 推送完成！
echo.
echo GitHub Actions 将自动开始构建 APK
echo.
echo 查看构建状态：
for /f "tokens=*" %%a in ('git remote get-url origin') do set REMOTE_URL=%%a
echo %REMOTE_URL%/actions
echo.
echo 构建完成后，你可以在以下位置下载 APK：
echo 1. Actions 页面 -^> 最新的工作流运行 -^> Artifacts
echo 2. Releases 页面（如果你创建了标签）
echo ========================================
pause
