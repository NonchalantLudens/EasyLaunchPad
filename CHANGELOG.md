# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [2.5.2] - 2026-09

### Summary / 摘要

The background slider is now transparency-based with a live style preview in Settings; the menu bar panel reliably toggles closed on a second click; clicking an icon shows a flash feedback before launching. / 背景滑条改为透明度语义并在设置页提供样式预览；菜单栏面板二次点击可靠关闭；点击图标先闪光反馈再启动。

### 新增 / Added

- 设置 → 显示：「背景暗度」更名为「**背景透明度**」（0% = 最暗，100% = 完全透明，默认 65%），并新增**样式预览**卡片，滑动实时预览压暗效果；自动迁移旧设置值 / The background slider is now "Background Transparency" with a live preview card; old values migrate automatically
- 点击图标后先**闪光反馈**再淡出启动，点击命中一目了然 / Clicking an icon flashes it before launching for clear hit feedback

### 修复 / Fixed

- 菜单栏图标**第二次点击可靠关闭面板**：以面板实际可见性为切换依据，并对按下/抬起的重复触发去抖 / A second click on the menu bar icon now reliably closes the panel: toggling is based on actual panel visibility with double-fire debounce

## [2.5.1] - 2026-09

### Summary / 摘要

Arrow keys now move the selected app icon across the grid (page-crossing included); a background dim slider is added to Settings. / 方向键改为在网格中移动选中的应用图标（可跨页）；设置页新增背景暗度滑条。

### 新增 / Added

- 设置 → 显示：新增「背景暗度」滑条（0–100%，默认 35%），实时生效并持久化 / Settings → Display: new background dim slider (0–100%, default 35%), live and persisted

### 变更 / Changed

- 方向键行为调整：左右上下键改为移动选中的图标（高亮框跟随，跨页自动翻页）；Enter 打开、Esc 退出不变；触控板/滚轮/分页圆点切页方式不变 / Arrow keys now move the selected icon (highlight follows, crossing pages auto-flips); Enter to open and Esc to close unchanged; trackpad/wheel/page-dot paging unchanged

## [2.5.0] - 2026-09

### Summary / 摘要

Displaced icons now slide with transition animation during drag; page dots are clickable to jump to a page; menu bar update status shows inline in the check-for-updates row and auto-reverts after informational results. / 拖动时被挤占的图标新增滑动过渡动画；底部分页圆点支持点击跳页；菜单栏更新状态改为行内展示且信息性结果自动复原。

### 新增 / Added

- 点击底部分页圆点直接跳转到对应分页 / Click a page dot to jump to that page
- 拖动图标时被挤占的图标以滑动过渡动画补位（被拖图标仍即时贴合指针） / Displaced icons slide into place during drag while the dragged icon stays glued to the pointer
- 菜单栏「检查更新」状态行内展示：检查中转圈、已是最新 / 失败短暂显示后自动复原；发现新版本时该行变为「下载并安装 vX」，下载进度百分比行内显示，不再占用独立行 / Menu bar update status is inline in the check row and auto-reverts after informational results; when an update is available the row becomes the install action

## [2.4.2] - 2026-09

### Summary / 摘要

Fixed the app quitting when the launcher hides, the repeated "access data from other apps" permission prompt, first-launch not showing the launcher, and rebuilt icon dragging with simpler and exact pointer tracking. / 修复启动器隐藏后 App 退出、每次启动弹「访问其他 App 数据」权限、首次启动不出全屏的问题；以更简单的实现重建图标拖拽。

### 修复 / Fixed

- 点击空白处隐藏启动器后 App 不再退出：声明「最后窗口关闭不终止」，恢复 Settings 场景 / The app no longer quits when the launcher hides: declares "don't terminate after last window closed" and restores the Settings scene
- 不再弹出「访问其他 App 的数据」权限：移除壁纸文件读取管线（系统动态壁纸资产属于受保护数据，每次启动读取都会触发 TCC 弹窗），背景改用系统毛玻璃材质（GPU 直接对桌面实时模糊，零文件访问） / Removes the repeated "access data from other apps" prompt: the wallpaper file pipeline is gone (system wallpaper assets are protected data); the background now uses the native material blur (GPU-composited, zero file access)
- 首次启动直接呼出全屏启动器（登录自启场景除外） / The launcher opens fullscreen on first manual launch (except login-item launches)

### 性能 / Performance

