# 创建 Gradle 初始化脚本
$gradleDir = "C:\Users\admin\.gradle"
if (-not (Test-Path $gradleDir)) {
    New-Item -ItemType Directory -Path $gradleDir | Out-Null
}

$initScript = @'
gradle.projectsEvaluated {
    tasks.withType(JavaCompile).configureEach {
        options.fork = true
        options.forkOptions.jvmArgs = [
            '-Dorg.gradle.internal.native.jni.disabled=true',
            '-Dandroid.enableJLink=false',
            '-Dandroid.disableJLinkTransform=true'
        ]
    }
}
'@

$initScript | Out-File -FilePath "$gradleDir\init.gradle" -Encoding ASCII
Write-Host "已创建 $gradleDir\init.gradle" -ForegroundColor Green
Write-Host "内容：" -ForegroundColor Yellow
Write-Host $initScript -ForegroundColor White
