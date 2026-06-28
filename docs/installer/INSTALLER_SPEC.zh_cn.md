# MeoArch OS 安装器规格

## 概览

MeoArch OS Installer 是为 MeoArch Live ISO 设计的全屏图形安装器。它会以专注的 kiosk 应用形式启动，而不是先暴露传统桌面会话。

第一阶段目标是一个安全、非破坏性的框架。它可以展示安装流程、收集未来会用到的选项，并生成 `archinstall` 配置预览。在破坏性安装路径被明确设计和审核之前，它不能分区、格式化、挂载目标磁盘，也不能执行真实安装。

## 产品目标

安装器应该给人清晰、安静、可信的感觉。默认流程面向普通用户，除非用户主动进入高级模式，否则不暴露 Linux 技术细节。

主要目标：

- 为 MeoArch OS 提供简单的图形安装体验。
- 在任何破坏性操作发生前，让风险选择足够明显。
- 把隐私和安全作为产品特性展示出来。
- 未来使用 `archinstall` 作为安装后端，并通过验证后的结构化配置驱动，而不是临时拼接 shell 命令。
- 为高级用户保留技术细节，但不让它们进入默认流程。

第一阶段非目标：

- 真实磁盘分区
- 文件系统格式化
- 挂载目标磁盘
- 执行 `archinstall`
- 安装 GRUB
- 创建真实目标用户
- 修改固件启动项

## 系统基线

当前假设：

- 基础发行版：Arch Linux
- ISO 构建工具：archiso
- Kiosk 合成器：Cage
- 安装器界面：GTK 4 + PyGObject
- 未来后端：`archinstall`
- 默认目标启动器：GRUB
- 默认目标桌面：MeoArch 定制 KDE Plasma
- 当前框架行为：仅安全预览

这些假设可以演进，但任何影响磁盘操作、启动器行为或最终安装系统的变化，都应先写入文档再实现。

## 运行架构

Live ISO 会在 Cage 中启动一个单独的图形安装器：

```text
Live ISO boot
  -> systemd
  -> meoarch-installer.service
  -> meoarch-installer-kiosk
  -> cage
  -> meoarch-installer
  -> GTK installer UI
```

安装器当前只会写入一个预览文件：

```text
/tmp/meoarch-archinstall-preview.json
```

这个预览代表未来 `archinstall` 配置的大致形状，但框架不会执行它。

## 用户体验原则

默认流程面向普通用户。高级 Linux 概念必须隐藏，除非用户主动要求查看。

使用普通语言：

- 使用 `512 GB SSD`，而不是 `/dev/nvme0n1`。
- 使用 `Erase disk and install`，而不是 `create GPT, EFI, root, swap`。
- 使用 `Recommended privacy settings are enabled`，而不是 `nftables service active`。

每个破坏性步骤都必须具备：

- 简单说明
- 明显警告
- 执行前摘要
- 不可逆更改前的最终确认

## 安装流程

推荐流程：

```text
Welcome
Language & Region
Keyboard Layout
Network
Privacy & Security
Disk Selection
User Account
Summary
Installing
Finish
```

当前框架可以在实现过程中保留占位页面，但最终用户流程应遵循这个顺序。

## 页面规格

### 1. Welcome

显示规则：必须显示。

作用：介绍系统，并开始安装。

显示：

- 系统名称
- Logo
- 简短介绍
- 语言选择器
- `Start Installation` 按钮

建议文案：

```text
Welcome to MeoArch OS Installer
This installer will help you install the system safely and simply.
```

不要显示：

- 分区细节
- 启动器选项
- Swap 设置
- 文件系统选择
- 内核参数

### 2. Language & Region

显示规则：必须或强烈建议显示。

作用：选择界面语言、地区和时区。

显示：

- Language: English / Chinese / Japanese
- Region: Singapore / China / Japan / etc.
- Time zone: 自动检测，允许用户修改

不要显示：

- `en_US.UTF-8` 这类 locale 代码
- `/etc/locale.gen`
- NTP 细节

### 3. Keyboard Layout

显示规则：必须或强烈建议显示。

作用：避免因键盘布局错误导致密码输入问题。

显示：

- Keyboard layout: US / UK / Chinese / Japanese
- 测试输入框：`Type here to test your keyboard`

不要显示：

- XKB model
- Variant
- Compose key

这些应放在 Advanced 设置里。

### 4. Network

显示规则：条件显示。

如果系统已经联网，只显示简洁状态：

```text
Connected to the Internet
```

如果离线，再显示连接选项。

显示：

- 当前网络状态
- 支持时显示 Wi-Fi 列表
- 有线网络状态
- `Retry` 和 `Skip`

默认不要显示：

- IP 地址
- DNS
- 网关
- Proxy

这些应放在 Advanced 设置里。

### 5. Privacy & Security

显示规则：必须显示。

作用：让 MeoArch 的隐私和安全取向变得可见、可理解。

显示：

- 默认启用推荐隐私设置
- Disable telemetry
- Enable firewall
- Enable automatic security updates
- Encrypt disk
- Restrict default permissions

建议文案：

```text
Recommended privacy settings are enabled by default.
[x] Disable telemetry
[x] Enable firewall
[x] Enable automatic security updates
[ ] Encrypt disk
```

