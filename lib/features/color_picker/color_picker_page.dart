import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../platform/native_hotkey.dart';
import 'color_picker_service.dart';
import 'color_picker_overlay.dart';

class ColorPickerPage extends ConsumerStatefulWidget {
  const ColorPickerPage({super.key});

  @override
  ConsumerState<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends ConsumerState<ColorPickerPage> {
  Color _selectedColor = Colors.blue;
  String _colorFormat = 'HEX';
  bool _isPicking = false;
  int _altCHotKeyId = -1;

  @override
  void initState() {
    super.initState();
    _registerHotkeys();
  }

  void _registerHotkeys() {
    // ALT+C
    _altCHotKeyId = NativeHotkey.register(
      vk: 0x43, // 'C'
      alt: true,
      handler: () => _startPicking(),
    );
  }

  Future<void> _startPicking() async {
    setState(() {
      _isPicking = true;
    });

    if (!mounted) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => ColorPickerOverlay(
        onColorPicked: (color) {
          setState(() {
            _selectedColor = color;
            _isPicking = false;
          });
          final colorPickerService = ref.read(colorPickerServiceProvider);
          colorPickerService.addToHistory(color);
          entry.remove();
        },
        onCancel: () {
          setState(() {
            _isPicking = false;
          });
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }

  void _copyColorValue() {
    final colorPickerService = ref.read(colorPickerServiceProvider);
    final formats = colorPickerService.getColorFormats(_selectedColor);
    final value = formats[_colorFormat] ?? '';

    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制: $value')),
    );
  }

  void _addToColorCard() {
    final colorPickerService = ref.read(colorPickerServiceProvider);
    colorPickerService.addToHistory(_selectedColor);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已加入取色历史')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorPickerService = ref.watch(colorPickerServiceProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '取色器',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：取色预览
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '屏幕取色',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isPicking ? Icons.colorize : Icons.colorize_outlined,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _isPicking ? '取色中...' : '按 ALT+C 开始取色',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  if (!_isPicking)
                                    FilledButton.icon(
                                      onPressed: _startPicking,
                                      icon: const Icon(Icons.colorize),
                                      label: const Text('开始取色'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // 取色历史
                          if (colorPickerService.colorHistory.isNotEmpty) ...[
                            const Divider(),
                            Text(
                              '取色历史',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: colorPickerService.colorHistory.length,
                                itemBuilder: (context, index) {
                                  final color = colorPickerService.colorHistory[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = color;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.outline,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧：颜色详情
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '颜色详情',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          // 颜色预览
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 颜色格式切换
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'HEX', label: Text('HEX')),
                              ButtonSegment(value: 'RGB', label: Text('RGB')),
                              ButtonSegment(value: 'HSL', label: Text('HSL')),
                            ],
                            selected: {_colorFormat},
                            onSelectionChanged: (formats) {
                              setState(() {
                                _colorFormat = formats.first;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // 颜色值
                          _buildColorValue(),
                          const SizedBox(height: 16),
                          // 操作按钮
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _copyColorValue,
                                  icon: const Icon(Icons.copy),
                                  label: const Text('复制'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _addToColorCard,
                                  icon: const Icon(Icons.add),
                                  label: const Text('加入色卡'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 配色建议
                          _buildColorSuggestions(),
                        ],
                      ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorValue() {
    final colorPickerService = ref.read(colorPickerServiceProvider);
    final formats = colorPickerService.getColorFormats(_selectedColor);
    final value = formats[_colorFormat] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: _copyColorValue,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSuggestions() {
    final colorPickerService = ref.read(colorPickerServiceProvider);
    final complementary = colorPickerService.getComplementary(_selectedColor);
    final analogous = colorPickerService.getAnalogous(_selectedColor);
    final darkTheme = colorPickerService.getDarkTheme(_selectedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '配色建议',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildColorRow('互补色', [complementary]),
        const SizedBox(height: 4),
        _buildColorRow('邻近色', analogous),
        const SizedBox(height: 4),
        _buildColorRow('暗黑主题', [darkTheme]),
      ],
    );
  }

  Widget _buildColorRow(String label, List<Color> colors) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Row(
            children: colors
                .map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    NativeHotkey.unregister(_altCHotKeyId);
    super.dispose();
  }
}
