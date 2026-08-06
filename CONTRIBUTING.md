# 贡献指南

欢迎贡献！请遵循以下约定。

## 开发环境

- macOS 15.0+，Xcode 26+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（生成 Xcode 项目）

## 开发流程

1. Fork 本仓库并克隆
2. 创建功能分支：`git checkout -b feat/your-feature`
3. 修改代码，保持既有风格（Swift + SwiftUI，见下方结构约定）
4. 运行测试：`xcodebuild -project LaunchPad.xcodeproj -scheme LaunchPad test`
5. 提交（遵循提交信息规范），推送并创建 Pull Request

## 提交信息规范

使用 Conventional Commits 风格，前缀：`feat` / `fix` / `perf` / `docs` / `refactor` / `chore` / `test` / `icon`。

示例：

```
feat: 增加 xxx 功能
fix: 修复 xxx 问题
perf: 优化 xxx 性能
```

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
