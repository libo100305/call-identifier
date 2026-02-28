@echo off
echo ========================================
echo 禁用 jlink 工具以解决 Flutter 打包问题
echo ========================================
echo.
echo 正在检查 jlink.exe...
if exist "C:\Program Files\Android\Android Studio\jbr\bin\jlink.exe" (
    echo 发现 jlink.exe
    echo 正在尝试重命名...
    ren "C:\Program Files\Android\Android Studio\jbr\bin\jlink.exe" "jlink.exe.disabled"
    if errorlevel 1 (
        echo.
        echo 需要管理员权限！
        echo 请右键点击此文件，选择"以管理员身份运行"
    ) else (
        echo.
        echo 成功禁用 jlink.exe！
        echo 文件已重命名为: jlink.exe.disabled
    )
) else (
    echo 未找到 jlink.exe
    echo 路径: C:\Program Files\Android\Android Studio\jbr\bin\jlink.exe
)

echo.
pause
