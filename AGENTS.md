# AGENTS.md

## 项目

EasyLaunchPad：macOS 15+ 还原经典 Launchpad 的全屏应用启动器（Swift + SwiftUI，XcodeGen 生成项目）。

## GitHub

- 账户与提交身份等登录信息统一保存在 `~/.config/opencode/credentials.md`（权限 600，禁止提交仓库），需要时读取
- 仓库：https://github.com/NonchalantLudens/EasyLaunchPad（origin，公开，MIT 协议）
- 推送：直接 `git push`（仓库级 gh 凭据助手已配置，无需交互）

## 常用命令

```bash
# 构建
xcodegen generate
xcodebuild -project EasyLaunchPad.xcodeproj -scheme EasyLaunchPad build
# 测试
xcodebuild -project EasyLaunchPad.xcodeproj -scheme EasyLaunchPad test
# 打包 DMG（含定制安装页）
./scripts/build-dmg.sh
# 打包 PKG
pkgbuild --component build/DerivedData/Build/Products/Release/EasyLaunchPad.app \
  --install-location /Applications --version 0.1.0 \
  --identifier com.easylaunchpad.app build/EasyLaunchPad-0.1.0.pkg
```

## 发布流程（发新版时）

1. `project.yml` 更新 `MARKETING_VERSION`
2. 重新打包 DMG + PKG，记录两者 SHA-256
3. `gh release create vX.Y.Z` 上传资产，notes 附校验和
4. 更新 `Casks/e/easylaunchpad.rb` 的 `version` 与 `sha256`（Homebrew tap 指向本仓库）
5. 更新 `CHANGELOG.md`
6. `git push`（含 tag）

## 分发方式

- Homebrew：`brew tap NonchalantLudens/EasyLaunchPad <本仓库URL> && brew install --cask easylaunchpad`
- curl：`curl -fsSL <本仓库>/raw/main/scripts/install.sh | bash`
- DMG / PKG：GitHub Release 资产
