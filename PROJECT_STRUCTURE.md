# 项目结构说明

```
sparke-bucket/
├── .github/
│   ├── workflows/
│   │   ├── checkver.yml          # 自动更新检查工作流
│   │   └── validate.yml          # 格式验证工作流
│   └── auto-update-config.json   # 自动化配置文件
├── bucket/
│   ├── pixpin.json              # PixPin 软件配置
│   ├── xylink.json              # 小鱼易连软件配置
│   └── xylink-np.json           # 小鱼易连非便携版配置
├── scripts/
│   └── update-manifests.ps1     # 本地更新脚本
├── README.md                    # 项目说明文档
└── PROJECT_STRUCTURE.md         # 本文件
```

## 自动化配置说明

### GitHub Actions 工作流

#### 1. checkver.yml - 自动更新检查
- **触发条件**: 
  - 定时触发 (每天凌晨1点和下午1点)
  - 手动触发
  - 推送 bucket 目录下的文件时
- **功能**:
  - 自动检查所有 manifest 文件的新版本
  - 更新发现的新版本
  - 自动提交更改到仓库
  - 生成更新摘要

#### 2. validate.yml - 格式验证
- **触发条件**:
  - Pull Request 时
  - 推送 bucket 目录下的文件时
- **功能**:
  - 验证 JSON 格式
  - 检查必需字段
  - 测试安装流程
  - 提供详细的错误和警告信息

### 本地脚本

#### update-manifests.ps1
- **功能**: 本地手动检查和更新软件版本
- **参数**:
  - `-DryRun`: 仅检查不更新
  - `-App`: 指定特定软件
- **特性**:
  - 彩色输出
  - 详细的更新摘要
  - 交互式提交选项

### 配置文件

#### auto-update-config.json
- **用途**: 集中管理自动化设置
- **包含**:
  - 更新计划配置
  - 通知设置
  - 验证选项
  - Git 配置

## 工作流程

1. **定时检查**: GitHub Actions 按计划自动运行
2. **版本检测**: 使用 Scoop 的 checkver 脚本检测新版本
3. **自动更新**: 发现新版本时自动更新 manifest 文件
4. **格式验证**: 确保更新后的文件格式正确
5. **自动提交**: 将更改提交到仓库
6. **状态报告**: 生成详细的更新摘要

## 扩展建议

1. **添加更多软件**: 在 bucket 目录下添加新的 .json 文件
2. **自定义验证规则**: 修改 validate.yml 添加特定的验证逻辑
3. **通知集成**: 可以添加 Slack、Discord 等通知渠道
4. **性能优化**: 对于大量软件，可以考虑并行处理
5. **备份策略**: 添加自动备份机制

## 故障排除

### 常见问题

1. **更新失败**: 检查 checkver 配置是否正确
2. **格式错误**: 使用 validate 工作流检查格式
3. **权限问题**: 确保 GitHub Actions 有写入权限
4. **网络问题**: 检查下载链接是否可访问

### 调试方法

1. 查看 GitHub Actions 日志
2. 使用本地脚本进行测试
3. 检查 manifest 文件的 checkver 配置
4. 验证下载链接的有效性
