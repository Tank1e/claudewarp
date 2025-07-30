# 发布到PyPI的步骤

## 准备工作

1. 安装构建工具：
```bash
pip install build twine
```

2. 注册PyPI账号：
   - 访问 https://pypi.org/account/register/
   - 创建账号并验证邮箱

## 构建包

1. 清理旧的构建文件：
```bash
rm -rf build/ dist/ *.egg-info/
```

2. 构建包：
```bash
python -m build
```

这将在 `dist/` 目录下生成：
- `claudewarpcli-1.0.0.tar.gz` (源码包)
- `claudewarpcli-1.0.0-py3-none-any.whl` (wheel包)

## 发布到PyPI

### 方式1：使用twine（推荐）

1. 上传到TestPyPI（测试环境）：
```bash
python -m twine upload --repository testpypi dist/*
```

2. 测试安装：
```bash
pip install --index-url https://test.pypi.org/simple/ claudewarpcli
```

3. 上传到正式PyPI：
```bash
python -m twine upload dist/*
```

### 配置API令牌

1. 在PyPI账户设置中创建API令牌
2. 配置.pypirc文件：

```ini
[distutils]
index-servers = 
    pypi
    testpypi

[pypi]
  username = __token__
  password = your-api-token-here

[testpypi]
  repository = https://test.pypi.org/legacy/
  username = __token__
  password = your-test-token-here
```

## 版本管理

使用bumpversion管理版本：

```bash
# 升级补丁版本
bumpversion patch

# 升级次要版本
bumpversion minor

# 升级主要版本
bumpversion major
```

## 发布清单

- [ ] 更新版本号
- [ ] 更新CHANGELOG.md
- [ ] 运行测试确保通过
- [ ] 构建包
- [ ] 上传到TestPyPI测试
- [ ] 上传到正式PyPI
- [ ] 创建GitHub Release
- [ ] 更新文档

## 注意事项

- 确保所有测试通过
- 验证包的完整性
- 检查依赖关系
- 确认版本号正确
- 备份重要配置