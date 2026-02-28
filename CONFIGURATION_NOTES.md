# Flutter 项目配置

## 问题诊断

**错误信息：**
```
Error while executing process C:\Program Files\Android\Android Studio\jbr\bin\jlink.exe
```

**根本原因：**
Android Studio 自带的 JBR 21 JDK 中的 jlink 工具与 Flutter 插件不兼容。

## 解决方案

### 方法 1：设置环境变量（推荐）

在 PowerShell 中运行以下命令：

```powershell
# 设置环境变量禁用 jlink
[Environment]::SetEnvironmentVariable("GRADLE_OPTS", "-Dorg.gradle.internal.native.jni.disabled=true -Dandroid.enableJLink=false", "User")
[Environment]::SetEnvironmentVariable("JAVA_OPTS", "-Dorg.gradle.internal.native.jni.disabled=true", "User")
```

然后**重启 PowerShell**，再运行：
```powershell
cd c:\Users\admin\Desktop\xmwj\dianhua
flutter build apk --debug
```

### 方法 2：降级到 Android SDK 33

修改 `android/app/build.gradle`：
```gradle
android {
    compileSdk = 33
    // ...
    targetSdk = 33
}
```

但这样会警告某些插件需要 SDK 34。

### 方法 3：安装 JDK 17（最彻底）

1. 下载 JDK 17：https://adoptium.net/teapot/
2. 设置 JAVA_HOME：
   ```powershell
   [Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "Machine")
   ```
3. 配置 Flutter：
   ```powershell
   flutter config --java-home="C:\Program Files\Java\jdk-17"
   ```

## 当前配置

- compileSdk: 34
- targetSdk: 34
- minSdk: 21
- camera 插件: 已启用

## 推荐操作

先尝试**方法 1**（设置环境变量），如果不行再用**方法 3**（安装 JDK 17）。
