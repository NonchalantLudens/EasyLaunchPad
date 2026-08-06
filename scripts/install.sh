#!/bin/bash
# EasyLaunchPad 安装脚本
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/NonchalantLudens/EasyLaunchPad/main/scripts/install.sh | bash
#   curl -fsSL ... | bash -s -- --version 0.1.0
set -euo pipefail

REPO="NonchalantLudens/EasyLaunchPad"
APP_NAME="EasyLaunchPad.app"
INSTALL_DIR="/Applications"
VERSION=""

for arg in "$@"; do
    case "$arg" in
        --version=*) VERSION="${arg#*=}" ;;
        --version) ;;
    esac
done

# 解析下一个参数作为版本号
ARGS=("$@")
for i in "${!ARGS[@]}"; do
    if [ "${ARGS[$i]}" = "--version" ] && [ $((i + 1)) -lt ${#ARGS[@]} ]; then
        VERSION="${ARGS[$((i + 1))]}"
    fi
done

echo "==> 获取 EasyLaunchPad 最新版本信息…"
if [ -n "$VERSION" ]; then
    API="https://api.github.com/repos/$REPO/releases/tags/v$VERSION"
else
    API="https://api.github.com/repos/$REPO/releases/latest"
fi

RELEASE_JSON=$(curl -fsSL "$API" || { echo "错误: 无法获取 release 信息（版本 $VERSION）"; exit 1; })

DMG_URL=$(printf '%s' "$RELEASE_JSON" | grep -o '"browser_download_url": *"[^"]*\.dmg"' | head -1 | sed 's/.*"browser_download_url": *"\([^"]*\)"/\1/')
EXPECTED_SHA=$(printf '%s' "$RELEASE_JSON" | grep -o '"digest": *"[^"]*"' | head -1 | sed 's/.*"digest": *"sha256:\([^"]*\)"/\1/')

if [ -z "$DMG_URL" ]; then
    echo "错误: 未找到 DMG 资产"
    exit 1
fi

echo "==> 下载: $DMG_URL"
TMP_DIR=$(mktemp -d)
trap 'hdiutil detach "$TMP_DIR/mnt" -quiet 2>/dev/null || true; rm -rf "$TMP_DIR"' EXIT
curl -fsSL "$DMG_URL" -o "$TMP_DIR/install.dmg"

if [ -n "$EXPECTED_SHA" ]; then
    echo "==> 校验 SHA-256…"
    echo "$EXPECTED_SHA  $TMP_DIR/install.dmg" | shasum -a 256 -c - >/dev/null || {
        echo "错误: SHA-256 校验失败"
        exit 1
    }
fi

echo "==> 挂载并安装…"
mkdir -p "$TMP_DIR/mnt"
hdiutil attach -nobrowse -quiet "$TMP_DIR/install.dmg" -mountpoint "$TMP_DIR/mnt"

if [ ! -d "$TMP_DIR/mnt/$APP_NAME" ]; then
    echo "错误: DMG 中未找到 $APP_NAME"
    exit 1
fi

rm -rf "$INSTALL_DIR/$APP_NAME"
cp -R "$TMP_DIR/mnt/$APP_NAME" "$INSTALL_DIR/"
hdiutil detach "$TMP_DIR/mnt" -quiet

echo "==> 完成"
echo "已安装到 $INSTALL_DIR/$APP_NAME"
echo "按 F4（或自定义快捷键）呼出 Launchpad。"
