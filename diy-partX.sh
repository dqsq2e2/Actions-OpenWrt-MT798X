#!/bin/bash
# 替换 daed Makefile 为官方版本（源码编译，跳过前端本地构建）
#

set -e

echo ">>> 替换 daed Makefile 为官方版本"

DAED_DIR=$(find . -path "*/daed/daed" -type d 2>/dev/null | head -n 1)

if [ -z "$DAED_DIR" ]; then
    echo "❌ 未找到 daed 目录"
    exit 1
fi

echo ">>> daed 目录: $DAED_DIR"

# 验证 files 目录
if [ ! -f "$DAED_DIR/files/daed.init" ] || [ ! -f "$DAED_DIR/files/daed.config" ]; then
    echo "❌ 缺少 files/daed.init 或 files/daed.config"
    exit 1
fi

# 直接从 ImmortalWrt 拉取官方 Makefile
curl -fsSL \
    "https://raw.githubusercontent.com/immortalwrt/packages/master/net/daed/Makefile" \
    -o "$DAED_DIR/Makefile"

# 修正 golang include 路径
sed -i 's|include ../../lang/golang/golang-package.mk|include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk|' \
    "$DAED_DIR/Makefile"

# 合并 geoip/geosite 到主依赖（luci-app-daed 只依赖 +daed）
sed -i 's|+kmod-veth$|+kmod-veth +v2ray-geoip +v2ray-geosite|' \
    "$DAED_DIR/Makefile"

# HASH 设为 skip（避免版本更新后校验失败）
sed -i 's/^PKG_MIRROR_HASH:=.*/PKG_MIRROR_HASH:=skip/' "$DAED_DIR/Makefile"
sed -i '/^[[:space:]]*HASH:=/s/HASH:=.*/HASH:=skip/' "$DAED_DIR/Makefile"

echo "✅ 官方 Makefile 已替换并适配"
echo ""
echo "   修改项："
echo "   ├── golang 路径适配 package/custom/"
echo "   ├── geoip/geosite 合并到主依赖"
echo "   └── HASH 校验跳过"
