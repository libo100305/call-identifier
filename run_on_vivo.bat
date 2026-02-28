@echo off
chcp 65001 >nul
echo ========================================
echo   Vivo 手机测试启动脚本
echo ========================================
echo.

echo [1/4] 检查设备连接...
flutter devices
if %errorlevel% neq 0 (
    echo ❌ 未检测到设备，请检查 USB 连接
    pause
    exit /b 1
)

echo.
echo [2/4] 检查依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 依赖检查失败
    pause
    exit /b 1
)

echo.
echo [3/4] 开始编译...
echo ⏳ 首次运行需要 3-5 分钟，请耐心等待...
echo.

echo [4/4] 运行应用到手机...
flutter run

if %errorlevel% equ 0 (
    echo.
    echo ✅ 应用已成功启动！
    echo.
    echo 提示：
    echo - 按 R 键热重载（修改代码后）
    echo - 按 Q 键退出
    echo - 查看控制台输出了解应用运行状态
) else (
    echo.
    echo ❌ 运行失败，请检查错误信息
)

echo.
pause
