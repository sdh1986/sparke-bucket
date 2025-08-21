# sparke-bucket

日常工作常用软件的 Scoop bucket，提供便捷的软件包管理。

## 🚀 特性

- **自动化更新**: 通过 GitHub Actions 自动检查和更新软件版本
- **格式验证**: 自动验证 manifest 文件格式和有效性
- **本地脚本**: 提供本地更新脚本，方便手动检查和更新

## 📦 包含的软件

| 软件 | 描述 | 版本 |
|------|------|------|
| [PixPin](https://pixpin.cn/) | 功能强大使用简单的截图/贴图工具 | 2.0.0.3 |
| [小鱼易连](https://www.xylink.com/) | 小鱼易连会议软件 | 3.8.0.12067 |
| [小鱼易连 (非便携版)](https://www.xylink.com/) | 小鱼易连会议软件 (非便携版) | 3.10.10.27298 |

## 🔧 安装和使用

### 添加 bucket

```powershell
scoop bucket add sparke-bucket https://github.com/your-username/sparke-bucket
```

### 安装软件

```powershell
# 安装 PixPin
scoop install sparke-bucket/pixpin

# 安装小鱼易连
scoop install sparke-bucket/xylink

# 安装小鱼易连 (非便携版)
scoop install sparke-bucket/xylink-np
```

## 🤖 自动化功能

### GitHub Actions 工作流

本项目配置了两个自动化工作流：

1. **自动更新检查** (`.github/workflows/checkver.yml`)
   - 每天凌晨1点和下午1点自动检查软件更新
   - 支持手动触发
   - 自动提交更新到仓库

2. **格式验证** (`.github/workflows/validate.yml`)
   - 在 Pull Request 和推送时验证 manifest 格式
   - 检查必需字段和格式规范
   - 测试安装流程

### 本地更新脚本

项目提供了本地更新脚本 `scripts/update-manifests.ps1`：

```powershell
# 检查所有软件更新
.\scripts\update-manifests.ps1

# 仅检查不更新 (干运行模式)
.\scripts\update-manifests.ps1 -DryRun

# 更新特定软件
.\scripts\update-manifests.ps1 -App pixpin
```

## 📋 开发指南

### 添加新软件

1. 在 `bucket/` 目录下创建新的 `.json` 文件
2. 确保包含以下必需字段：
   - `version`: 软件版本
   - `description`: 软件描述
   - `homepage`: 官方网站
   - `url`: 下载链接
   - `hash`: 文件哈希值

3. 添加 `checkver` 和 `autoupdate` 配置以支持自动更新

### 示例 manifest

```json
{
  "version": "1.0.0",
  "description": "软件描述",
  "homepage": "https://example.com",
  "license": "MIT",
  "url": "https://example.com/download/app-1.0.0.zip",
  "hash": "sha256-hash-here",
  "checkver": {
    "url": "https://example.com/download",
    "regex": "download/app-([\\d.]+)\\.zip"
  },
  "autoupdate": {
    "url": "https://example.com/download/app-$version.zip"
  }
}
```

## 🔄 自动化流程

1. **定时检查**: GitHub Actions 每天自动检查软件更新
2. **版本检测**: 使用 `checkver` 配置检测最新版本
3. **自动更新**: 发现新版本时自动更新 manifest 文件
4. **格式验证**: 确保更新后的文件格式正确
5. **自动提交**: 将更新提交到仓库

## 📊 状态

![GitHub Actions](https://github.com/your-username/sparke-bucket/workflows/Check%20Version%20and%20Update/badge.svg)
![Validation](https://github.com/your-username/sparke-bucket/workflows/Validate%20Manifests/badge.svg)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- 参考了 [dorado](https://github.com/chawyehsu/dorado) 项目的自动化配置
- 感谢 [Scoop](https://scoop.sh/) 项目提供的包管理工具
