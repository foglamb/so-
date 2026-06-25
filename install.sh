#!/bin/bash
set -e
REPO="foglamb/so-"
PY=$(python3 -c "import sys; print(f'cp{sys.version_info.major}{sys.version_info.minor}')" 2>/dev/null || echo "cp312")
ARCH=$(uname -m)
case $ARCH in
    aarch64|arm64) PLAT="linux-aarch64" ;;
    x86_64|amd64) PLAT="linux-x86_64" ;;
    *) echo "不支持: $ARCH"; exit 1 ;;
esac
cd /tmp && mkdir -p dcjz && cd dcjz
SO="dcjz_core.${PY}-${PLAT}.so"
echo "平台: $PLAT | Python: $PY"
curl -sL "https://raw.githubusercontent.com/$REPO/main/dcjz_run.py" -o dcjz_run.py
curl -sL "https://github.com/$REPO/releases/latest/download/$SO" -o "$SO"
[ -s "$SO" ] && echo "下载完成" || { echo "下载失败"; exit 1; }
python3 dcjz_run.py
