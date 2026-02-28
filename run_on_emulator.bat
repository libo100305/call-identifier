@echo off
chcp 65001 >nul
echo ========================================
echo   Android 模拟器测试启动脚本
echo ========================================
echo.

echo [1/3] 检查可用的模拟器...
flutter emulators
echo.

echo [2/3] 启动模拟器...
echo ⏳ 模拟器启动需要 1-2 分钟...
flutter emulators --launch emulator-5554

echo.
echo [3/3] 等待模拟器完全启动...
timeout /t 30 /nobreak

echo.
echo ========================================
echo   开始运行应用
echo ========================================
flutter run

pause