不要显示：

- `iptables` 或 `nftables` 规则
- 加密算法细节
- systemd 服务细节

### 6. Disk Selection

显示规则：必须显示。

作用：选择安装目标。这是最高风险页面，因为它可能导致数据丢失。

默认模式：

```text
Choose where to install the system
```

显示：

- 磁盘名称
- 磁盘大小
- 是否会擦除数据
- 警告：`This will erase all data on the selected disk.`

默认选项：

- `Erase disk and install`
- `Manual partitioning / Advanced`

默认不要显示：

- `/dev/sda`
- `/dev/nvme0n1p1`
- EFI 分区
- Root 分区
- Swap 分区
- `ext4` 或 `btrfs`

这些应放在 Advanced 设置里。

### 7. User Account

显示规则：必须显示。

作用：创建安装后登录使用的账户。

显示：

- Your name
- Username
- Computer name
- Password
- Confirm password
- Automatic login option

不要显示：

- UID
- Shell
- `sudo` group
- Home directory path

这些应由默认值处理。

### 8. Summary

显示规则：必须显示。

作用：破坏性更改前的最终安全检查点。

显示：

```text
Ready to install

Language: English
Keyboard: US
Disk: 512 GB SSD
Install mode: Erase disk
Privacy: Recommended settings enabled
User: shekong
```

按钮：

```text
Back        Install Now
```

警告：

```text
After clicking Install Now, disk changes cannot be undone.
```

高级用户可以打开 `Show details` 查看技术输出。

### 9. Installing

显示规则：必须显示。

作用：在后端执行安装步骤时展示进度。

显示：

- 进度条
- 当前步骤
- 简短说明
- 可展开日志

示例步骤：

```text
Installing system files...
Setting up user account...
Installing bootloader...
Applying privacy settings...
```

默认不要显示完整日志。使用 `Show details` 展开。

### 10. Finish

显示规则：必须显示。

作用：给用户明确的结束状态。

显示：

```text
Installation complete
You can now restart your computer.
```

按钮：

- `Restart Now`

可选：

- `Remove installation media after shutdown`

除非安装失败，否则不要显示复杂日志、堆栈跟踪或安装路径。

## 可见性矩阵

| 模块 | 可见性 | 原因 |
| --- | --- | --- |
| Welcome | 必须 | 建立安装器身份 |
| Language | 必须 / 建议 | 普通用户需要 |
| Region / time zone | 建议 | 可自动检测 |
| Keyboard layout | 必须 / 建议 | 密码输入必须可靠 |
| Network | 条件显示 | 已联网时弱化 |
| Privacy settings | 必须 | 符合项目重点 |
| Disk selection | 必须 | 高风险操作 |
| Manual partitioning | 仅 Advanced | 普通用户不需要 |
| User account | 必须 | 安装后登录需要 |
| Bootloader | 默认隐藏 | 太技术化 |
| Filesystem choice | 默认隐藏 | 太技术化 |
| Swap settings | 默认隐藏 | 应自动处理 |
| Summary | 必须 | 防止误操作 |
| Install logs | 默认隐藏 | 用户要求时才显示 |
| Finish | 必须 | 给出明确结束感 |

## 后端边界

UI 可以：

- 展示结构化状态
- 页面导航
- 收集用户选择
- 请求检测或生成预览
- 展示进度和日志

UI 不能：

- 解析 `lsblk` 等工具的原始命令输出
- 从用户可见标签拼接 shell 命令
- 分区磁盘
- 格式化文件系统
- 挂载安装目标
- 直接执行安装命令

后端应该：

- 读取硬件和磁盘信息
- 将数据规范化为带版本的 JSON
- 验证用户选择
- 生成 `archinstall` 配置
- 明确分离 dry-run 和真实执行路径

## 未来 `archinstall` 配置

安装器未来应生成经过验证的配置，例如：

```json
{
  "hostname": "meoarch",
  "locale_config": {
    "kb_layout": "us",
    "sys_enc": "UTF-8",
    "sys_lang": "en_US"
  },
  "mirror_config": {
    "mirror_regions": {
      "Worldwide": ["https://geo.mirror.pkgbuild.com/$repo/os/$arch"]
    }
  },
  "timezone": "UTC"
}
```

只有在对应 UI 验证存在后，才能扩展这个 schema。

## 第一阶段安全规则

框架阶段允许：

- 读取硬件信息
- 读取磁盘信息
- 检测网络状态
- 生成配置预览
- 写入 `/tmp` 下的临时安装器日志

框架阶段禁止：

- 修改分区表
- 格式化文件系统
- 挂载目标磁盘
- 执行 `archinstall`
- 执行 `pacstrap`
- 生成或覆盖真实 `fstab`
- 执行 `grub-install`
- 创建目标系统用户
- 修改固件启动项

## 未决事项

这些主题需要单独设计后才能实现：

- 自动分区布局
- 默认文件系统
- 全盘加密行为
- 双系统策略
- KDE Plasma 精确包组
- MeoArch 自有包列表
- BIOS 和 UEFI 下的 GRUB 参数
- Secure Boot 支持
- 离线安装行为
- 失败恢复和回滚行为

