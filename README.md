# 多财金猪脚本 - SO加密版本

## 🔒 超级加密保护

Python脚本通过Cython编译为.so二进制文件，源码完全不可见。

## 📦 文件说明

| 文件 | 说明 |
|------|------|
| `dcjz_core.pyx` | Cython源码（加密核心） |
| `setup.py` | 编译脚本 |
| `run.py` | 启动器（自动检测平台并加载.so） |
| `.github/workflows/build.yml` | GitHub Actions自动编译 |

## 🚀 使用方法

### 方法1：直接下载编译好的.so文件

1. 从Releases下载适合你平台的.so文件
2. 运行：
   ```bash
   python3 run.py
   ```

### 方法2：自己编译（推荐）

```bash
# 安装依赖
pip install cython setuptools requests

# 编译
python3 setup.py build_ext --inplace

# 运行
python3 run.py
```

### 方法3：GitHub Actions自动编译

Push tag后自动编译多平台版本：
```bash
git tag v1.0.0
git push origin v1.0.0
```

## 📝 环境变量

在青龙面板设置：
```
dcjz = 备注#token#device_id#brand_model#brand#model
```

可选推送通知：
```
QMSG_KEY = 你的Qmsg密钥
```

## 🖥️ 支持的平台

| Python版本 | aarch64 (ARM64) | x86_64 (AMD64) |
|-----------|----------------|----------------|
| 3.10 | ✅ | ✅ |
| 3.11 | ✅ | ✅ |
| 3.12 | ✅ | ✅ |

## ⚠️ 注意事项

- .so文件是平台相关的，必须匹配操作系统和Python版本
- `run.py`会自动检测平台并加载对应的.so文件
- 如果找不到对应的.so文件，会提示错误

## 📊 加密等级

- **Cython编译**: Python → C → .so二进制
- **源码保护**: 无法从.so提取Python源码
- **反编译难度**: 需要逆向工程才能分析