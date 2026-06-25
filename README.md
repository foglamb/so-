# 多财金猪脚本 - SO加密版本

## 🔒 超级加密
Python脚本通过Cython编译为.so二进制文件，源码完全不可见。

## 🚀 青龙面板一键运行
```bash
curl -sL https://raw.githubusercontent.com/foglamb/so-/main/install.sh | bash
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

## 🖥️ 支持平台
| 平台 | 状态 |
|------|------|
| ARM64 (aarch64) | ✅ |
| x86_64 (AMD64) | ✅ |

## 📊 加密等级
- Cython编译: Python → C → .so二进制
- 源码保护: 无法从.so提取Python源码
- 反编译难度: 需要逆向工程ARM汇编才能分析
