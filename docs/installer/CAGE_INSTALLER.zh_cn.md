# Cage 安装器运行时

本文档说明 MeoArch 安装器规格如何映射到当前 Live ISO 运行时。产品流程和 UX 规则见 `INSTALLER_SPEC.zh_cn.md`。

## 运行时概览

安装器会在 Cage 中作为单个全屏 GTK 应用运行：

```text
systemd
  -> meoarch-installer.service
  -> /usr/local/bin/meoarch-installer-kiosk
  -> cage
  -> /usr/local/bin/meoarch-installer
  -> /opt/meoarch-installer/meoarch_installer.py
```

当前实现有意保持非破坏性。它可以显示安装器外壳，并写入预览文件：

```text
/tmp/meoarch-archinstall-preview.json
```

它不会分区、格式化、挂载目标磁盘，也不会执行 `archinstall`。

## Live ISO 文件

| 用途 | 路径 |
| --- | --- |
| 开发源码 | `scripts/installer/meoarch_installer.py` |
| 运行时应用 | `MeoArch os/airootfs/opt/meoarch-installer/meoarch_installer.py` |
| 应用启动器 | `MeoArch os/airootfs/usr/local/bin/meoarch-installer` |
| Cage 启动器 | `MeoArch os/airootfs/usr/local/bin/meoarch-installer-kiosk` |
| systemd 服务 | `MeoArch os/airootfs/etc/systemd/system/meoarch-installer.service` |
| 服务启用链接 | `MeoArch os/airootfs/etc/systemd/system/multi-user.target.wants/meoarch-installer.service` |

`scripts/build.sh` 会在调用 `mkarchiso` 前运行 `scripts/sync-installer-to-airootfs.sh`，因此开发源码的修改会自动同步进 ISO profile。

## 必需 ISO 包

Live ISO 包列表必须包含：

```text
archinstall
cage
gtk4
python-gobject
```

`archinstall` 是为未来后端保留的。当前框架不会执行它。

## 服务行为

服务通过 Live 系统的 `multi-user.target` 启动。

关键属性：

- 在 Live ISO 中以 root 运行
- 使用 `/dev/tty1`
- 直接启动 Cage
- 失败后自动重启
- 导出 `GDK_BACKEND=wayland`
- 导出 `XKB_DEFAULT_LAYOUT=us`

该服务面向 kiosk 安装环境，而不是通用桌面会话。

## 当前 UI 映射

当前框架为最终流程提供了轻量外壳：

| 当前页面 | 最终规格页面 | 状态 |
| --- | --- | --- |
| Welcome | Welcome | 已作为框架页面存在 |
| Disk | Disk Selection | 占位 |
| User | User Account | 占位 |
| Profile | Privacy、desktop、package choices | 占位 |
| Review | Summary | 仅 JSON 预览 |
| Install | Installing | 禁用执行器，仅写入预览 |

最终规格还需要增加：

- Language & Region
- Keyboard Layout
- Network
- Privacy & Security
- Finish

在连接真实安装后端之前，应先加入这些页面。

## 数据流

当前框架：

```text
GTK page state
  -> static preview object
  -> /tmp/meoarch-archinstall-preview.json
```

目标流程：

```text
GTK page state
  -> validated installer model
  -> archinstall config JSON
  -> final confirmation
  -> archinstall execution backend
  -> progress and logs
```

在启用执行后端之前，必须先存在最终确认页。

## 安全契约

当前框架必须保持非破坏性。

允许：

- 显示 UI
- 收集选项
- 生成预览 JSON
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

## 实现路线

1. 加入 `INSTALLER_SPEC.zh_cn.md` 中缺失的 UX 页面。
2. 用简单且带验证的控件替换占位页面。
3. 将硬件、磁盘、网络和 locale 检测作为结构化后端数据接入。
4. 生成完整的 `archinstall` 配置预览。
5. 加入 Summary 页面，作为严格的最终检查点。
6. 加入 Installing 页面，包含进度和默认折叠日志。
7. 只有在验证和确认流程完整后，才启用真实后端执行。

## 手动测试清单

连接真实安装行为之前，需要验证：

- Live ISO 能启动到安装器服务。
- Cage 能成功启动。
- GTK 窗口能填满显示器。
- 安装器可以在所有页面间导航。
- 预览文件能写入 `/tmp/meoarch-archinstall-preview.json`。
- 关闭安装器后 Cage 能干净退出。
- 服务失败会写入 journal。
- 不发生任何磁盘状态更改。

