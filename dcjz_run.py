#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
多财金猪脚本 - 青龙面板运行脚本
自动检测平台 → 检查本地SO → 从GitHub下载 → 执行
"""
import os
import sys
import platform
import urllib.request
import importlib.util

GITHUB_REPO = "foglamb/so-"
SO_VERSION = "cp312"

def detect_platform():
    arch = platform.machine().lower()
    if arch in ['aarch64', 'arm64']:
        return "linux-aarch64"
    elif arch in ['x86_64', 'amd64']:
        return "linux-x86_64"
    return f"linux-{arch}"

def download_file(url, dest):
    try:
        urllib.request.urlretrieve(url, dest)
        return True
    except Exception as e:
        print(f"    ❌ {e}")
        return False

def main():
    print("=" * 50)
    print("🔒 多财金猪脚本 - SO加密版本")
    print("=" * 50)

    if not os.environ.get("dcjz"):
        print("\n❌ 请设置环境变量 dcjz")
        print("格式：备注#token#device_id#brand_model#brand#model")
        return

    platform_name = detect_platform()
    so_name = f"dcjz_core.{SO_VERSION}-{platform_name}.so"
    script_dir = os.path.dirname(os.path.abspath(__file__))
    so_path = os.path.join(script_dir, so_name)

    print(f"\n🔍 平台: {platform_name}")
    print(f"🔍 SO文件: {so_name}")

    if os.path.exists(so_path):
        print("✅ 本地已存在SO文件")
    else:
        print("⚠️ 本地不存在，从GitHub下载...")
        urls = [
            f"https://github.com/{GITHUB_REPO}/releases/latest/download/{so_name}",
            f"https://raw.githubusercontent.com/{GITHUB_REPO}/main/{so_name}",
        ]
        ok = False
        for i, url in enumerate(urls, 1):
            print(f"  📥 尝试 {i}/{len(urls)}...")
            if download_file(url, so_path):
                print("  ✅ 下载成功")
                ok = True
                break
        if not ok:
            print(f"❌ 下载失败: https://github.com/{GITHUB_REPO}/releases")
            return

    print("\n🚀 加载加密模块...")
    try:
        spec = importlib.util.spec_from_file_location("dcjz_core", so_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        if hasattr(module, 'main'):
            print("✅ 启动脚本\n")
            module.main()
        else:
            print("❌ 模块中没有main函数")
    except Exception as e:
        print(f"❌ 加载失败: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()