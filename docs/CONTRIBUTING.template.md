# 贡献指南（通用模板）

> 本文件是跨项目通用的贡献规范模板，源自 [EasyLaunchPad](https://github.com/NonchalantLudens/EasyLaunchPad) 的 CONTRIBUTING.md。
> 其它项目复制本文件为 `CONTRIBUTING.md`，替换以下占位符：
> - `{{PROJECT_NAME}}`：项目名
> - `{{BUNDLE_ID}}`：应用 Bundle Identifier（若为应用项目）
> - `{{YEAR}}` / `{{AUTHOR}}`：版权年份与作者

## 开发流程

1. Fork 本仓库并克隆
2. 创建功能分支：`git checkout -b feat/your-feature`
3. 修改代码，保持既有风格
4. 运行测试（见项目 README 或 AGENTS.md 的测试命令）
5. 提交（遵循下方提交信息规范），推送并创建 Pull Request

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
| `feat` | 新功能 | `feat: 增加 xxx 功能` |
| `fix` | 缺陷修复 | `fix: 修复 xxx 问题` |
| `perf` | 性能优化 | `perf: 优化 xxx 性能` |
| `refactor` | 重构（不改行为） | `refactor: 重构 xxx 模块` |
| `docs` | 文档（含 README/About 信息） | `docs: 补充 xxx 说明` |
| `test` | 测试 | `test: 新增 xxx 用例` |
| `chore` | 构建/工具/杂项 | `chore: 更新依赖` |
| `icon` | 图标资源 | `icon: 更新应用图标` |
| `tweak` | 微调（动画参数等） | `tweak: 调整 xxx 参数` |
| `release` | 版本发布（版本号/打包/发布同步） | `release: v0.2.0` |

### 范围（scope，可选）

指向改动模块：`controller`、`settings`、`view`、`scripts`、`cask`、`readme` 等，按项目实际情况取模块名。

### 描述要求

- 祈使句、简洁（建议 ≤ 72 字符）、说明"做了什么"而非"怎么做"
- 中文或英文均可，与正文语言保持一致；中文项目默认中文
- 描述不要以句号结尾

### 破坏性变更

行为不兼容时在 footer 注明：

```
refactor!: 变更 xxx 接口

BREAKING CHANGE: 说明不兼容影响与迁移方式
```

### 与发布的关系

- `feat` / `fix` 提交应在发布时同步更新 `CHANGELOG.md`
- 发布新版时 tag 格式：`v<MAJOR>.<MINOR>.<PATCH>`（见项目 AGENTS.md 发布流程）

## Release 发布规范

发版操作统一使用 `release` 类型提交（`release: vX.Y.Z`），并遵循项目 AGENTS.md 发布流程。版本发布涉及以下文件的同步更新：

| 文件 | 同步内容 | 变更类型 |
|---|---|---|
| 版本配置（如 `project.yml` 的 `MARKETING_VERSION`） | 版本号 / 构建号 | `release` |
| `CHANGELOG.md` | 新增版本条目（语义化版本） | 随 `release` 提交 |
| 分发配置（如 Homebrew `Casks`） | `version` 与校验和 | `chore(cask)` |
| Release 资产 | 安装包重新打包上传，notes 附校验和 | `gh release` |
| tag | `v<MAJOR>.<MINOR>.<PATCH>`，指向发布提交 | `git tag` |

### 发布提交要求

- 版本号与 tag 三者一致：版本配置、`CHANGELOG` 条目、tag 名
- Release notes 必须包含：功能亮点、安装方式、各安装包的校验和（SHA-256），**中英双语**（见下方双语规范）
- 打包产物不入库（加入 `.gitignore`），仅通过 Release 资产分发
- 发布后验证：所有安装方式均可安装新版本

### 重新打包后必须同步

打包产物变更后，以下内容必须同步，否则安装校验失败：

- 分发配置（如 `Casks`）中的校验和
- Release notes 中的校验和
- 若 About 页含版本相关静态信息，同步更新（见下方 About 规范）

## About 关于页规范

关于页信息与项目元数据保持一致：

| 信息 | 数据源 | 同步要求 |
|---|---|---|
| 应用名称 | 静态文本 | 与项目名一致（{{PROJECT_NAME}}） |
| 版本 / 构建号 | Bundle 动态读取 | 自动同步，无需手动维护 |
| 仓库链接 | 静态 URL | 仓库迁移/改名时同步更新 |
| 版权行 | 静态文本 | 与 `LICENSE`、平台版权配置三者一致 |

### 约定

- 版权行格式：`© <年份> <作者>`；年份或作者变更时，**多处同步**：About 页、平台版权配置（如 `NSHumanReadableCopyright`）、`LICENSE`
- 仓库 URL 变更时同步：About 页链接、分发配置（`Casks` 的 `url`/`homepage`）、安装脚本中的 `REPO`、README 全部链接
- About 页信息变更使用 `docs(about)` 提交，并重新打包同步 Release 资产
- About 页文案**中英双语**（见下方双语规范）

## 双语规范（通用标准）

> 面向用户的内容必须中英双语覆盖；内部技术文档（本文档、AGENTS.md 等）默认中文，不受本条约束。

### 适用范围

以下内容**必须**中英双语：

| 内容 | 形式 | 要求 |
|---|---|---|
| `README.md` | 双文件 | 英文主版 + `README.zh-CN.md` 中文版，结构对应、顶部互链（见 README 规范） |
| About 页 | 双语文案 | 描述文案中英并列，或按系统语言本地化（String Catalog / `Localizable.strings`） |
| Release notes | 双语文案 | 功能亮点、安装方式、校验和说明使用中英双语段落 |
| `CHANGELOG.md` | 双语摘要 | 每个版本条目提供中英双语标题与摘要（如 `### 新增 / Added`） |
| 用户可见 UI 文案 | 本地化 | 遵循平台本地化机制（macOS: String Catalog；Web: i18n） |

### 约定

- 英文为主版本、中文为翻译版，两版内容必须同步，改动时同时提交
- 技术名词（Live Photo、RAW、Bundle ID、GitHub 等）保留英文原词，不翻译
- 名称与固定格式（应用名、`© <年份> <作者>` 版权行、校验和）不参与翻译
- 提交信息语言与正文语言一致（见提交信息规范），不受本条约束

## README 规范

涉及 `README.md` 的改动（`docs(readme)`）必须遵循以下排版约定；中英两版（`README.md` / `README.zh-CN.md`）同步修改。

### 结构

```
# 项目名
> slogan（一句话简介）
[徽章行]（license / 平台 / 语言 / Release，shields.io）
[语言切换链接]（[English](README.md) | [简体中文](README.zh-CN.md)）
[简介段落]
## 目录（Table of Contents，锚点链接，与下文章节一一对应）
## 功能特性（要点列表，**加粗标题** — 描述 格式）
## 系统要求（表格：项目/要求 两列）
## 安装（分层小节，代码块带语言标注）
## 使用指南（表格：操作/方式 两列）
## 故障排查（H3 子标题 + 有序列表）
## 构建（代码块，含测试与打包命令）
## 项目结构（text 代码块树）
## 参与贡献（链接 CONTRIBUTING.md）
## 许可（[MIT](LICENSE) © 年份 作者）
```

### 约定

- **徽章行**：置于标题与简介之间，使用 shields.io 静态徽章，主仓库必含 license 与 Release 徽章
- **语言版本**：`README.md` 为英文主版本（GitHub 默认渲染），`README.zh-CN.md` 为中文版；两版章节结构完全对应，顶部互相链接
- **表格**：需表头与对齐分隔行（`| --- |`），单元格内容不换行
- **代码块**：一律标注语言（`bash` / `text` 等）
- **中文版格式**：标题层级与英文一致；技术名词保留英文原词

## 测试要求

- 纯逻辑必须附带单元测试
- 提交前确保项目测试命令全部通过

## 模板来源

本模板维护于 [EasyLaunchPad/docs/CONTRIBUTING.template.md](https://github.com/NonchalantLudens/EasyLaunchPad/blob/main/docs/CONTRIBUTING.template.md)。规范更新时以该文件为准，各项目复制后按需裁剪。
