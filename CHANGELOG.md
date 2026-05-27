# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-05-27

### Added

- **截图**
  - 全局热键截图：PrintScreen / Alt+A
  - 三种截图模式：区域选择、全屏截图、窗口截图
  - 标注编辑器：矩形、箭头、文字、高亮、马赛克
  - 标注撤销/重做支持
- **取色**
  - Win32 API 实时屏幕取色
  - 鼠标跟随放大镜显示
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
