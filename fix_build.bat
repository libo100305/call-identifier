@echo off
echo ========================================
echo Flutter APK 打包问题解决方案
echo ========================================
echo.

echo 步骤 1: 创建 Gradle 初始化脚本...
echo 将在 C:\Users\admin\.gradle\ 目录下创建 init.gradle 文件
echo.

if not exist "C:\Users\admin\.gradle" (
    mkdir "C:\Users\admin\.gradle"
    echo 已创建 C:\Users\admin\.gradle 目录
)

echo.
echo 创建 init.gradle 文件...
echo.

echo gradle.projectsEvaluated { > "C:\Users\admin\.gradle\init.gradle"
echo     tasks.withType(JavaCompile).configureEach { >> "C:\Users\admin\.gradle\init.gradle"
echo         options.fork = true >> "C:\Users\admin\.gradle\init.gradle"
echo         options.forkOptions.jvmArgs = [ >> "C:\Users\admin\.gradle\init.gradle"
echo             '-Dorg.gradle.internal.native.jni.disabled=true', >> "C:\Users\admin\.gradle\init.gradle"
echo             '-Dandroid.enableJLink=false', >> "C:\Users\admin\.gradle\init.gradle"
echo             '-Dandroid.disableJLinkTransform=true' >> "C:\Users\admin\.gradle\init.gradle"
echo         ] >> "C:\Users\admin\.gradle\init.gradle"
echo     } >> "C:\Users\admin\.gradle\init.gradle"
echo } >> "C:\Users\admin\.gradle\init.gradle"

if exist "C:\Users\admin\.gradle\init.gradle" (
    echo 成功创建 C:\Users\admin\.gradle\init.gradle
    echo.
    echo 文件内容：
    type "C:\Users\admin\.gradle\init.gradle"
    echo.
) else (
    echo 创建失败！
    echo 请以管理员身份运行此脚本
    pause
    exit /b 1
)

echo ========================================
echo 步骤 2: 清理构建缓存...
echo.
cd /d "C:\Users\admin\Desktop\xmwj\dianhua"
flutter clean
echo 清理完成
echo.

echo ========================================
echo 步骤 3: 重新构建
echo.
flutter pub get
flutter build apk --debug

echo.
echo ========================================
echo 构建完成！
echo ========================================
pause
