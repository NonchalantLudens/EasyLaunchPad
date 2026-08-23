# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [2.2.0] - 2026-08

### Summary / 摘要

Reworked update UX: the menu panel stays clean, "Check for Updates" opens a dedicated update window with full status flow; menu items now have hover highlighting. / 重做更新交互：菜单面板保持简洁，「检查更新…」打开独立更新窗口展示完整状态流转；菜单项新增悬停高亮。

### 新增 / Added

- 独立更新窗口：点击「检查更新…」弹出「软件更新」界面，完整展示检查中 / 已是最新 / 发现新版本（安装按钮）/ 下载进度条 / 安装中 / 失败重试 / Dedicated update window: "Check for Updates…" opens a Software Update panel showing checking, up-to-date, new version with install, download progress bar, installing, and retry
- 菜单栏面板项悬停高亮效果 / Hover highlighting for menu bar panel items

### 修复 / Fixed

- 版本状态不再内联在菜单面板中，避免覆盖「检查更新」入口 / Version status no longer inlined in the menu panel (it previously covered the check-for-updates entry)

## [2.1.0] - 2026-08

### Summary / 摘要

Update experience overhaul: inline update status in the menu bar panel, real download progress bar, and retry on failure. / 更新体验全面改进：菜单栏面板内联更新状态、下载真实进度条、失败重试。

### 新增 / Added

- 菜单栏面板内联展示更新状态：检查中 / 已是最新 / 发现新版本（一键安装）/ 下载进度条 / 安装中 / 失败原因与重试，不再点击后无反馈 / Menu bar panel now shows update status inline: checking, up-to-date, new version with one-click install, download progress bar, installing, and failure reason with retry
- 下载更新改为真实进度条：基于 URLSession 委托的实时字节进度（百分比 + 进度条），菜单面板与设置页同步显示 / Download now shows a real progress bar: live byte-level progress via URLSession delegate (percentage + bar), synced in both the menu panel and Settings

## [2.0.0] - 2026-08

### 变更

- 版本号修正：Info.plist 引用 `MARKETING_VERSION`（此前被写死为 1.0）
- 关于页：仓库链接文案更新（验证自动更新链路）

## [0.1.0] - 2026-08

首个公开版本。基于 macOS 15+ 还原经典 Launchpad 体验。

### 新增

- 全屏覆盖层窗口：即时呼出/关闭，无 Space 切换延迟
- 模糊壁纸背景（`NSWorkspace.desktopImageURL` + CIFilter 高斯模糊）+ 渐变暗层
- 应用扫描：`/Applications`、`/System/Applications`（可开关）、`~/Applications`，按 bundle ID 去重
- 多页网格 + 分页圆点 + 平滑切页动画（0.18s）
- 实时搜索：输入即过滤 + 匹配高亮
- 全局快捷键（默认 F4）：Carbon `RegisterEventHotKey`，设置页录制器 + 冲突检测
- 键盘导航：方向键 / 左右切页 / Home-End / 回车打开 / Esc 退出
- 触控板手势：滑动与滚轮切页（档位防抖）、捏合关闭
- 删除模式：Option 抖动 + 徽标 → 隐藏 / 移入废纸篓
- 隐藏应用管理（菜单栏子菜单 + 设置页），持久化于 UserDefaults
- 手动添加应用（NSOpenPanel）
- 设置页：热键录制、手势开关、自启动（SMAppService）、4 级图标大小、图标入场动画开关、系统应用开关、关于页
- 点击空白区域退出
- 多显示器支持：按鼠标所在屏幕呼出

### 性能

- 目录扫描后台化 + 刷新合并（同事件循环去重）
- 图标异步加载 + 启动预热（NSCache 有界缓存）
- 壁纸模糊一次性缓存
- 窗口级 alpha 淡入淡出（单一 GPU 合成）
- 图标入场动画（逐行弹性上弹）可开关

### 打包与发布

- `scripts/build-dmg.sh`：Release 构建 + 签名 + 定制安装页 DMG
- 应用图标（app.svg 全套尺寸）
- MIT 许可

[0.1.0]: https://github.com/NonchalantLudens/EasyLaunchPad/releases/tag/v0.1.0
