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
| `docs` | 文档 | `docs: 补充 README 安装说明` |
| `test` | 测试 | `test: 新增分页边界用例` |
| `chore` | 构建/工具/杂项 | `chore: 更新 .gitignore` |
| `icon` | 图标资源 | `icon: app.svg 增加内边距` |
| `tweak` | 微调（动画参数等） | `tweak: 切页动画缩短至 0.18s` |

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
