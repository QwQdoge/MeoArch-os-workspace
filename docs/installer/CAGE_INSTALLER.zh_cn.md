# Cage 安装器运行时

本文档说明 MeoArch 安装器规格如何映射到当前 Live ISO 运行时。产品流程和 UX 规则见 `INSTALLER_SPEC.zh_cn.md`。

## 运行时概览

安装器会在 Cage 中作为单个全屏 Qt Quick/QML 应用运行：

```text
systemd
  -> meoarch-installer.service
  -> /usr/local/bin/meoarch-installer-kiosk
  -> cage
  -> /usr/local/bin/meoarch-installer
  -> /opt/meoarch-installer/qml/Main.qml
```

UI 源码放在 archiso profile 外面的 `installer/` 中。构建同步步骤会把 QML 文件和共享 `assets/` 复制到 Live ISO 的运行目录。

## Live ISO 文件

| 用途 | 路径 |
| --- | --- |
| 开发源码 | `installer/` |
| 运行时应用 | `MeoArch os/airootfs/opt/meoarch-installer/qml/Main.qml` |
| 运行时资源 | `MeoArch os/airootfs/opt/meoarch-installer/assets/` |
| 应用启动器 | `MeoArch os/airootfs/usr/local/bin/meoarch-installer` |
| Cage 启动器 | `MeoArch os/airootfs/usr/local/bin/meoarch-installer-kiosk` |
| systemd 服务 | `MeoArch os/airootfs/etc/systemd/system/meoarch-installer.service` |

`scripts/build.sh` 会在调用 `mkarchiso` 前运行 `scripts/sync-installer-to-airootfs.sh`，因此独立 installer 源码的修改会自动同步进 ISO profile。

## 必需 ISO 包

Live ISO 包列表必须包含：

```text
archinstall
cage
qt6-base
qt6-declarative
qt6-wayland
```

`archinstall` 是为未来后端保留的。当前框架不会执行它。

## 服务行为

服务通过 Live 系统的 `multi-user.target` 启动。

关键属性：

- 在 Live ISO 中以 root 运行
- 使用 `/dev/tty1`
- 直接启动 Cage
- 失败后自动重启
- 导出 `QT_QPA_PLATFORM=wayland`
- 导出 `XKB_DEFAULT_LAYOUT=us`

该服务面向 kiosk 安装环境，而不是通用桌面会话。

## 当前 UI 映射

QML 外壳当前包含 10 个页面：

| QML 页面 | 最终规格页面 | 状态 |
| --- | --- | --- |
| `WelcomePage.qml` | Welcome | 已完成首屏视觉 |
| `LanguageRegionPage.qml` | Language & Region | 占位 |
| `KeyboardLayoutPage.qml` | Keyboard Layout | 占位 |
| `NetworkPage.qml` | Network | 占位 |
| `PrivacySecurityPage.qml` | Privacy & Security | 占位 |
| `DiskSelectionPage.qml` | Disk Selection | 占位 |
| `UserAccountPage.qml` | User Account | 占位 |
| `SummaryPage.qml` | Summary | 占位 |
| `InstallingPage.qml` | Installing | 占位 |
| `FinishPage.qml` | Finish | 占位 |

共享背景、居中卡片、左上品牌条、右上按钮和右侧电源菜单定义在 `installer/qml/PageFrame.qml`。

## 安全契约

当前框架必须保持非破坏性。

允许：

- 显示 UI
- 收集选项
- 生成未来预览数据
- 在 `/tmp` 下写入临时日志

禁止：

- 分区磁盘
- 格式化文件系统
- 挂载目标磁盘
- 执行 `archinstall`
- 执行 `pacstrap`
- 执行 `grub-install`
- 创建目标用户
- 修改固件启动项

## 手动测试清单

连接真实安装行为之前，需要验证：

- Live ISO 能启动到安装器服务。
- Cage 能成功启动。
- QML 窗口能填满显示器。
- 安装器可以在 10 个页面间导航。
- 关闭安装器后 Cage 能干净退出。
- 服务失败会写入 journal。
- 不发生任何磁盘状态更改。
