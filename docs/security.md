# FMoment 安全规范

## 安全等级

**Standard** - 文件系统 + 网络边界管控

## 文件系统边界

### 可读目录
- `workspace/` - 工作区
- `config/` - 配置文件
- `docs/` - 文档
- `logs/` - 日志
- `static/` - 静态资源

### 可写目录
- `workspace/` - 工作区
- `logs/` - 日志
- `tmp/` - 临时文件

### 禁止访问
- 系统目录（Windows、System32 等）
- 隐藏文件（.git、.env 等）
- 项目外敏感路径

## 网络出口

### 白名单配置
网络请求必须在 `config/network-allowlist.json` 中配置：

```json
{
  "allowed_hosts": [],
  "blocked_hosts": [],
  "timeout_ms": 5000
}
```

### 请求头规范
所有网络请求必须包含 User-Agent：
```
User-Agent: FMoment-Agent/1.0
```

## 敏感操作

以下操作需要用户确认或自动拒绝：

- 删除文件
- `git push --force`
- 修改门禁配置
- 访问系统目录

## 权限分级

### Planner（规划者）
- 只读访问 `docs/`、`config/`

### Coder（编码者）
- 读写 `workspace/`
- 网络白名单内请求

### Reviewer（审查者）
- 只读访问
- 可执行 lint/test

## 数据安全

### 本地数据
- 数据库文件存储在用户文档目录
- 配置文件存储在应用数据目录
- 临时文件使用后及时清理

### 敏感信息
- 禁止在代码中硬编码密钥
- 禁止在日志中记录敏感信息
- 禁止在版本控制中提交 .env 文件

## 代码安全

### 输入验证
- 所有用户输入必须验证
- 文件路径必须规范化
- 颜色值必须在有效范围内

### 资源管理
- 文件句柄及时关闭
- 数据库连接及时释放
- 内存使用设置上限
