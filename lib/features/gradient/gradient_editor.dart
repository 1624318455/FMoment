import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/color/color_utils.dart';

class GradientEditor extends ConsumerStatefulWidget {
  const GradientEditor({super.key});

  @override
  ConsumerState<GradientEditor> createState() => _GradientEditorState();
}

class _GradientEditorState extends ConsumerState<GradientEditor> {
  String _gradientType = 'linear';
  double _angle = 0;
  List<ColorStop> _colorStops = [
    ColorStop(color: Colors.red, position: 0),
    ColorStop(color: Colors.blue, position: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '渐变编辑器',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：编辑区
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 渐变类型选择
                          _buildGradientTypeSelector(),
                          const SizedBox(height: 16),
                          // 角度控制（仅线性渐变）
                          if (_gradientType == 'linear') ...[
                            _buildAngleControl(),
                            const SizedBox(height: 16),
                          ],
                          // 色标编辑
                          _buildColorStopsEditor(),
                          const SizedBox(height: 16),
                          // 操作按钮
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧：预览和代码
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '预览',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          // 渐变预览
                          _buildGradientPreview(),
                          const SizedBox(height: 16),
                          // CSS 代码
                          _buildCSSCode(),
                        ],
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

  Widget _buildGradientTypeSelector() {
    return Row(
      children: [
        Text(
          '渐变类型',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'linear', label: Text('线性')),
            ButtonSegment(value: 'radial', label: Text('径向')),
          ],
          selected: {_gradientType},
          onSelectionChanged: (types) {
            setState(() {
              _gradientType = types.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAngleControl() {
    return Row(
      children: [
        Text(
          '角度',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Slider(
            value: _angle,
            min: 0,
            max: 360,
            divisions: 36,
            label: '${_angle.round()}°',
            onChanged: (value) {
              setState(() {
                _angle = value;
              });
            },
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${_angle.round()}°',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildColorStopsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '色标',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addColorStop,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('添加色标'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._colorStops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          return _buildColorStopItem(index, stop);
        }),
      ],
    );
  }

  Widget _buildColorStopItem(int index, ColorStop stop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // 颜色预览
          GestureDetector(
            onTap: () => _pickColor(index),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: stop.color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 颜色值
          Expanded(
            child: Text(
              '#${stop.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          // 位置滑块
          Expanded(
            child: Slider(
              value: stop.position,
              min: 0,
              max: 1,
              onChanged: (value) {
                setState(() {
                  _colorStops[index] = ColorStop(
                    color: stop.color,
                    position: value,
                  );
                });
              },
            ),
          ),
          // 删除按钮
          if (_colorStops.length > 2)
            IconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () => _removeColorStop(index),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _generateComplementary,
          icon: const Icon(Icons.palette),
          label: const Text('互补色'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _generateAnalogous,
          icon: const Icon(Icons.color_lens),
          label: const Text('邻近色'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _generateDarkTheme,
          icon: const Icon(Icons.dark_mode),
          label: const Text('暗黑主题'),
        ),
      ],
    );
  }

  Widget _buildGradientPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        gradient: _buildGradient(),
      ),
    );
  }

  Gradient _buildGradient() {
    final stops = _colorStops.map((stop) => stop.position).toList();
    final colors = _colorStops.map((stop) => stop.color).toList();

    if (_gradientType == 'linear') {
      final radians = _angle * pi / 180;
      return LinearGradient(
        begin: Alignment(-1 * cos(radians), -1 * sin(radians)),
        end: Alignment(cos(radians), sin(radians)),
        stops: stops,
        colors: colors,
      );
    } else {
      return RadialGradient(
        stops: stops,
        colors: colors,
      );
    }
  }

  Widget _buildCSSCode() {
    final css = _generateCSS();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'CSS 代码',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: css));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制 CSS 代码')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            css,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  String _generateCSS() {
    final stops = _colorStops.map((stop) {
      final hex = '#${stop.color.toARGB32().toRadixString(16).substring(2)}';
      return '$hex ${(stop.position * 100).round()}%';
    }).join(', ');

    if (_gradientType == 'linear') {
      return 'linear-gradient(${_angle.round()}deg, $stops)';
    } else {
      return 'radial-gradient(circle, $stops)';
    }
  }

  void _addColorStop() {
    setState(() {
      _colorStops.add(ColorStop(
        color: Colors.green,
        position: 0.5,
      ));
    });
  }

  void _removeColorStop(int index) {
    setState(() {
      _colorStops.removeAt(index);
    });
  }

  void _pickColor(int index) {
    // TODO: 打开颜色选择器
    // 这里暂时使用随机颜色
    setState(() {
      _colorStops[index] = ColorStop(
        color: Colors.primaries[index % Colors.primaries.length],
        position: _colorStops[index].position,
      );
    });
  }

  void _generateComplementary() {
    if (_colorStops.isEmpty) return;

    final color = _colorStops.first.color;
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    final complementary = ColorUtils.complementary(r, g, b);
    final complementaryColor = Color.fromARGB(
      255,
      complementary['r']!,
      complementary['g']!,
      complementary['b']!,
    );

    setState(() {
      _colorStops = [
        ColorStop(color: color, position: 0),
        ColorStop(color: complementaryColor, position: 1),
      ];
    });
  }

  void _generateAnalogous() {
    if (_colorStops.isEmpty) return;

    final color = _colorStops.first.color;
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    final analogous = ColorUtils.analogous(r, g, b);
    final analogousColors = analogous
        .map((c) => Color.fromARGB(255, c['r']!, c['g']!, c['b']!))
        .toList();

    setState(() {
      _colorStops = analogousColors
          .asMap()
          .entries
          .map((entry) => ColorStop(
                color: entry.value,
                position: entry.key / (analogousColors.length - 1),
              ))
          .toList();
    });
  }

  void _generateDarkTheme() {
    if (_colorStops.isEmpty) return;

    final color = _colorStops.first.color;
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    final dark = ColorUtils.darkTheme(r, g, b);
    final darkColor = Color.fromARGB(255, dark['r']!, dark['g']!, dark['b']!);

    setState(() {
      _colorStops = [
        ColorStop(color: color, position: 0),
        ColorStop(color: darkColor, position: 1),
      ];
    });
  }
}

class ColorStop {
  final Color color;
  final double position;

  ColorStop({required this.color, required this.position});
}
