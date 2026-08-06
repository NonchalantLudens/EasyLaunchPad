# EasyLaunchPad

> [English](README.md) | [简体中文](README.zh-CN.md)

还原经典 Launchpad 的全屏应用启动器。在 macOS 15+（Launchpad 已被移除）上重新呈现老版本 Launchpad 的完整体验：全屏网格、毛玻璃背景、分页、搜索、删除模式、全局快捷键与触控板手势。

## 功能特性

- **全屏展示**：覆盖层全屏窗口，即时呼出/关闭（无 Space 切换延迟）
- **经典视觉**：模糊壁纸背景 + 渐变暗层、多页网格、分页圆点
- **应用管理**：自动扫描 `/Applications`、`/System/Applications`、`~/Applications`，支持手动添加、隐藏（可恢复）、移入废纸篓
- **实时搜索**：输入即过滤，匹配高亮
- **全局快捷键**：默认 F4 呼出/关闭，可在设置中自定义（支持冲突检测）
- **键盘导航**：方向键移动选择、左右键切换页面、回车打开、Esc 退出
- **触控板手势**：两指/三指滑动或滚轮切换页面（带档位防抖）、捏合关闭
- **删除模式**：按住 Option 图标抖动 + 删除徽标
- **个性化**：4 级图标大小、图标入场动画开关、系统应用显示开关
- **多显示器**：按鼠标所在屏幕呼出，全屏尺寸精确

## 系统要求

- macOS 15.0 及以上
- Apple Silicon 或 Intel

## 安装

任选其一：

- **Homebrew**（推荐）：cask 定义随源码维护在本仓库
  ```bash
  brew tap NonchalantLudens/EasyLaunchPad https://github.com/NonchalantLudens/EasyLaunchPad.git
  brew install --cask easylaunchpad
  ```
- **curl 脚本**：自动下载最新版、校验 SHA-256 并安装到 /Applications
  ```bash
  curl -fsSL https://raw.githubusercontent.com/NonchalantLudens/EasyLaunchPad/main/scripts/install.sh | bash
  ```
- **DMG**：从 [Releases](https://github.com/NonchalantLudens/EasyLaunchPad/releases) 下载，拖入「应用程序」文件夹
- **PKG 安装包**：从 Releases 下载，双击按向导安装

按 **F4**（或自定义快捷键）呼出 Launchpad。

> 开机自启动需将应用安装在 `/Applications` 后，在 设置 → 通用 → 登录时自动启动 中开启。

## 故障排查

### 「Apple 无法检查 EasyLaunchPad 是否包含恶意软件」/「无法验证开发者」

应用暂未公证（需要 Developer ID 证书），Gatekeeper 可能在首次打开时拦截。解决方法任选其一：

1. 在「应用程序」文件夹中**右键点击**（或按住 Control 点击）EasyLaunchPad → 选择**打开** → 在弹窗中点击**打开**
2. 或前往**系统设置 → 隐私与安全性** → 在应用旁点击**仍要打开**
3. 或在终端移除隔离属性：

```bash
xattr -dr com.apple.quarantine /Applications/EasyLaunchPad.app
```

> 通过 Homebrew 安装（`brew install --cask easylaunchpad`）不受影响。

## 使用指南

| 操作 | 方式 |
|---|---|
| 呼出 / 关闭 | F4 或自定义全局快捷键；点击菜单栏图标 |
| 打开应用 | 点击图标 / 选中后回车 |
| 切换页面 | 左右方向键 / 两指滑动 / 滚轮（带档位防抖） |
| 搜索 | 直接输入文字（无需点击搜索框）/ Cmd+F 聚焦 |
| 删除模式 | 按住 Option → 图标抖动 → 点击 × → 隐藏或移入废纸篓 |
| 关闭 | Esc / 点击空白区域 |

## 构建

```bash
# 生成 Xcode 项目并构建
xcodegen generate
xcodebuild -project EasyLaunchPad.xcodeproj -scheme EasyLaunchPad build

# 打包 DMG（含定制安装页面）
./scripts/build-dmg.sh

# 打包 PKG 安装包
pkgbuild --component build/DerivedData/Build/Products/Release/EasyLaunchPad.app \
  --install-location /Applications --version 0.1.0 \
  --identifier com.easylaunchpad.app build/EasyLaunchPad-0.1.0.pkg
```

## 项目结构

```
Sources/
├── Models/        # AppItem、IconSizeLevel
├── Services/      # 应用扫描、窗口控制、热键、图标/壁纸缓存
├── Settings/      # 设置模型与持久化
└── Views/         # SwiftUI 界面
Tests/             # 单元测试
scripts/           # 打包与图标生成脚本
```

## 许可

[MIT](LICENSE) © 2026 NonchalantLudens
