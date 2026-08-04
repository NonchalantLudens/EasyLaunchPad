#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(grep MARKETING_VERSION project.yml | head -1 | awk '{print $2}')
OUT_DIR="build"
DERIVED="$OUT_DIR/DerivedData"
APP="$DERIVED/Build/Products/Release/LaunchPad.app"
STAGING="$OUT_DIR/dmg"
RAW_DMG="$OUT_DIR/LaunchPad-tmp.dmg"
DMG="$OUT_DIR/LaunchPad-$VERSION.dmg"
VOLNAME="LaunchPad"

xcodegen generate

# Use the first available signing identity if present, else ad-hoc.
IDENTITY=$(security find-identity -v -p codesigning 2>/dev/null | grep -oE '"[^"]+"' | head -1 | tr -d '"' || true)
SIGN_ARGS=()
if [ -n "$IDENTITY" ]; then
    SIGN_ARGS=(CODE_SIGN_IDENTITY="$IDENTITY")
    echo "Signing with: $IDENTITY"
else
    SIGN_ARGS=(CODE_SIGN_IDENTITY=-)
    echo "No signing identity found, using ad-hoc signing"
fi

xcodebuild \
    -project LaunchPad.xcodeproj \
    -scheme LaunchPad \
    -configuration Release \
    -derivedDataPath "$DERIVED" \
    "${SIGN_ARGS[@]}" \
    build >/dev/null

# 暂存内容
rm -rf "$STAGING"
mkdir -p "$STAGING/.background"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

# 生成安装页背景图（640x400 @2x）
swift scripts/make_dmg_background.swift "$STAGING/.background/install-bg.png" >/dev/null

# 原始可写镜像（用于 Finder 定制）
rm -f "$RAW_DMG"
hdiutil create -volname "$VOLNAME" -srcfolder "$STAGING" -ov -format UDRW "$RAW_DMG" >/dev/null

# 清理残留挂载
for m in $(ls -d "/Volumes/$VOLNAME"* 2>/dev/null || true); do
    hdiutil detach -force "$m" >/dev/null 2>&1 || true
done

# 定制安装页：背景图、图标位置、窗口尺寸
CUSTOMIZED=0
if osascript -e 'tell application "Finder" to count windows' >/dev/null 2>&1; then
    MOUNT_POINT=$(hdiutil attach -readwrite -noverify -noautoopen "$RAW_DMG" 2>/dev/null | grep 'Volumes' | awk '{print $NF}' || true)
    if [ -n "$MOUNT_POINT" ]; then
        # 等待 Finder 注册新卷（attach 返回后 Finder 可能尚未识别）
        REGISTERED=0
        for i in 1 2 3 4 5; do
            if osascript -e 'tell application "Finder" to get name of every disk' 2>/dev/null | grep -q "$VOLNAME"; then
                REGISTERED=1
                break
            fi
            sleep 1
        done
        if [ "$REGISTERED" -eq 1 ]; then
            if osascript <<EOF
tell application "Finder"
  tell disk "$VOLNAME"
    open
    delay 2
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {400, 150, 1040, 550}
    delay 1
    set opts to the icon view options of container window
    set arrangement of opts to not arranged
    set icon size of opts to 88
    set background picture of opts to (POSIX file "$MOUNT_POINT/.background/install-bg.png" as alias)
    set position of item "LaunchPad.app" of container window to {140, 120}
    set position of item "Applications" of container window to {420, 120}
    close
  end tell
end tell
EOF
            then
                echo "安装页已定制（背景/图标/窗口尺寸）"
                CUSTOMIZED=1
            else
                echo "Finder 定制脚本失败，使用默认布局"
            fi
        else
            echo "Finder 未识别新卷，跳过安装页定制"
        fi
        sleep 1
        hdiutil detach -force "$MOUNT_POINT" >/dev/null 2>&1 || true
    fi
else
    echo "Finder 自动化权限未授予，跳过安装页定制"
fi

# 确保卷完全卸载后再转换
for i in 1 2 3 4 5; do
    if ! ls -d "/Volumes/$VOLNAME"* >/dev/null 2>&1; then break; fi
    sleep 1
    for m in $(ls -d "/Volumes/$VOLNAME"* 2>/dev/null || true); do
        hdiutil detach -force "$m" >/dev/null 2>&1 || true
    done
done

# 压缩为最终 dmg
rm -f "$DMG"
hdiutil convert -format UDZO -o "$DMG" "$RAW_DMG" >/dev/null
rm -f "$RAW_DMG"

echo "Done: $DMG"
