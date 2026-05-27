import 'dart:ffi';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:win32/win32.dart';

/// 使用 Win32 RegisterHotKey API 实现全局热键
class NativeHotkey {
  static const _wmHotkey = 0x0312;
  static const _modAlt = 0x0001;
  static const _modControl = 0x0002;
  static const _modShift = 0x0004;
  static const _modWin = 0x0008;

  static int _nextId = 1;
  static final Map<int, void Function()> _handlers = {};
  static bool _listening = false;

  /// 注册全局热键，返回热键 ID
  static int register({
    required int vk,
    bool alt = false,
    bool ctrl = false,
    bool shift = false,
    bool win = false,
    required void Function() handler,
  }) {
    final id = _nextId++;
    int modifiers = 0;
    if (alt) modifiers |= _modAlt;
    if (ctrl) modifiers |= _modControl;
    if (shift) modifiers |= _modShift;
    if (win) modifiers |= _modWin;

    try {
      final result = RegisterHotKey(NULL, id, modifiers, vk);
      if (result == 0) {
        return -1;
      }
    } catch (e) {
      // Test environment or Win32 not available
      return -1;
    }

    _handlers[id] = handler;
    _startListening();
    return id;
  }

  /// 注销热键
  static void unregister(int id) {
    if (id <= 0) return;
    UnregisterHotKey(NULL, id);
    _handlers.remove(id);
  }

  static void _startListening() {
    if (_listening) return;
    _listening = true;

    // Skip in test environment — no real Win32 message queue
    final binding = WidgetsBinding.instance;
    if (binding is! WidgetsFlutterBinding) return;

    Timer.periodic(const Duration(milliseconds: 16), (_) {
      final msg = calloc<MSG>();
      while (PeekMessage(msg, NULL, _wmHotkey, _wmHotkey, PM_REMOVE) != 0) {
        final id = msg.ref.wParam;
        final handler = _handlers[id];
        if (handler != null) {
          handler();
        }
      }
      calloc.free(msg);
    });
  }
}
