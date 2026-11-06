# MeoArch 主文档 / Master Doc

> **这是 MeoArch 全部仓库的唯一入口与地图。** 任何人或 AI 代理（Claude Code、Codex 等）只要读完本文件，就知道：有哪些仓库、各自负责什么、代码在哪台机器的哪个目录、怎么构建/验证/发布/部署、线上跑在 Cloudflare 的哪个资源上，以及去哪里读更详细的文档。
> 每个仓库的 `README.md`、`AGENTS.md` 以及 `docs/` 下的文档第一行都有指回本文件的链接。
> 全部 Markdown 文档的完整链接清单见 [MEOARCH_DOC_INDEX.md](MEOARCH_DOC_INDEX.md)（由脚本生成，不手改）。

- 本文件位置：<https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md>
- 命令行读取（任何环境，已登录 `gh`）：`gh api repos/QwQdoge/MeoArch-os-workspace/contents/docs/MEOARCH_MASTER.md -H 'Accept: application/vnd.github.raw'`
- 本文件只做**导航与汇总**，不是权威合同。出现冲突时按 [docs/README.md](README.md) 的权威顺序（产品身份 → 跨仓库合同 → 所属仓库合同 → 当前里程碑 → …）；仓库边界以 [repository-architecture.md](repository-architecture.md) 为准。
- 本文件不含任何密钥、令牌、连接串。永远不要把它们写进文档、日志或提交。

## 文档分工

- **主文档（本文件）：怎么用。** 各个产品和接口怎么使用，以及去哪里找。
- **各项目自己的文档（`README.md`、`AGENTS.md`、`docs/`）：怎么做这个项目。** 构建、测试、贡献和内部约定。
- **账号 API 怎么用**：<https://meoarch.org/docs/guide/account-api.html>（Markdown 版 <https://meoarch.org/docs/guide/account-api.md>）。基础地址 `https://api.meoarch.org/v1`，授权用 Meo Account OAuth 2.1（授权码 + S256 PKCE），令牌 scope 为 `meo:read` / `meo:write`。接口的实现和维护细节见 meo-api 仓库的 `docs/api-reference.md`。
- 使用要求（系统、Meo AI、各应用）：<https://meoarch.org/docs/guide/requirements.html>。

---

## 1. 一张图看懂 MeoArch

```text
                         ┌────────────────────────── 设计系统 ──────────────────────────┐
                         │ MeoUI（Qt Quick / QML Material 3 Expressive：token、控件、Showcase）│
                         └───────┬───────────────────────────────┬──────────────────────┘
                                 │ 被依赖                         │ 文档生成 → meoarch.org/docs, llms.txt
        ┌────────────────────────▼───────────┐   ┌───────────────▼──────────────┐
        │ 桌面与应用（Arch + KDE Plasma 6）    │   │ 官网与落地页（Cloudflare）       │
        │ meo-kde      Plasma/KWin 集成、Meo.System │   │ meoarch-site  meoarch.org (Pages)│
        │ MeoSettings  系统设置应用              │   │ MeoArch-os-webside  os.meoarch.org│
        │ OmniStore    软件商店                 │   │ meo-ai-landing ai.meoarch.org    │
        │ meo-ai       AI 助手（桌面/Web/安卓）   │   │ Worker meoarch-paths /os /ai 路径  │
        │ meo-login-manager 登录管理器           │   └──────────────────────────────┘
        │ kde-plasma6-widgets 第三方小部件收集    │
        └───────────────┬────────────────────┘
                        │ 打包 / 签名 / 发布
        ┌───────────────▼────────────────┐    ┌──────────────── 账号与后端 ────────────────┐
        │ meo-repo  PKGBUILD、manifests、   │    │ meo-api（Cloudflare Worker：api.meoarch.org）│
        │ release.yml → 签名 pacman 仓库     │    │   └ Hyperdrive → Neon（Meo Account / Meo AI）│
        │ + AUR；二进制放 R2                 │    │ MeoArch-account（Flutter 账号站：Pages）     │
        └───────────────┬────────────────┘    └──────────────────────────────────────────┘
                        │ 被组装
        ┌───────────────▼────────────────┐    ┌──────── 独立项目 ────────┐
        │ MeoArch-os-workspace  ISO、安装器、│    │ downloader（下载源发现+安全重定向）│
        │ 修复工具、System AI Router、验收    │    │ mrbeazleyisamazing（静态图库）   │
        └────────────────────────────────┘    └─────────────────────────┘
```

依赖方向：`MeoUI → 应用 / meo-kde → MeoArch-os-workspace 集成 → meo-repo 打包与发布`。品牌缩写 **MEO = Modern · Expressive · Open**。

---

