> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Themes & UI Components

为了保证组件与桌面主题的单一权威源（Single Source of Truth），项目遵循以下架构规范：

- **MeoUI 组件库 & GitHub Pages 规范站点**：单一维护在 sibling `MeoUI` 仓库中（本地可通过 `$MEO_UI_ROOT` 解析）（包含 `meo-ui/docs/` 作为 GitHub Pages 站点，展示全部 89+ 组件及图片/文档）。
- **KDE Plasma 6 桌面集成与主题**：单一维护在 sibling `meo-kde` 仓库中（本地可通过 `$MEO_KDE_ROOT` 解析）（包含 Look-and-Feel、Plasmoids、KDecoration2 窗口装饰及 KWin 6 特效）。
- **MeoArch OS ISO 构建**：`meo-arch-os-workspace` 的 ISO 打包与构建脚本会自动从外部的 `meo-ui` 和 `meo-kde` 读取并安装最新版本，不再在工作区内部存放冗余的重复副本。
