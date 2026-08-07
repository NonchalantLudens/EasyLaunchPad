# 贡献指南

欢迎贡献！请遵循以下约定。

## 开发环境

- macOS 15.0+，Xcode 26+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（生成 Xcode 项目）

## 开发流程

1. Fork 本仓库并克隆
2. 创建功能分支：`git checkout -b feat/your-feature`
3. 修改代码，保持既有风格（Swift + SwiftUI，见下方结构约定）
4. 运行测试：`xcodebuild -project EasyLaunchPad.xcodeproj -scheme EasyLaunchPad test`
5. 提交（遵循提交信息规范），推送并创建 Pull Request

## 提交信息规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 风格。

### 格式

```
<type>(<scope>): <description>

<可选正文：说明动机与影响>

<可选 footer：BREAKING CHANGE / 关联 issue>
```

### 类型（type）

| 类型 | 用途 | 示例 |
|---|---|---|
| `feat` | 新功能 | `feat: 增加图标大小分级设置` |
| `fix` | 缺陷修复 | `fix: 修复隐藏应用不实时刷新` |
| `perf` | 性能优化 | `perf: 目录扫描移至后台队列` |
| `refactor` | 重构（不改行为） | `refactor: 统一更名为 EasyLaunchPad` |
| `docs` | 文档（含 README/About 信息） | `docs: 补充 README 安装说明` |
| `test` | 测试 | `test: 新增分页边界用例` |
| `chore` | 构建/工具/杂项 | `chore: 更新 .gitignore` |
| `icon` | 图标资源 | `icon: app.svg 增加内边距` |
| `tweak` | 微调（动画参数等） | `tweak: 切页动画缩短至 0.18s` |
| `release` | 版本发布（版本号/打包/发布同步） | `release: v0.2.0` |

### 范围（scope，可选）

指向改动模块：`controller`、`catalog`、`settings`、`view`、`grid`、`scripts`、`cask`、`readme` 等。

### 描述要求

- 祈使句、简洁（建议 ≤ 72 字符）、说明"做了什么"而非"怎么做"
- 中文或英文均可，与正文语言保持一致；项目默认中文
- 描述不要以句号结尾

### 示例

```
feat(settings): 增加「显示系统应用」开关
fix(controller): 修复退出动画黑屏闪烁
perf(catalog): 目录扫描移至后台并合并刷新
docs: 补充 Homebrew 安装方式
```

### 破坏性变更

行为不兼容时在 footer 注明：

```
refactor!: bundle ID 更改为 com.easylaunchpad.app

BREAKING CHANGE: 变更 Bundle Identifier，旧安装需先卸载
```

### 与发布的关系

- `feat` / `fix` 提交应在发布时同步更新 `CHANGELOG.md`
- 发布新版时 tag 格式：`v<MAJOR>.<MINOR>.<PATCH>`（见 AGENTS.md 发布流程）

## Release 发布规范

发版操作统一使用 `release` 类型提交（`release: vX.Y.Z`），并遵循 AGENTS.md 发布流程。版本发布涉及以下文件的同步更新：

| 文件 | 同步内容 | 变更类型 |
|---|---|---|
| `project.yml` | `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` | `release` |
| `CHANGELOG.md` | 新增版本条目（语义化版本） | 随 `release` 提交 |
| `Casks/e/easylaunchpad.rb` | `version` 与 `sha256`（DMG 校验和） | `chore(cask)` |
| Release 资产 | DMG / PKG 重新打包上传，notes 附 SHA-256 | `gh release` |
| tag | `v<MAJOR>.<MINOR>.<PATCH>`，指向发布提交 | `git tag` |

### 发布提交要求

- 版本号与 tag 三者一致：`MARKETING_VERSION`、`CHANGELOG` 条目、tag 名
- Release notes 必须包含：功能亮点、安装方式、DMG 与 PKG 的 SHA-256 校验和
- 打包产物（DMG/PKG）不入库（`build/` 已忽略），仅通过 Release 资产分发
- 发布后验证：`brew install --cask easylaunchpad` 与 `scripts/install.sh` 均可安装新版本

