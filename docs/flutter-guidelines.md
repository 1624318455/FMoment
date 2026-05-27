# Flutter 编码规范

## Widget 规范

### 构造函数
- 使用 `const` 构造函数
- 使用 `super.key` 参数
- 使用 `required` 标记必需参数

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}
```

### 无业务逻辑
- Widget 仅负责渲染与事件转发
- 禁止在 Widget 中包含业务逻辑、数据处理、API 调用
- 业务逻辑放在 Feature 层或 Provider 中

## 状态管理

### Riverpod 规范
- 使用 `StateNotifier` 管理复杂状态
- 使用 `Provider` 提供依赖注入
- 使用 `ConsumerWidget` 在 Widget 中消费状态

```dart
// 定义 StateNotifier
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
}

// 定义 Provider
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// 在 Widget 中使用
class CounterWidget extends ConsumerWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

### 禁止 setState 异步操作
- 禁止在 `setState` 中执行异步操作
- 异步操作放在 Provider 或 Service 中

## 性能优化

### 列表优化
- 使用 `ListView.builder` 构建列表
- 使用 `const` 构造函数
- 使用 `RepaintBoundary` 优化重绘

### 动画优化
- 使用 `AnimationController` 管理动画
- 在 `dispose` 中释放动画资源
- 使用 `TickerProviderStateMixin` 提供 Ticker

### 内存优化
- 及时释放资源（数据库连接、流订阅等）
- 使用 `dispose` 方法清理资源
- 避免内存泄漏

## 代码风格

### 命名规范
- 类名：PascalCase
- 变量/方法：camelCase
- 常量：camelCase（Dart 风格）
- 文件名：snake_case

### 注释规范
- 公共 API 必须有文档注释
- 复杂逻辑必须有行内注释
- 避免无意义的注释

### 格式规范
- 使用 `dart format` 格式化代码
- 行长度限制：80 字符
- 缩进：2 空格

## 测试规范

### 单元测试
- 测试所有公共方法
- 测试边界条件
- 测试错误处理

### Widget 测试
- 测试 Widget 渲染
- 测试用户交互
- 测试状态变化

### 集成测试
- 测试完整功能流程
- 测试跨模块交互
- 测试性能指标
