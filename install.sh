#!/bin/bash
# 一键下载运行脚本
# 使用方法: curl -sL https://raw.githubusercontent.com/foglamb/so-/main/install.sh | bash

set -e

REPO="foglamb/so-"
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}{sys.version_info.minor}')" 2>/dev/null || echo "312")
ARCH=$(uname -m)

case $ARCH in
    aarch64|arm64)
        PLATFORM="linux-aarch64"
        ;;
    x86_64|amd64)
        PLATFORM="linux-x86_64"
        ;;
    *)
        echo "❌ 不支持的架构: $ARCH"
        exit 1
        ;;
esac

WORK_DIR="/tmp/dcjz_so"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

PYTHON_ABI="cp${PYTHON_VERSION}"
SO_FILE="dcjz_core.${PYTHON_ABI}-${PLATFORM}.so"
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${SO_FILE}"

echo "🔍 平台: $PLATFORM"
echo "🔍 Python: $PYTHON_VERSION"
echo "📥 下载: $SO_FILE"

# 下载run.py
curl -sL "https://raw.githubusercontent.com/${REPO}/main/run.py" -o run.py

# 下载.so文件
if curl -sL "$DOWNLOAD_URL" -o "$SO_FILE" && [ -s "$SO_FILE" ]; then
    echo "✅ 下载完成"
else
    echo "⚠️  从Releases下载失败，尝试从仓库直接下载..."
    curl -sL "https://raw.githubusercontent.com/${REPO}/main/${SO_FILE}" -o "$SO_FILE"
fi

# 检查文件
if [ ! -s "$SO_FILE" ]; then
    echo "❌ 下载失败，请检查网络或手动下载"
    exit 1
fi

echo "🚀 启动脚本..."
python3 run.py