# FMoment 架构文档

## 分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer (Widgets)                      │
├─────────────────────────────────────────────────────────────┤
│                   Feature Layer (Features)                   │
├─────────────────────────────────────────────────────────────┤
│                  Platform Layer (Platform)                   │
├─────────────────────────────────────────────────────────────┤
│                     Data Layer (Data)                        │
└─────────────────────────────────────────────────────────────┘
```

## 依赖方向

```
UI → Feature → Platform → Data
         ↓
    Utils (Color)
```

- **UI Layer**: 纯渲染组件，无业务逻辑
- **Feature Layer**: 功能模块，组合 Platform 和 Data
- **Platform Layer**: Windows 原生通道封装
- **Data Layer**: 数据库操作、Repository
- **Utils**: 工具函数（色彩算法等）

## 目录结构

```
lib/
├── main.dart              # 应用入口
├── app/                   # 应用配置、路由、主题
│   ├── app.dart
│   └── home_page.dart
├── features/              # 功能模块
│   ├── screenshot/        # 截图功能
│   ├── color_picker/      # 取色功能
│   ├── gradient/          # 渐变编辑器
│   ├── color_card/        # 色卡管理
│   ├── annotation/        # 标注工具
│   └── settings/          # 设置页面
├── platform/              # Windows 原生通道
│   └── platform_service.dart
├── data/                  # 数据层
│   └── database.dart
├── utils/                 # 工具函数
│   └── color/             # 色彩算法
│       └── color_utils.dart
└── widgets/               # 通用组件
```

## 状态管理

使用 Riverpod 进行状态管理：

- **StateNotifier**: 管理复杂状态
- **Provider**: 提供依赖注入
- **ConsumerWidget**: 在 Widget 中消费状态

## 数据库设计

### 表结构

1. **color_group**: 色卡分组
2. **color_card**: 色卡
3. **color_item**: 颜色项
4. **config**: 配置

### 关系

- color_card.group_id → color_group.id (一对多)
- color_item.card_id → color_card.id (一对多)

## 平台通道

使用成熟插件实现 Windows 原生功能：

- **screen_retriever**: 屏幕捕获、像素取色
- **screen_capturer**: 快速截图
- **hotkey_manager**: 全局热键
- **window_manager**: 窗口管理
- **system_tray**: 系统托盘
