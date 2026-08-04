# LaunchPad 还原应用 — 设计文档

日期: 2026-08-04
状态: 已确认

## 1. 目标

在 macOS 15 (Sequoia) 及以上系统构建一个原生应用，还原老版本 Launchpad 的全屏展示形式：经典网格 + 毛玻璃 + 分页圆点 + 缩放入场动画，并支持应用的添加/删除（隐藏 + 移入废纸篓）、全局快捷键和触控板手势。

## 2. 技术决策

| 决策点 | 选择 | 理由 |
|---|---|---|
| 技术栈 | Swift + SwiftUI | 原生性能，动画/毛玻璃/手势支持完整 |
| 目标系统 | macOS 15+ | Sequoia 已移除 Launchpad，是主要动机 |
| 还原风格 | 经典网格 + 毛玻璃（Lion/Mountain Lion 风格） | 全屏网格 + 分页圆点 + 搜索框 + 抖动删除模式 |
| 分发 | 直接分发（非沙盒） | 允许 CGEventTap、Accessibility 权限、文件删除 |
| 窗口方案 | 全屏 Space 窗口 | 最还原原版沉浸感 |
| 项目生成 | XcodeGen | 项目文件可版本控制、可命令行生成 |
| 应用列表 | LSApplicationWorkspace 扫描 + 文件系统兜底 + 手动添加 | 覆盖全部已注册应用，私有 API 失败可回退 |
| 删除语义 | 隐藏（不删文件）+ 移入废纸篓两种模式 | 安全且实用 |

## 3. 架构

```
LaunchPad (Swift + SwiftUI, macOS 15+, 非沙盒)
├── App 入口        — @main, 激活策略 .accessory（无 Dock 图标）+ 菜单栏图标
├── AppCatalog      — 应用扫描与缓存
│   ├── LSApplicationWorkspace (私有 API) 扫描全部已注册应用
│   ├── 文件系统兜底扫描 /Applications、~/Applications
│   └── 手动添加（NSOpenPanel 选择 .app）→ 存 UserDefaults 别名列表
├── GridEngine      — 纯函数分页逻辑：根据屏幕尺寸计算每页行列数、图标布局、分页
├── LaunchPadWindow — 全屏 Space 窗口（.fullScreenUI 材质毛玻璃）
├── 视图层          — SearchBarView / GridPageView / IconTileView / PageDotsView
├── ShortcutManager — 全局热键（Carbon RegisterEventHotKey）+ 窗口内 NSEvent 快捷键
├── GestureManager  — 窗口内 magnify/swipe 手势识别
├── TrashService    — 移入废纸篓（NSWorkspace.trashItem）
├── Settings        — 偏好设置窗（热键自定义、手势开关、开机自启 SMAppService）
└── Persistence     — UserDefaults：隐藏应用列表、手动添加列表、设置
```

### 核心数据流

- **扫描**: AppCatalog 启动时 + 应用变更时（KVO NSWorkspace didLaunch/didTerminate + 定时刷新）扫描 → 合并"自动发现 + 手动添加"，排除"隐藏列表" → 按名称排序
- **分页**: `GridEngine.pages(apps, screenSize)` → `[Page(apps)]`，每页 `ceil(宽/140) × ceil(高/150)` 个
- **呈现**: 打开 LaunchPad 时先建全屏窗口 → 缩放动画入场 → 图标交错淡入 → 手势/热键关闭时反向动画

## 4. 功能清单

| 功能 | 实现要点 |
|---|---|
| 全屏还原 | 全屏 Space + 毛玻璃材质 + 缩放入场动画（仿 genie 效果） |
| 搜索 | 顶部搜索栏，实时过滤网格 + 高亮匹配，Cmd+F 聚焦 |
| 打开应用 | 点击/回车 → NSWorkspace.open + 关闭 LaunchPad |
| 删除模式 | 按住 Option → 图标抖动（jiggle 动画）+ 徽标按钮；点击 → 选择"隐藏"或"移入废纸篓" |
| 手动添加 | 菜单栏"添加应用…"→ NSOpenPanel 选 .app；拖拽 .app 到菜单栏图标 |
| 快捷键 | 全局热键（默认 F4，可自定义）、方向键/回车/Esc/Cmd+F/Cmd+数字切页 |
| 手势 | 窗口内：两指/三指左右滑切页、捏合缩放关闭（系统保留的四指缩合无法捕获，以全局热键替代） |
| 菜单栏 | 图标点击呼出/关闭、添加应用、偏好设置、退出 |
| 自启动 | SMAppService.mainApp 登录启动，开机即可用热键 |
| 偏好设置 | 热键录制、手势开关、删除默认行为、开机自启开关 |

## 5. 风险与对策

- **全局四指缩合不可捕获**（系统保留给 Mission Control）→ 以热键 + 窗口内捏合手势补偿，设置中明确提示
- **私有 API LSApplicationWorkspace** 可能随系统版本变化 → 加文件系统扫描兜底，API 调用做 try/catch
- **全屏 Space 切换延迟** → 预创建窗口 + NSAnimationContext 控制动画时长

## 6. 测试策略

- 单元测试: 分页数学、目录解析、隐藏列表持久化
- UI 测试: 热键呼出/关闭、搜索过滤、删除模式
- 手动测试矩阵: 不同分辨率/外接屏、深色模式

## 7. 里程碑

1. 脚手架 + 应用扫描 + 全屏窗口 + 全局热键
2. 网格 + 分页 + 选择 + 打开应用
3. 搜索 + 入场/退场动画
4. 删除模式（隐藏/废纸篓）+ 手动添加 + 持久化
5. 手势 + 偏好设置 + 开机自启
6. 签名公证 + dmg 打包
