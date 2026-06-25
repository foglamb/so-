#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
多财金猪脚本 - 本地运行版本
自动检测平台，从GitHub下载.so文件并执行
"""
import os
import sys
import platform
import urllib.request
import importlib.util

GITHUB_REPO = "foglamb/so-"

def detect_platform():
    """检测平台架构"""
    arch = platform.machine()
    py_ver = f"{sys.version_info.major}.{sys.version_info.minor}"
    py_abi = f"cp{sys.version_info.major}{sys.version_info.minor}"
    
    if arch in ['aarch64', 'arm64']:
        platform_name = "linux-aarch64"
    elif arch in ['x86_64', 'amd64']:
        platform_name = "linux-x86_64"
    else:
        platform_name = f"linux-{arch}"
    
    return platform_name, py_abi

def get_so_filename(py_abi, platform_name):
    """生成.so文件名"""
    return f"dcjz_core.{py_abi}-{platform_name}.so"

def download_file(url, dest):
    """下载文件"""
    print(f"📥 下载: {url}")
    try:
        urllib.request.urlretrieve(url, dest)
        return True
    except Exception as e:
        print(f"❌ 下载失败: {e}")
        return False

def main():
    print("🔒 多财金猪脚本 - 本地运行版")
    print("=" * 50)
    
    # 检查环境变量
    if not os.environ.get("dcjz"):
        print("❌ 请设置环境变量 dcjz")
        print("格式：备注#token#device_id#brand_model#brand#model")
        print("示例：test#token123#device123#Redmi#Xiaomi#RedmiNote12")
        print("")
        print("设置方法:")
        print('  export dcjz="备注#token#device_id#brand_model#brand#model"')
        return
    
    # 检测平台
    platform_name, py_abi = detect_platform()
    print(f"✅ 平台: {platform_name}")
    print(f"✅ Python: {py_abi}")
    
    # 生成.so文件名
    so_filename = get_so_filename(py_abi, platform_name)
    so_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), so_filename)
    
    print(f"✅ SO文件: {so_filename}")
    
    # 检查本地是否已有.so文件
    if os.path.exists(so_path):
        print(f"✅ 本地已存在: {so_path}")
    else:
        print(f"⚠️ 本地不存在，尝试从GitHub下载...")
        
        # 尝试多个下载地址
        download_urls = [
            f"https://github.com/{GITHUB_REPO}/releases/latest/download/{so_filename}",
            f"https://raw.githubusercontent.com/{GITHUB_REPO}/main/{so_filename}",
        ]
        
        downloaded = False
        for url in download_urls:
            if download_file(url, so_path):
                downloaded = True
                break
        
        if not downloaded:
            print(f"❌ 下载失败，请手动下载 {so_filename}")
            print(f"   地址: https://github.com/{GITHUB_REPO}/releases")
            return
    
    print(f"\n🚀 正在加载SO模块...")
    
    try:
        # 动态加载.so模块
        spec = importlib.util.spec_from_file_location("dcjz_core", so_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        
        # 调用main函数
        if hasattr(module, 'main'):
            print("✅ 加载成功，启动脚本...\n")
            module.main()
        else:
            print("❌ SO模块中没有找到main函数")
            print(f"   模块内容: {dir(module)}")
    except Exception as e:
        print(f"❌ 加载SO模块失败: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()