# FMoment

Windows 一站式截图贴图 + 取色配色工具

## 功能特性

- **截图**：全局热键（PrintScreen / Alt+A）唤起，支持选区、全屏、窗口三种截图模式，截图后自动打开标注编辑器
- **增强标注**：矩形、箭头、文字、高亮、马赛克等标注工具，支持撤销/重做
- **悬浮贴图**：截图转为置顶悬浮窗口，支持缩放、透明度调节、鼠标穿透模式
- **专业像素取色**：Win32 API 实时屏幕取色，鼠标跟随放大镜，HEX / RGB / HSL 一键复制，取色历史记录
- **渐变编辑器**：线性 / 径向渐变，角度控制，色标编辑，CSS 代码导出
- **色彩合规检测**：计算前景/背景对比度，校验 WCAG AA / AAA 无障碍标准，提供优化建议
- **色卡管理**：分组 / 色卡 / 颜色三级 CRUD，SQLite 持久化存储，JSON 导入 / 导出

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
git clone https://github.com/1624318455/FMoment.git

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
