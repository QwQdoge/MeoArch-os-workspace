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
  -> /opt/meoarch-installer/bin/meoarch-installer-app
  -> /opt/meoarch-installer/qml/Main.qml
```

UI 源码放在 archiso profile 外面的 `installer/` 中。构建同步步骤会把 QML 文件和共享 `assets/` 复制到 Live ISO 的运行目录。

## Live ISO 文件

| 用途 | 路径 |
| --- | --- |
| 开发源码 | `installer/` |
| 运行时应用 | `meoarch-os/airootfs/opt/meoarch-installer/qml/Main.qml` |
| 运行时资源 | `meoarch-os/airootfs/opt/meoarch-installer/assets/` |
| 应用启动器 | `meoarch-os/airootfs/usr/local/bin/meoarch-installer` |
| Cage 启动器 | `meoarch-os/airootfs/usr/local/bin/meoarch-installer-kiosk` |
| systemd 服务 | `meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service` |

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

只有原生 controller 完成验证并显式启用生产路径后，才会调用 `archinstall`。

## 启动参数

启动器默认进入非破坏模式：

```sh
meoarch-installer
```

能力参数必须显式传入；ISO kiosk 启动器负责组合生产参数：

| 参数 | 作用 |
| --- | --- |
| `--production` | 标记由 ISO 控制的生产启动。 |
| `--enable-real-install` | 仅与 `--production` 一起启用受保护的 Archinstall 适配器。 |
| `--enable-system-actions` | 仅与 `--production` 一起启用重启和关机。 |
| `--repair` | 在 Live 模式中打开快速修复。 |
| `--` | 后面的所有参数原样转发给原生安装器 host。 |

启动器不会回退到裸 QML 运行时，因为它无法提供必需的 controller 和生产能力边界。

## 服务行为

服务通过 Live 系统的 `graphical.target` 启动。

关键属性：

- 在 Live ISO 中以 root 运行
- 使用 `/dev/tty1`
- 直接启动 Cage
- 失败后自动重启
- 导出 `QT_QPA_PLATFORM=wayland`
- 导出 `XKB_DEFAULT_LAYOUT=us`

该服务面向 kiosk 安装环境，而不是通用桌面会话。

## 当前 UI 映射

QML 外壳从 Welcome 到 Finish 共包含 12 个引导页面，覆盖语言、键盘、网络、
隐私、磁盘、账户、软件、更新通道、复核和安装状态。共享背景、居中卡片、
顶部操作、底部导航和居中电源对话框定义在 `installer/qml/PageFrame.qml`。

## 安全契约

默认开发启动保持非破坏性。真实安装和系统电源操作必须由 ISO kiosk 启动器
分别提供生产能力参数。

允许：

- 显示 UI
- 收集选项
- 生成并验证安装计划
- 在 `/tmp` 下写入临时日志
- 运行非破坏性的 Archinstall 预检查
- 在不执行系统动作时报告其已禁用

禁止：

- 分区磁盘
- 格式化文件系统
- 挂载目标磁盘
- 执行真实 `archinstall` 安装
- 执行 `pacstrap`
- 执行 `grub-install`
- 创建目标用户
- 修改固件启动项
- 默认执行关机、重启或睡眠

## 手动测试清单

连接真实安装行为之前，先测试默认禁用模式：

- Live ISO 能启动到安装器服务。
- Cage 能成功启动。
- QML 窗口能填满显示器。
- 安装器可以在 12 个页面间导航。
- Material 电源对话框可以打开，并要求长按确认。
- 没有生产能力参数时，重启和关机会显示已禁用提示。
- 关闭安装器后 Cage 能干净退出。
- 服务失败会写入 journal。
- 不发生任何磁盘状态更改。

然后测试显式开启模式：

```sh
meoarch-installer --production --enable-system-actions
meoarch-installer --production --enable-real-install
```

预期结果：

- `--enable-system-actions` 允许 controller 请求重启或关机。
- `--enable-real-install` 允许已确认且就绪的计划进入安装适配器。
- 没有 `--production` 时，这两个能力参数都保持禁用。