## 2. 所有东西在哪里（只有三处：GitHub、本机、Cloudflare）

### 2.1 GitHub（账号 `QwQdoge`，`gh` 已登录，协议 https）

| 仓库 | 可见性 | 默认分支 | 一句话职责 |
|---|---|---|---|
| [MeoUI](https://github.com/QwQdoge/MeoUI) | 公开 | main | 共享设计系统（QML 控件、token、动效、Showcase） |
| [meo-kde](https://github.com/QwQdoge/meo-kde) | 公开 | main | KDE Plasma 6 原生集成：Shell、Plasmoid、主题、Meo.System、桌面默认配置 |
| [MeoSettings](https://github.com/QwQdoge/MeoSettings) | 公开 | main | 日常系统设置应用 |
| [OmniStore](https://github.com/QwQdoge/OmniStore) | 公开 | main | 软件商店（pacman / AUR / flatpak / appimage），Python 后端 + 原生 MeoUI 客户端 |
| [meo-ai](https://github.com/QwQdoge/meo-ai) | 公开（fork） | main | AI 助手：桌面（C++/QML）、Web、安卓、Rust 核心、无头服务 |
| [meo-login-manager](https://github.com/QwQdoge/meo-login-manager) | 公开 | **`meo/6.7`** | 登录/显示管理器（KDE Plasma Login Manager 的展示层下游分支） |
| [meo-repo](https://github.com/QwQdoge/meo-repo) | 公开 | main | pacman 软件源：配方、发布清单、校验、签名与发布工作流（Stable/Beta） |
| [MeoArch-os-workspace](https://github.com/QwQdoge/MeoArch-os-workspace) | 公开 | main | ISO 集成：ArchISO 配置、安装器、修复工具、System AI Router、验收；**本主文档所在仓库** |
| [meoarch-site](https://github.com/QwQdoge/meoarch-site) | 公开 | main | 总官网 `meoarch.org` + Worker `meoarch-paths` + 生成的 MeoUI 文档站 |
| [MeoArch-os-webside](https://github.com/QwQdoge/MeoArch-os-webside) | 私有 | main | MeoArch OS 官网（`os.meoarch.org`） |
| [meo-ai-landing](https://github.com/QwQdoge/meo-ai-landing) | 私有 | main | `ai.meoarch.org` 落地页 Worker |
| [meo-api](https://github.com/QwQdoge/meo-api) | 私有 | main | 服务端 API Worker：Better Auth、OAuth 2.1、`/v1/*`、AI 与账号数据 |
| [MeoArch-account](https://github.com/QwQdoge/MeoArch-account) | 私有 | main | Meo Account 账号站（Flutter Web + 桌面代理），部署到 Pages |
| [downloader](https://github.com/QwQdoge/downloader) | 私有 | main | 下载源发现与安全重定向（Worker + Flutter Web） |
| [kde-plasma6-widgets](https://github.com/QwQdoge/kde-plasma6-widgets) | 公开（fork） | main | 第三方/上游 Plasma 6 小部件暂存与兼容收集 |
| [mrbeazleyisamazing](https://github.com/QwQdoge/mrbeazleyisamazing) | 公开 | main | 小型静态图库 |

不属于 MeoArch 产品线、本文件**不管**：[vrcx-c](https://github.com/QwQdoge/vrcx-c)（VRC Memories，自带主文档 README）、[obsidian-notes](https://github.com/QwQdoge/obsidian-notes)、[cent-journal-cent](https://github.com/QwQdoge/cent-journal-cent)、[flutter](https://github.com/QwQdoge/flutter)（上游 fork）。旧仓库 `QwQdoge/MeoArch_os-workspace` 已废弃，禁止用于新工作。

### 2.2 本机环境（概览）

克隆按"需要哪个环境"分两处放：需要 Arch/Qt/KDE 工具链的放在 WSL 的 Arch 里，网站/云端/Flutter/Python 项目放在 Windows 里。`gh repo list QwQdoge` 是云端真相，两处都要和云端同步。

| 环境 | 仓库 |
|---|---|
| WSL（Arch）的 `projects` 目录 | meo-ai、meo-kde、MeoUI、MeoSettings、OmniStore、meo-login-manager、meo-repo、MeoArch-os-workspace、kde-plasma6-widgets |
| Windows 的 `projects` 目录 | meo-api、meo-ai-landing、meoarch-site、MeoArch-os-webside、downloader、mrbeazleyisamazing、MeoArch-account、vrcx-c |

**用户名、绝对路径、邮箱、虚拟机和机器布局等个人/本机信息只写在本机文件（`~/.claude/CLAUDE.md`、`projects/agent.md`），不进仓库、不上网站。** 虚拟机只保留 WSL Arch 一个。

跨仓库根变量（文档里常见）：`$MEO_UI_ROOT`（MeoUI）、`$MEO_KDE_ROOT`、`$MEO_DOCS_ROOT`（项目记录）、`$MEO_OUTPUT_ROOT`（构建/验证产物）、`$MEO_WORKSPACE_ROOT`（MeoArch-os-workspace）；未设置时用相邻目录，注意目录名是 `MeoUI`、`meo-kde`（不是 `meo-ui`）。

WSL 发行版平时是停止状态；从 Windows 调用即自动启动：`wsl.exe -d Arch -- bash -lc '…'`。

### 2.3 Cloudflare（线上全部在这里）

| 类型 | 名称 | 来源仓库 | 说明 |
|---|---|---|---|
| Worker | `meo-api` | meo-api | `api.meoarch.org`（自定义域）+ `account.meoarch.org` 的若干登录/授权/静态窄路由；经 Hyperdrive 连 Neon 的 Account 与 AI 两个库 |
| Worker | `meo-ai-landing` | meo-ai-landing | `ai.meoarch.org/`、`/about`、`/zh*`、`/assets/*`；push 到 main 由 Workers Builds 部署 |
| Worker | `meoarch-paths` | meoarch-site `workers/paths` | `meoarch.org/os*`（代理 OS 站）与 `/ai*`（服务绑定 `meo-ai-landing`） |
| Worker | `vrc-m-intro` | vrcx-c `landing/` | `meoarch.org/vrc-m*`（与本主文档范围无关，仅记录路由占用） |
| Pages | `meoarch-site` | meoarch-site | `meoarch.org`，push 到 main 自动部署 |
| Pages | `meoarch-account` | MeoArch-account | `account.meoarch.org` 账号站，由 `deploy.yml`（手动触发）发布 |
| Pages | chat 站 | meo-ai Web 客户端 | `chat.meoarch.org`（见 meo-api `docs/cloudflare-deployment.md` 的线上状态记录） |
| R2 | `meo-packages` | meo-repo | 软件源二进制包与仓库数据库（对外 `packages.meoarch.org`，详见 meo-repo `docs/artifact-storage.md`） |
| R2 | `meo-iso` | MeoArch-os-workspace / meo-repo | ISO 镜像存放 |
| KV | `MIRROR_KV` | downloader | 镜像/下载源状态缓存（staging 与 production 共用同一命名空间） |
| Hyperdrive | `meo-api-account`、`meo-api-ai` | meo-api | 指向 Neon `Meo Account` / `Meo AI` production（直连端点，非 pooler） |

当前没有 D1 数据库。要看实时清单：`wrangler` 或 Cloudflare MCP 工具（`workers_list`、`r2_buckets_list`、`kv_namespaces_list`、`d1_databases_list`）。后端外部依赖（均在 meo-api / downloader 内配置，**密钥只在 Cloudflare Worker secrets 或 GitHub Environment**）：Neon PostgreSQL、Resend（账号邮件）、Turnstile（人机验证）、Supabase（仅 downloader）。

### 2.4 域名与路由总表

| 地址 | 由谁提供 |
|---|---|
| `https://meoarch.org/` | Pages `meoarch-site` |
| `https://meoarch.org/docs/`、`/llms.txt` | meoarch-site 里由 MeoUI `docs/` 生成的静态文档（给人和代理） |
| `https://meoarch.org/os/` → `os.meoarch.org` | Worker `meoarch-paths` → MeoArch-os-webside |
| `https://meoarch.org/ai/` → `ai.meoarch.org` | Worker `meoarch-paths` → Worker `meo-ai-landing` |
| `https://ai.meoarch.org/` | Worker `meo-ai-landing` |
| `https://api.meoarch.org/` | Worker `meo-api` |
| `https://account.meoarch.org/` | Pages `meoarch-account` + Worker `meo-api` 的窄路由 |
| `https://chat.meoarch.org/` | Pages（Meo AI Web） |
| `https://packages.meoarch.org/` | R2 上的签名 pacman 仓库（`[meo]` 稳定 / `[meo-beta]` 测试） |

---

## 3. 全体共用规则（写进每个仓库 AGENTS.md 的"所有者规则"）

1. 直接在仓库当前默认分支提交（通常 `main`；`meo-login-manager` 是 `meo/6.7`），**不开功能分支/PR**，除非被要求。
2. 提交后**立即 push**，不要问许可，不要留下未提交/未推送的完成工作。
3. 验证从简：只跑与改动对应的检查，不跑全量、不额外写测试，除非被要求。
4. 一次做完，例行问题有明显默认值就别停下来问。
5. 密钥、令牌、凭据永远不进代码、日志、提交、文档、聊天。
6. UI 工作先读 MeoUI 规范：<https://meoarch.org/llms.txt> → <https://meoarch.org/docs/meoui/for-agents.md>（权威源是 MeoUI `docs/design/`，站点由它生成）。
7. 证据等级不可混用：`Specified → Implemented → Build-tested → Session-tested → VM-tested → Hardware-tested → Release-ready`。编译通过 ≠ 真实 Plasma 会话可用；预览 ≠ 线上。
8. 范围控制：不因看到长期合同就实现新功能；无关 bug/想法记录下来另做。
9. 不要未经授权发布、改 DNS、改托管配置、签名、改仓库数据库、上传产物。
10. 提交身份使用 GitHub noreply 邮箱（不要把个人邮箱写进提交或文档）；Claude 提交需带 `Co-Authored-By` 署名行。

---

## 4. 各仓库详解（做什么 · 在哪 · 怎么验证 · 怎么发布）

> 通用写法：`R` = `~/projects/<仓库>`。链接都指向 GitHub `main`。该仓库**所有** md 的清单见 [MEOARCH_DOC_INDEX.md](MEOARCH_DOC_INDEX.md)。

### 4.1 MeoUI — 共享设计系统
- 拥有：主题 token、控件、模式、动效、响应式合同、Showcase、网页 token 导出。不拥有：Plasma/KWin/DBus、应用后端。
- 先读：[README](https://github.com/QwQdoge/MeoUI/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/MeoUI/blob/main/AGENTS.md) · 设计规范 `docs/design/`（权威）。
- 验证（挑最窄的）：
  - 静态：`python3 tools/verify-design-system-usage.py --mode library MeoTheme.qml MeoMotion.qml components widgets patterns`
  - Qt/QML：`cmake --fresh -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TESTING=ON -DMEOUI_BUILD_SHOWCASE=OFF` → `cmake --build build --parallel 2` → `QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure --timeout 60`
  - 公开 QML 导出变化：`python3 tools/verify-showcase-coverage.py`；可见组件/动效/布局变化必须更新并运行 Showcase。
  - Web token：`node tools/export-web-tokens.mjs …`
- 发布：AUR 包 `meoui-qml`（`yay -Syu meoui-qml`），经 meo-repo 发布；文档由 meoarch-site 重新生成（见 4.9）。

### 4.2 meo-kde — Plasma 6 集成
- 拥有：Shell、Plasmoid、主题、Meo.System、KDE 原生桥接、桌面默认配置、锁屏/会话集成、Arch 打包定义。依赖 MeoUI，不复制其组件。
- 安装：`yay -Syu meo-desktop`，或 `curl -fsSL https://raw.githubusercontent.com/QwQdoge/meo-kde/main/bootstrap.sh | bash`（`-y` 免确认、`--dry-run` 试运行）；本地 `./install.sh`。
- 先读：[README](https://github.com/QwQdoge/meo-kde/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/meo-kde/blob/main/AGENTS.md) · `docs/desktop-architecture.md` · `docs/component-status.md` · `docs/design-system.md`。
- 验证：脚本 `bash -n`；合同/主题/小部件用 `tests/` 下 unittest（跨领域才跑 `.github/workflows/contracts.yml` 全套）；`native/system/` 变更按 `native-system-build.yml`：`BUILD_TESTING=ON` 配置、构建，再 `QT_QPA_PLATFORM=offscreen ctest`。
- 发布：meo-repo 打包（`meo-desktop` 等包）。

### 4.3 MeoSettings — 系统设置
- 拥有：设置应用及其运行时合同；不替代 NetworkManager/BlueZ/PipeWire/KScreen/PowerDevil/KWin/System Settings。
- 安装：`yay -Syu meo-settings`。先读：[README](https://github.com/QwQdoge/MeoSettings/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/MeoSettings/blob/main/AGENTS.md) · `docs/ARCHITECTURE.md` · `docs/SETTINGS_COVERAGE.md`。
- 验证（镜像 `.github/workflows/arch-tests.yml`）：先构建 MeoUI 与 Meo.System 依赖 → `BUILD_TESTING=ON` 配置 → `cmake --build build --parallel 2` → `QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure --timeout 60` → `QT_QPA_PLATFORM=offscreen ./build/meo-settings --smoke`；Welcome 另跑英文与 zh_CN smoke。
- 本地常有未跟踪的构建产物，提交时只 `git add` 自己改的文件。

### 4.4 OmniStore — 软件商店
- 拥有：商店/搜索/安装/更新逻辑、来源与插件模型、Python 后端/守护进程、原生 MeoUI 客户端；`legacy/flutter-ui` 仅为兼容保留，不用于新功能。
- 安装：`yay -Syu omnistore-bin`。先读：[README](https://github.com/QwQdoge/OmniStore/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/OmniStore/blob/main/AGENTS.md) · `docs/MEO_INTEGRATION.md` · `docs/NATIVE_MEOUI_FRONTEND.md` · `docs/TRANSACTION_RELEASE_CONTRACT.md` · `docs/UNIFIED_UPDATES.md`。
- 验证：Python：`cd python && python -m pytest -q`；原生 UI：按 `native-quality.yml` 用真实 MeoUI 配置 `src/native-ui/` 并构建目标 `omnistore-native`；Flutter 兼容：`cd legacy/flutter-ui && flutter pub get && flutter analyze && flutter test`。
- 发布：`native-release.yml` 产出不可变 bundle，经 meo-repo 发布 `omnistore-bin`。

### 4.5 meo-ai — AI 助手
- 拥有：助手与前端、无头助手服务、提供方/代理集成、对 System AI Router 的客户端适配；Newelle 派生引擎仅作迁移兼容。方向：云优先、一个核心、三端一致（桌面/Web/安卓）。
- 先读：[README](https://github.com/QwQdoge/meo-ai/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/meo-ai/blob/main/AGENTS.md) · `meo/docs/architecture.md` · `meo/docs/unified-platform.md` · `docs/ownership.md`。
- 验证（按改动面选）：
  - Python 兼容层：`python3 -m compileall -q src meo/service meo/system meo/adapters meo/runtime meo/tools meo/device`；`python3 meo/tools/check_headless_imports.py`；`python3 -m meo.runtime.main --self-check`；`python3 -m unittest discover -s meo/tests -p 'test_*.py' -v`
  - 桌面：`cmake -S meo -B build/meo -DMEO_UI_ROOT="${MEO_UI_ROOT:-$PWD/../MeoUI}" -DBUILD_TESTING=ON` → `cmake --build build/meo --parallel 2` → offscreen `ctest`
  - Rust：`meo/core-rs` 内 `cargo fmt --check`、`cargo clippy --locked --all-features --all-targets -- -D warnings`、`cargo test --locked --all-features`
  - UI schema：`node meo/ui-schema/generate.mjs --check`；Web：`meo/web/client` 内 `npm ci && npm run typecheck && npm test && npm run build`；安卓：`meo/android` 内 `./gradlew :app:assembleDebug`
- 发布：`release.yml` 构建 Windows（安装器+便携 zip）与安卓，挂到一个 Beta GitHub Release（默认草稿）；Linux 走 meo-repo。运行时 prompt 在 `meo/prompts/*.md`，那是程序数据，不是文档。

### 4.6 meo-login-manager — 登录管理器
- KDE Plasma Login Manager（SDDM 衍生）的展示层下游，服务/PAM/认证/会话合同保持上游。分支 **`meo/6.7`**。先读：[README](https://github.com/QwQdoge/meo-login-manager/blob/meo/6.7/README.md) · [AGENTS](https://github.com/QwQdoge/meo-login-manager/blob/meo/6.7/AGENTS.md) · `docs/MEO_FORK_POLICY.md`。
- 验证（镜像 `arch-build.yml`）：CMake/Ninja `BUILD_TESTING=ON` → 构建 → offscreen `ctest`；greeter 用 staged install + `plasma-login-greeter --test`；改了 Meo 分叉面还要 `cmake -DPROJECT_SOURCE_DIR="$PWD" -DUPSTREAM_BASE=<已评审基线> -P tests/verify-meo-fork-boundary.cmake`（不得为过测试削弱它）。真实 PAM/Wayland 登录必须在项目 VM 验证。

### 4.7 meo-repo — 软件源与发布
- 拥有：包配方 `packages/`、发布清单 `manifests/`（stable/beta/pending）、校验 `scripts/ ci/ tests/ tools/`、密钥环输入、已跟踪的仓库载荷 `x86_64/`（**不是缓存，别删**）。不拥有组件源码，不得把组件源码塞进来。
- 先读：[README](https://github.com/QwQdoge/meo-repo/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/meo-repo/blob/main/AGENTS.md) · [MEOARCH_IMPLEMENTATION_RUNBOOK](https://github.com/QwQdoge/meo-repo/blob/main/docs/MEOARCH_IMPLEMENTATION_RUNBOOK.md)（跨仓库实现与 Arch 发布的唯一可复制手册）· `docs/KEY_MANAGEMENT.md` · `docs/artifact-storage.md` · `docs/AUR.md` · `docs/ISO.md`。
- 验证（镜像 `validation.yml`）：`python -m compileall -q scripts tests` → `python -m unittest discover -s tests -v` → `find ci scripts -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n`。`repository-smoke.yml` 打的是**已发布**仓库，不当作本地验证。
- 发布（一步步）：① `python tools/release_center.py` 打开本机控制面板（只监听 localhost，不接触签名密钥/R2/Cloudflare 凭据）；② 选已评审 manifest，面板检查它已跟踪且干净并跑预检；③ 面板通过已登录的 `gh` 触发受保护的 `release.yml`（workflow_dispatch）；④ 构建、`upgrade-smoke`、安装冒烟通过后，进入 GitHub `release` Environment 签名并发布到仓库（R2）；⑤ 发布后手动触发 `repository-smoke.yml`（channel 如 `beta`）在一次性 Arch 容器里验证；⑥ `publish-aur.yml` 负责 AUR。一次只发一个候选；MeoUI 与图标先于桌面/应用，Account/Icon Studio 先于 Settings。没有明确授权不得签名、改库、发布、上传。
- 包名举例：`meoui-qml`、`meo-desktop`、`meo-settings`、`omnistore-bin`、`meo-account`、`meo-ai`、`meo-keyring`、`meo-channel-stable/beta`、`meo-core-meta`、`meo-apps-meta`、`meo-icon-studio`。

### 4.8 MeoArch-os-workspace — ISO 集成（本文件所在）
- 拥有：`meoarch-os/`（ArchISO 配置）、`installer/`、`repair/`、`ai-router/`（System AI Router）、`system-transaction/`、`scripts/`、`assets/ configs/ themes/`、跨仓库验收。不是应用单体仓库；不要复制兄弟仓库或把 airootfs 当源码。
- 在已有 Arch 上安装整套：`curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash`（`-s -- --full` 完整桌面，`--core` 仅核心，`--beta` 测试通道）。它校验并固定公钥载荷、配置签名通道、装仓库控制包，再用 pacman 装 Meo 元包；**不在客户端克隆或编译组件**。
- 先读：[docs/README.md](README.md)（文档权威顺序）· [repository-architecture.md](repository-architecture.md) · [CURRENT_MILESTONE.md](CURRENT_MILESTONE.md)（当前范围）· [product-identity.md](product-identity.md) · [system-experience-contract.md](system-experience-contract.md) · [production-readiness-matrix.md](production-readiness-matrix.md) · [iso-build.md](iso-build.md) · [vm-testing.md](vm-testing.md) · `installer/` 下各文档。
- 验证阶梯（每级只证明自己）：① 源码/静态：`python -m compileall -q installer repair`、`python -m unittest discover -s installer/tests -p 'test_*.py' -v`、`… -s repair/tests …`、受影响脚本 `bash -n`；② 组件集成：`component-build.yml` 或 `scripts/acceptance/20-build-components.sh`（需要兄弟仓库 MeoUI/meo-kde）；③ 暂存：只能用 `scripts/sync-installer-to-airootfs.sh`；④ ISO：仅在需要时构建；⑤ VM/真机：仅在被明确授权时。

### 4.9 meoarch-site — 总官网
- 拥有：`index.html styles.css app.js assets/`、`workers/paths`、生成的 `docs/` 与 `llms.txt`。语言开关 zh-CN/en，两种语言的 `data-i18n` 键必须同步。
- 先读：[README](https://github.com/QwQdoge/meoarch-site/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/meoarch-site/blob/main/AGENTS.md)。
- 本地预览：`python3 -m http.server 8000 --bind 127.0.0.1`（只证明本地渲染）。
- 新增项目卡：改 `index.html`（两个按钮：Details/Open）、`app.js` 文案键、`scripts/build_details.py` 一行，再 `python3 scripts/build_details.py`。
- 重新生成 MeoUI 文档：`python3 scripts/build_docs.py`（读 `$MEO_UI_ROOT/docs`，默认 `../MeoUI`）；**`docs/` 与 `llms.txt` 禁止手改**。
- 部署：站点本身 push 到 `main` 由 Cloudflare Pages 自动发布；Worker：`cd workers/paths && wrangler deploy`（回滚 = 删除其路由）。

### 4.10 MeoArch-os-webside — OS 官网
- 纯静态站，文案/布局/行为/资源都在这里；ISO 与安装器在 workspace。先读：[README](https://github.com/QwQdoge/MeoArch-os-webside/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/MeoArch-os-webside/blob/main/AGENTS.md)。服务于 `os.meoarch.org`，并由 `meoarch-paths` 代理到 `meoarch.org/os/`。发布与托管配置变更需明确授权。

### 4.11 meo-ai-landing — AI 落地页 Worker
- 页面文案在 `src/pages.js`，模板在 `src/index.js`，图标在 `src/icon.js`（换图标：替换 `icon.png` 后 `npm run icon`）。路由在 `wrangler.jsonc`。部署：push 到 `main` → Cloudflare Workers Builds 自动构建部署。先读：[README](https://github.com/QwQdoge/meo-ai-landing/blob/main/README.md)。

### 4.12 meo-api — 后端 API Worker
- 拓扑：`客户端 → Worker meo-api → Hyperdrive → Neon PostgreSQL`（两个库：`Meo Account`、`Meo AI`，AI 库只存账号 UUID，不复制 PII，无跨库外键）。版本化 `/v1/*` + OAuth 2.1。会员：free / plus / pro（付费结账未开通）。
- 先读：[README](https://github.com/QwQdoge/meo-api/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/meo-api/blob/main/AGENTS.md) · `docs/cloudflare-deployment.md`（部署与上线后清单）· `docs/production-status.md` · `docs/api-v1.md` · `docs/database-schema.md` · `docs/backups.md`。
- 本地验证：`npm ci` → `npm run typecheck` → `npm run test:offline`（内存 pg + token harness）→ `npm test`（含部署/MCP/模型/prompt 合同）。
- 数据库迁移（需授权）：只在进程环境里设 `ACCOUNT_DATABASE_URL`、`AI_DATABASE_URL`，运行 `npm run db:migrate`；绝不把连接串写进源码/Wrangler vars/日志/聊天。
- 部署：**只有提交信息含 `[deploy-production]` 的 push 到 `main` 才会部署**——`publish-production.yml` 依次跑模型发现测试 → `scripts/production-deploy-preflight.mjs --audit` → `npx wrangler deploy`；普通提交不会动线上。预检未过时**不要**用裸 `wrangler deploy` 绕过；以 `docs/production-status.md` 的最新线上状态为准。
- 敏感值（`BETTER_AUTH_SECRET`、`RESEND_API_KEY`、OAuth 客户端密钥等）只放 Cloudflare Worker secrets；邮件发送失败即关闭（`src/email.ts` 缺配置会拒绝），上线后要用真实邮件动作确认 Resend 出现成功的 `POST /emails`。

### 4.13 MeoArch-account — 账号站
- Flutter 客户端只和公开的 Meo Account / Meo API 边界通话；认证是 meo-api 里的 Better Auth，数据在 Neon（经 Hyperdrive）。客户端**不得**含连接串、service-role key、OAuth 密钥。
- 先读：[README](https://github.com/QwQdoge/MeoArch-account/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/MeoArch-account/blob/main/AGENTS.md) · `docs/ACCOUNT_SYSTEM_V2.md` · `docs/INTEGRATION.md` · `docs/oauth-entry.md`。
- 验证：`flutter pub get` → `dart format --output=none --set-exit-if-changed lib test` → `flutter analyze --fatal-infos --fatal-warnings` → `flutter test --coverage`；Web 外壳再跑 `flutter build web --release --dart-define=MEO_API_URL=https://api.meoarch.org --dart-define=MEO_AUTH_URL=https://account.meoarch.org --dart-define=TURNSTILE_SITE_KEY=<公开站点 key>`；`verify.yml` 是合并与部署的完整闸门。
- 部署：手动触发 `deploy.yml`（需要 `environment` 批准）→ `wrangler pages deploy build/web --project-name=meoarch-account`。未登录页面能打开不等于生产认证可用。
- 本地可能有未跟踪的 `meoarch_account.iml`、`build/`，不要 `git add -A`。

### 4.14 downloader — 下载源发现与安全重定向
- Worker + Flutter Web + Supabase schema + 镜像配置 + 命令行包装。只发现公开产物并重定向到被允许的源，**不是大文件代理**。
- 先读：[README](https://github.com/QwQdoge/downloader/blob/main/README.md) · [AGENTS](https://github.com/QwQdoge/downloader/blob/main/AGENTS.md) · `docs/deployment.md` · `docs/security-model.md` · `docs/mirror-router.md` · `docs/makepkg-source-routing.md`。
- 验证（`ci.yml`）：`npm ci` → `npm run validate:config` → `npm run validate:mirrors` → `npm run lint` → `npm run typecheck` → `npm test` → `npm run worker:types` →（部署相关）`npm run build`；Flutter：`flutter analyze --no-fatal-infos`、`flutter test`。不要为了验证源码去跑远程镜像发现/健康任务。
- 部署：push 到 `main` 跑 `deploy.yml`：全套检查 → `wrangler deploy --dry-run --env staging` → 部署 staging → 远程冒烟与验收 → 浏览器测试。cron 触发器：每 30 分钟、每 6 小时（17 分）、每天 02:43。秘密（`SUPABASE_SERVICE_ROLE_KEY`、`GITHUB_TOKEN`、`ADMIN_TOKEN`）只在 Worker secrets。

### 4.15 kde-plasma6-widgets / mrbeazleyisamazing
- `kde-plasma6-widgets`：第三方小部件集合。安装：`./install_all.sh [名称]`，单个测试 `./install_all.sh -t weather`，手动 `kpackagetool6 --type Plasma/Applet --install .`；调试 `systemctl --user restart plasma-plasmashell`、`journalctl --user -f -g plasmashell`。
- `mrbeazleyisamazing`：静态图库，`resources/manifest.json` 由 `scripts/scan_resources.py` 重新生成；改 UI 要起本地 HTTP 服务看桌面与手机宽度。

---

## 5. 端到端流程

**① 改一个应用并上线（Linux 桌面组件）**：在 `~/projects/<仓库>` 改代码 → 只跑该仓库"验证"一栏的最窄检查 → `git pull --ff-only`（远端常有别的会话在推）→ 提交 → `git push` → 若需要发布：在 meo-repo 更新/新增 manifest，用 Release Center 触发 `release.yml` → 签名发布到 `packages.meoarch.org` → 用户 `pacman -Syu` / OmniStore 更新。

**② 改网站**：meoarch-site / MeoArch-os-webside → 本地 HTTP 预览（中英文、桌面+手机宽度）→ push `main` → Pages 自动发布；改 `/os`、`/ai` 路径行为才需要 `wrangler deploy` Worker `meoarch-paths`。

**③ 改后端或账号**：meo-api 改动 → `typecheck` + `test:offline` + `npm test` → 提交信息带 `[deploy-production]` 并 push `main` → `publish-production.yml`（含预检）→ 上线后按 `docs/cloudflare-deployment.md` 清单冒烟；账号站改动 → `verify.yml` 通过 → 手动触发 `deploy.yml`。

**④ 改设计规范（MeoUI）**：只在 MeoUI `docs/design/` 改 → 更新 Showcase → 在 meoarch-site 运行 `python3 scripts/build_docs.py` 重新生成 `docs/` 与 `llms.txt` → push 两个仓库。

---

## 6. 日常操作手册（在 WSL 里执行，每条都说明作用）

```bash
# 1) 看所有仓库状态：分支、是否落后远端、有无未提交改动
cd ~/projects && for d in */; do d=${d%/}; git -C $d fetch -q; echo "$d: $(git -C $d status -sb | head -1) dirty=$(git -C $d status --porcelain | wc -l)"; done

# 2) 同步所有仓库到最新（只快进，不会覆盖本地未推送的提交）
cd ~/projects && for d in */; do git -C ${d%/} pull --ff-only -q; done

# 3) 重新生成全部 md 链接清单（改了任何文档/新增文档后执行，然后提交 MEOARCH_DOC_INDEX.md）
bash ~/projects/MeoArch-os-workspace/scripts/docs/build-meoarch-index.sh

# 4) 给所有仓库的 md 补"指回主文档"横幅（幂等，已有的不会重复加）
bash ~/projects/MeoArch-os-workspace/scripts/docs/add-master-banner.sh

# 5) 从 Windows 调用 WSL（PowerShell / Git Bash 均可）
wsl.exe -d Arch -- bash -lc 'cd ~/projects/meo-repo && git status -sb'

# 6) 读取线上 Cloudflare 清单（需要 Cloudflare 凭据/MCP，只读）
#    workers_list / r2_buckets_list / kv_namespaces_list / d1_databases_list
```

提交某个仓库的改动：`git -C ~/projects/<仓库> add <具体文件> && git -C … commit -m "…" && git -C … push`；遇到落后远端先 `pull --rebase`。有别人的未提交文件时**不要** `add -A`。

---

## 7. 维护本文件的约定

1. 新增仓库：在 §2.1 表、§4 加一节、§2.3/§2.4 补线上资源，然后运行操作手册 (3)(4)，并在新仓库的 AGENTS.md 里写入共用规则。
2. 新增/移动 md：运行 (3) 重新生成清单；新文件顶部加横幅（运行 (4)）。
3. 删除仓库：同步删除各处记录，并把它写进 §2.1 的"已废弃"。
4. 改了部署方式或线上资源：先改对应仓库的合同文档，再回来改 §2.3/§4。
5. 生成文件（meoarch-site 的 `docs/` 与 `llms.txt`、`MEOARCH_DOC_INDEX.md`）不手改；运行时 prompt（`meo/prompts/*.md`）与第三方内置文档（`*/vendor/*`、`.agents/skills/*`、`legacy/*`）不加横幅。
