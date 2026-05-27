# FMoment

Windows 一站式截图贴图 + 取色配色工具

## 功能特性

- **截图与悬浮贴图**：全局热键唤起，支持选区/全屏/窗口截图，截图可置顶悬浮
- **专业像素取色**：屏幕全局吸色、多点连续取色，一键导出 HEX/RGB/HSL
- **配色与渐变**：自动生成互补色、邻近色、暗黑主题配色，内置渐变编辑器
- **色彩合规检测**：计算前景与背景色对比度，校验 WCAG 无障碍标准
- **色卡管理**：保存取色记录为色卡，支持分组、收藏、批量导出
- **增强标注**：箭头、图形、文字、高亮、马赛克等标注工具

## 技术栈

- **框架**：Flutter Windows Desktop
- **状态管理**：Riverpod
- **本地数据库**：Sqflite
- **系统能力**：Windows 原生通道插件

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.12.0
- Windows 10/11

### 安装

```bash
# 克隆项目
git clone https://github.com/memeflyfly/FMoment.git

# 进入项目目录
cd FMoment

# 安装依赖
flutter pub get

# 运行项目
flutter run -d windows
```

### 设置 Git Hooks

```bash
# 运行设置脚本
./scripts/setup-hooks.sh
```

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── app/                   # 应用配置、路由、主题
├── features/              # 功能模块
│   ├── screenshot/        # 截图功能
│   ├── color_picker/      # 取色功能
│   ├── gradient/          # 渐变编辑器
│   ├── color_card/        # 色卡管理
│   ├── annotation/        # 标注工具
│   └── settings/          # 设置页面
├── platform/              # Windows 原生通道
├── data/                  # 数据层
├── utils/                 # 工具函数
└── widgets/               # 通用组件
```

## 开发规范

- 遵循 Flutter 编码规范
- 使用 Riverpod 进行状态管理
- 逻辑与视图分离
- 平台 API 统一封装
- 禁止硬编码

## 文档

- [架构文档](docs/architecture.md)
- [安全规范](docs/security.md)
- [评估体系](docs/evaluation-framework.md)
- [Flutter 编码规范](docs/flutter-guidelines.md)

## 许可证

MIT License
