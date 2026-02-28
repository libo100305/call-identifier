# GitHub Actions 构建指南

## 构建状态查看

1. 打开：https://github.com/libo100305/call-identifier/actions
2. 查看最新的构建任务
3. 等待状态变为 ✅（成功）

## 下载 APK

构建成功后：
1. 点击构建任务
2. 滚动到页面底部
3. 找到 **Artifacts** 部分
4. 点击 **app-debug.apk** 下载

## 构建失败处理

如果构建失败，可能原因：
1. 依赖版本问题
2. Flutter 版本不兼容
3. 网络问题

解决方案：
1. 检查 Actions 日志
2. 修改 pubspec.yaml 中的依赖版本
3. 重新推送代码触发构建

## 当前配置

- Flutter 版本：3.24.0
- JDK 版本：17
- 构建类型：Debug APK