- 壁纸不再解码 + 高斯模糊（每次启动的 CIImage 管线删除），呼出更轻快 / No more per-launch wallpaper decode + Gaussian blur; snappier open
- 拖动跟随偏移改为图块局部状态：指针移动只重渲染被拖图块，不再整网格刷新；边缘翻页仅在进入/离开边缘区域时写入状态 / Drag follow offset is now tile-local state: pointer moves re-render only the dragged tile; page-flip state writes only on edge-zone enter/leave

### 变更 / Changed

- 图标拖拽实现大幅简化：删除悬浮层与跨坐标空间换算机制；拖动中的图标以固定抓取偏移瞬时跟随指针（换位无动画，指针与图标始终贴合） / Icon dragging greatly simplified: the floating overlay and cross-space conversion mechanism are gone; the dragged icon tracks the pointer instantly with a constant grab offset (instant reordering, pointer always aligned)

## [2.4.1] - 2026-09

### Summary / 摘要

Fixed the Settings window failing to open from the menu bar panel, and fixed the dragged icon drifting out from under the pointer during icon rearrangement. / 修复应用未激活时菜单面板中的「偏好设置」无法打开设置窗口的问题；修复拖动图标时图标与指针错位的问题。

### 修复 / Fixed

- 设置窗口改由 AppKit 直接持有（与启动器窗口同模式），`orderFrontRegardless` 兜底置前，不再依赖应用激活状态；已通过合成点击端到端验证 / Settings window is now owned by AppKit (same pattern as the launcher window) with `orderFrontRegardless` fallback; verified end-to-end via synthesized clicks
- 拖动图标不再与指针错位：拖动中的图标改为独立悬浮层即时跟随指针，抓取偏移全程保持（抓哪算哪，不再跳到指针下居中），网格换位动画与其解耦；拖动中的原位图块隐形留空 / Dragged icon no longer drifts from the pointer: it is rendered in a separate overlay that tracks the pointer instantly with a constant grab offset (no more snap-to-center), fully decoupled from the grid reordering animation; the original tile is hidden while dragging

## [2.4.0] - 2026-09

### Summary / 摘要

Icons can now be dragged to rearrange (with page-flip at screen edges, order persisted); fixed the launch overlay freezing on top of dialogs; reworked the menu bar panel interaction; About page simplified. / 图标支持拖拽排序（边缘翻页、顺序持久化）；修复启动遮罩卡住盖住弹窗的问题；重构菜单栏面板交互；简化关于页。

### 新增 / Added

- 图标拖拽排序：拖动图标换位，其余图标滑动补位；拖到屏幕左右边缘停留自动翻页，可跨页移动；顺序持久化，重启保留 / Drag to rearrange icons with slide-aside animation, page auto-flip at screen edges, cross-page moves, and persisted order
- 新增 GridGeometry 网格几何计算与应用排序逻辑，配套单元测试 / New GridGeometry hit-testing and app ordering logic with unit tests

### 修复 / Fixed

- 点击应用后不再卡住：先淡出窗口再异步启动应用，目标应用启动慢或弹出对话框时不再被全屏遮罩盖住 / Launching an app no longer freezes the overlay: the window fades out first and the app is opened asynchronously, so slow launches or dialogs are no longer covered
- 菜单栏面板重构：改用 NSStatusItem + 非激活面板，点击外部自动收起，条目点击后自动收起 / Menu bar panel reworked with NSStatusItem + non-activating panel; auto-dismisses on outside click and after item actions
- 「偏好设置」经常无响应已修复（先激活应用再打开设置窗口）/ Preferences now opens reliably (activates the app first)
- 「检查更新」在菜单面板内原地展示状态（检查/结果/下载进度/安装/失败重试），不再弹出独立窗口 / "Check for Updates" now shows its status inline in the panel instead of opening a separate window
- 菜单条目样式统一（悬停高亮一致）/ Menu item styles unified with consistent hover highlighting

### 变更 / Changed

- 关于页移除 GitHub 链接 / About page: removed the GitHub link

## [2.3.0] - 2026-08

### Summary / 摘要

Fixed the auto-update install step failing with "an item with the same name already exists" when a legacy backup folder exists in /Applications. / 修复 /Applications 存在历史备份目录时自更新安装报「同名条目已存在」的问题。

### 修复 / Fixed

- 自动更新安装：备份目录名唯一化（UUID 后缀），不再与历史遗留的固定名备份冲突；安装成功后尽力清理历史遗留备份 / Auto-update install: the backup folder name is now unique (UUID suffix), no longer colliding with legacy fixed-name backups; legacy backups are cleaned up best-effort after install

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
