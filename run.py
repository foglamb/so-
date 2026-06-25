#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
多财金猪脚本 - SO加密版本启动器
从GitHub下载.so文件后运行
"""
import os
import sys
import platform
import importlib.util

def detect_platform():
    """检测平台架构"""
    arch = platform.machine()
    py_version = f"{sys.version_info.major}{sys.version_info.minor}"
    
    if arch in ['aarch64', 'arm64']:
        return f"linux-aarch64", py_version
    elif arch in ['x86_64', 'amd64']:
        return f"linux-x86_64", py_version
    else:
        return f"linux-{arch}", py_version

def main():
    print("🔒 多财金猪脚本 - SO加密版本")
    print("=" * 50)
    
    # 检查环境变量
    if not os.environ.get("dcjz"):
        print("❌ 请设置环境变量 dcjz")
        print("格式：备注#token#device_id#brand_model#brand#model")
        print("示例：test#token123#device123#Redmi#Xiaomi#RedmiNote12")
        print("")
        print("如需推送通知，可设置环境变量：QMSG_KEY")
        return
    
    # 检测平台
    platform_name, py_version = detect_platform()
    print(f"✅ 平台: {platform_name}")
    print(f"✅ Python: {py_version}")
    
    # 查找.so文件
    so_files = [
        f"dcjz_core.cpython-{py_version}-{platform_name}.so",
        "dcjz_simple_cython.cpython-312-aarch64-linux-gnu.so",
        "dcjz_core.so",
    ]
    
    so_file = None
    for f in so_files:
        if os.path.exists(f):
            so_file = f
            break
    
    if not so_file:
        print(f"❌ 找不到SO文件")
        print(f"   请确保已下载适合当前平台的.so文件")
        print(f"   当前需要: cpython-{py_version}-{platform_name}")
        return
    
    print(f"✅ 找到SO文件: {so_file}")
    print("🚀 正在加载加密模块...\n")
    
    try:
        # 动态加载.so模块
        spec = importlib.util.spec_from_file_location(
            "dcjz_encrypted",
            so_file
        )
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        
        # 调用main函数
        if hasattr(module, 'main'):
            module.main()
        else:
            print("❌ SO模块中没有找到main函数")
    except Exception as e:
        print(f"❌ 加载SO模块失败: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()