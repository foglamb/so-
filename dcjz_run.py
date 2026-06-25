#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
多财金猪脚本 - 青龙面板运行脚本
自动检测平台 → 检测版本更新 → 检查本地SO → 从GitHub下载 → 执行
"""
import os
import sys
import platform
import urllib.request
import importlib.util

GITHUB_REPO = "foglamb/so-"
SO_VERSION = "cp312"
VERSION_URL = f"https://raw.githubusercontent.com/{GITHUB_REPO}/main/version.txt"
LOCAL_VERSION_FILE = "dcjz_version.txt"


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


def get_remote_version():
    """获取远程版本号"""
    try:
        req = urllib.request.Request(VERSION_URL, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.read().decode('utf-8').strip()
    except:
        return None


def get_local_version(script_dir):
    """获取本地版本号"""
    version_file = os.path.join(script_dir, LOCAL_VERSION_FILE)
    if os.path.exists(version_file):
        try:
            with open(version_file, 'r') as f:
                return f.read().strip()
        except:
            pass
    return None


def save_local_version(script_dir, version):
    """保存本地版本号"""
    version_file = os.path.join(script_dir, LOCAL_VERSION_FILE)
    try:
        with open(version_file, 'w') as f:
            f.write(version)
    except:
        pass


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

    # 版本检测
    print("\n🔄 检查版本更新...")
    remote_version = get_remote_version()
    local_version = get_local_version(script_dir)

    print(f"   本地版本: {local_version or '未知'}")
    print(f"   远程版本: {remote_version or '获取失败'}")

    need_download = False

    if not os.path.exists(so_path):
        print("⚠️ 本地SO文件不存在，需要下载")
        need_download = True
    elif remote_version and local_version and remote_version != local_version:
        print(f"🆕 发现新版本: {local_version} -> {remote_version}，更新中...")
        need_download = True
    elif remote_version and not local_version:
        print("🆕 首次检测版本，记录当前版本")
        need_download = True
    else:
        print("✅ 版本已是最新")

    if need_download:
        print("\n📥 开始下载SO文件...")
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

        # 保存版本号
        if remote_version:
            save_local_version(script_dir, remote_version)
            print(f"  ✅ 版本已更新: {remote_version}")

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