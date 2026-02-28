# 📱 Vivo 手机连接快速指南

## ⚠️ 当前状态
**未检测到设备** - 需要连接手机或启动模拟器

---

## 🔌 方案一：连接 Vivo 真机测试（推荐）

### 步骤 1：启用开发者选项
1. 打开 **设置**
2. 进入 **关于手机**
3. 连续点击 **版本号** 7 次
4. 看到提示"您已处于开发者模式"

### 步骤 2：开启 USB 调试
1. 返回 **设置** 主界面
2. 进入 **系统管理**（或"更多设置"）
3. 找到 **开发者选项**
4. 开启 **USB 调试** 开关
5. 弹出确认框时点击 **确定**

### 步骤 3：连接 USB
1. 使用 USB 数据线连接手机和电脑
2. 手机上弹出"允许 USB 调试"对话框
3. 勾选"始终允许"并点击 **确定**
4. 下拉通知栏，将 USB 模式改为 **传输文件（MTP）**

### 步骤 4：验证连接
连接成功后，在电脑终端运行：
```bash
adb devices
```

**预期输出：**
```
List of devices attached
XXXXXXXX    device
```

如果还是看不到设备，请继续看下面的故障排查。

---

## 🖥️ 方案二：使用 Android 模拟器（无需真机）

### 方式 A：使用 Android Studio 模拟器

1. **打开 Android Studio**
2. **创建模拟器**：
   - Tools → Device Manager
   - Click "Create Device"
   - 选择手机型号（推荐 Pixel 6）
   - 下载并选择系统镜像（推荐 API 33）
   - 完成创建

3. **启动模拟器**：
   - 在 Device Manager 中点击 ▶️ 启动

4. **运行应用**：
   ```bash
   cd C:\Users\admin\Desktop\xmwj\dianhua
   flutter run
   ```

### 方式 B：使用网易 MuMu 模拟器

1. **下载并安装**：https://mumu.163.com/
2. **启动 MuMu 模拟器**
3. **开启 USB 调试**：
   - 设置 → 关于平板电脑 → 连续点击版本号
   - 返回设置 → 开发者选项 → 开启 USB 调试
4. **运行应用**：
   ```bash
   flutter run
   ```

### 方式 C：使用雷电模拟器

1. **下载并安装**：https://www.ldmnq.com/
2. **开启 ROOT 权限**：
   - 设置 → 其他设置 → 开启 ROOT 权限
3. **开启 USB 调试**：
   - 设置 → 开发者选项 → USB 调试
4. **连接 ADB**：
   ```bash
   adb connect 127.0.0.1:5555
   ```
5. **运行应用**：
   ```bash
   flutter run
   ```

---

## 🔧 故障排查

### 问题 1：adb devices 看不到设备

**症状：**
```
List of devices attached
```
（空列表）

**解决方案：**

#### 1. 检查 USB 连接
- 重新插拔 USB 线
- 尝试不同的 USB 端口
- 更换 USB 线（确保是数据线而非充电线）

#### 2. 检查驱动
```bash
# 查看设备管理器是否有未知设备
# Win + X → 设备管理器
# 查看是否有带黄色感叹号的设备
```

**安装 Vivo 驱动：**
- 大多数情况下 Windows 会自动安装
- 如需手动安装：使用手机助手类软件

#### 3. 重启 ADB 服务
```bash
adb kill-server
adb start-server
adb devices
```

#### 4. 检查开发者选项
- 确认开发者选项已开启
- 确认 USB 调试已开启
- 关闭并重新开启 USB 调试
- 撤销 USB 调试授权，重新连接

### 问题 2：设备 unauthorized

**症状：**
```
List of devices attached
XXXXXXXX    unauthorized
```

**解决方案：**
1. 手机上会弹出"允许 USB 调试"对话框
2. 勾选"始终允许"
3. 点击"确定"
4. 再次运行 `adb devices`

### 问题 3：连接不稳定

**症状：** 设备时有时无

**解决方案：**
```bash
# 设置永不断连
adb devices
# 如果设备消失，重新运行
adb reconnect
```

---

## 🎯 快速连接检查清单

请按顺序检查：

- [ ] 手机开发者选项已开启
- [ ] USB 调试已开启
- [ ] USB 线已连接
- [ ] 手机选择"传输文件"模式
- [ ] 手机上允许了 USB 调试
- [ ] 运行 `adb devices` 能看到设备
- [ ] 运行 `flutter devices` 能看到设备

---

## 🚀 连接成功后的操作

一旦看到设备，立即运行：

```bash
# 方法 1：使用脚本（推荐）
双击 run_on_vivo.bat

# 方法 2：手动运行
cd C:\Users\admin\Desktop\xmwj\dianhua
flutter run
```

---

## 📞 需要帮助？

如果以上方法都不行，请提供以下信息：

1. **手机型号**：例如 Vivo X90 Pro+
2. **Android 版本**：设置 → 关于手机 → Android 版本
3. **连接状态**：`adb devices` 的输出
4. **设备管理器截图**：是否有未知设备

---

## 💡 临时方案：使用 Chrome 浏览器测试

如果暂时无法连接手机，可以先用浏览器测试基本功能：

```bash
cd C:\Users\admin\Desktop\xmwj\dianhua
flutter run -d chrome
```

**注意：** 相机功能在浏览器中可能无法使用，但可以测试其他功能。

---

**选择最适合您的方案开始测试吧！** 🎉