### 重新打包后必须同步

应用打包产物变更后，以下内容必须同步，否则安装校验失败：

- `Casks/e/easylaunchpad.rb` 的 `sha256`（与新版 DMG 一致）
- Release notes 中的校验和
- 若 About 页含版本相关静态信息，同步更新（见下方 About 规范）

## About 关于页规范

关于页信息（`Sources/Views/AboutSettingsView.swift`）与项目元数据保持一致：

| 信息 | 数据源 | 同步要求 |
|---|---|---|
| 应用名称 | 静态文本 | 与项目名一致（EasyLaunchPad） |
| 版本 / 构建号 | Bundle 动态读取 | 自动同步，无需手动维护 |
| 仓库链接 | 静态 URL | 仓库迁移/改名时同步更新 |
| 版权行 | 静态文本 | 与 `LICENSE`、`project.yml` 的 `NSHumanReadableCopyright` 三者一致 |

### 约定

- 版权行格式：`© <年份> <作者>`；年份变更或作者变更时，**三处同步**：`AboutSettingsView`、`project.yml`（`NSHumanReadableCopyright`）、`LICENSE`
- 仓库 URL 变更时同步：`AboutSettingsView` 链接、`Casks` 的 `url`/`homepage`、`scripts/install.sh` 的 `REPO`、README 全部链接
- About 页信息变更使用 `docs(about)` 提交，并重新打包同步 Release 资产

## README 规范

涉及 `README.md` 的改动（`docs(readme)`）必须遵循以下排版约定，中英两版（`README.md` / `README.zh-CN.md`）同步修改：

### 结构

```
# 项目名
> slogan（一句话简介）
[徽章行]（license / macOS / Swift / Release，shields.io）
[语言切换链接]（[English](README.md) | [简体中文](README.zh-CN.md)）
[简介段落]
## 目录（Table of Contents，锚点链接，与下文章节一一对应）
## 功能特性（要点列表，**加粗标题** — 描述 格式）
## 系统要求（表格：项目/要求 两列）
## 安装（分层小节：Homebrew → curl 脚本 → DMG/PKG；代码块带 bash 标注）
## 使用指南（表格：操作/方式 两列）
## 故障排查（H3 子标题 + 有序列表）
## 从源码构建（bash 代码块，含测试与打包命令）
## 项目结构（text 代码块树）
## 参与贡献（链接 CONTRIBUTING.md）
## 许可（[MIT](LICENSE) © 年份 作者）
```

### 约定

- **徽章行**：置于标题与简介之间，使用 shields.io 静态徽章，主仓库必含 license 与 Release 徽章
- **语言版本**：`README.md` 为英文主版本（GitHub 默认渲染），`README.zh-CN.md` 为中文版；两版章节结构完全对应，顶部互相链接
- **表格**：需表头与对齐分隔行（`| --- |`），单元格内容不换行
- **代码块**：一律标注语言（`bash` / `text`）
- **中文版格式**：标题层级与英文一致；技术名词保留英文原词

## 代码结构约定

```
Sources/
├── Models/        # 数据模型（AppItem、IconSizeLevel）
├── Services/      # 业务逻辑（扫描、窗口控制、热键、缓存）——不与 UI 耦合
├── Settings/      # 设置模型与 UserDefaults 持久化
└── Views/         # SwiftUI 视图——只做展示与事件转发
Tests/             # 与 Sources 对应的单元测试
scripts/           # 构建/打包/资源生成脚本
```

## 测试要求

- 纯逻辑（分页数学、布局常量、持久化）必须附带单元测试
- 提交前确保 `xcodebuild test` 全部通过

## 打包验证

改动影响发布流程时，运行 `./scripts/build-dmg.sh` 验证 DMG 可正常生成。
