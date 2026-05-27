# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-28

### Added

- **截图**
  - 全局热键截图：PrintScreen / Alt+A
  - 三种截图模式：区域选择、全屏截图、窗口截图
  - 标注编辑器：矩形、箭头、文字、高亮、马赛克、椭圆、直线、画笔
  - 标注撤销/重做支持
- **取色**
  - Win32 API 实时屏幕取色
  - 鼠标跟随放大镜显示（边缘自动翻转）
  - 颜色格式：HEX、RGB、HSL 一键复制
  - 取色历史记录
- **悬浮贴图**
  - 截图后转为悬浮窗口置顶显示
  - 窗口缩放、透明度调节
  - 鼠标穿透模式
- **色卡管理**
  - 分组/色卡/颜色三级 CRUD
  - SQLite（Sqflite）持久化存储
  - JSON 导入/导出
- **渐变编辑器**
  - 线性渐变、径向渐变
  - 角度控制
  - 色标编辑
  - CSS 代码导出
- **色彩合规检测**
  - WCAG AA / AAA 对比度检查
  - 优化建议
- **技术栈**
  - Flutter Windows Desktop
  - Riverpod 状态管理
  - Sqflite 本地数据库
  - Win32 API 系统能力调用

### Fixed

- Win32 GDI 错误检查，防止静默失败
- FocusNode 内存泄漏，确保 widget 生命周期正确释放
- 截图导航 null-safe 处理
- 热键独立注销，不再影响兄弟页面
- Paint 对象隔离，防止渲染帧间状态污染
- SQL 列别名不匹配修复
- `dart:math.pow()` 替代截断循环，修复色彩精度
- 数据库迁移钩子接入
- 放大镜边缘溢出自动翻转
- `drawAnnotation` 改为 static，避免每帧重建实例
- 移除有原生崩溃 bug 的 `hotkey_manager` 插件，改用 Win32 API 直接注册全局热键
- `sqflite_common_ffi` 初始化，修复 Windows 桌面端数据库无法使用的问题
- 窗口显示时序修复，避免启动白屏

### Commits

| Hash | Description |
|------|-------------|
| `d6eac6a` | fix: replace hotkey_manager with native Win32 hotkey, add sqflite FFI init |
| `4864ba7` | docs: consolidate CHANGELOG for v1.0.0 release |
| `57836c4` | fix: magnifier edge clamping and static drawAnnotation |
| `ce51b75` | fix: resolve 12 runtime issues from code review |
| `5bb42d9` | docs: update README and add CHANGELOG via Hermes |
| `af49fc0` | chore: update .gitignore for Flutter, remove build artifacts |
| `7945f84` | feat: implement FMoment core features |
| `e39e7a1` | chore: init FMoment project |
