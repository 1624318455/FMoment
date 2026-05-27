import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/color/color_utils.dart';

class ColorCheckPage extends ConsumerStatefulWidget {
  const ColorCheckPage({super.key});

  @override
  ConsumerState<ColorCheckPage> createState() => _ColorCheckPageState();
}

class _ColorCheckPageState extends ConsumerState<ColorCheckPage> {
  Color _foreground = Colors.black;
  Color _background = Colors.white;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _checkContrast();
  }

  void _checkContrast() {
    final fr = (_foreground.r * 255.0).round().clamp(0, 255);
    final fg = (_foreground.g * 255.0).round().clamp(0, 255);
    final fb = (_foreground.b * 255.0).round().clamp(0, 255);

    final br = (_background.r * 255.0).round().clamp(0, 255);
    final bg = (_background.g * 255.0).round().clamp(0, 255);
    final bb = (_background.b * 255.0).round().clamp(0, 255);

    setState(() {
      _result = ColorUtils.checkWCAG(fr, fg, fb, br, bg, bb);
    });
  }

  void _swapColors() {
    setState(() {
      final temp = _foreground;
      _foreground = _background;
      _background = temp;
    });
    _checkContrast();
  }

  void _copyResult() {
    if (_result == null) return;

    final ratio = _result!['ratio'] as double;
    final text = 'WCAG 对比度检查\n'
        '对比度: ${ratio.toStringAsFixed(2)}:1\n'
        'AA 普通文本: ${_result!['AA_normal'] ? '通过' : '不通过'}\n'
        'AA 大文本: ${_result!['AA_large'] ? '通过' : '不通过'}\n'
        'AAA 普通文本: ${_result!['AAA_normal'] ? '通过' : '不通过'}\n'
        'AAA 大文本: ${_result!['AAA_large'] ? '通过' : '不通过'}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制检查结果')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '色彩合规检测',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：颜色选择
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '颜色选择',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          // 前景色
                          _buildColorSelector(
                            label: '前景色（文字）',
                            color: _foreground,
                            onChanged: (color) {
                              setState(() {
                                _foreground = color;
                              });
                              _checkContrast();
                            },
                          ),
                          const SizedBox(height: 16),
                          // 交换按钮
                          Center(
                            child: IconButton(
                              icon: const Icon(Icons.swap_vert),
                              onPressed: _swapColors,
                              tooltip: '交换颜色',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 背景色
                          _buildColorSelector(
                            label: '背景色',
                            color: _background,
                            onChanged: (color) {
                              setState(() {
                                _background = color;
                              });
                              _checkContrast();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧：检查结果
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '检查结果',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: _copyResult,
                                tooltip: '复制结果',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 预览
                          _buildPreview(),
                          const SizedBox(height: 16),
                          // 对比度数值
                          if (_result != null) ...[
                            _buildContrastRatio(),
                            const SizedBox(height: 16),
                            // WCAG 标准检查
                            _buildWCAGChecks(),
                            const SizedBox(height: 16),
                            // 优化建议
                            _buildSuggestions(),
                          ],
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

  Widget _buildColorSelector({
    required String label,
    required Color color,
    required ValueChanged<Color> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            // 颜色预览
            GestureDetector(
              onTap: () {
                // TODO: 打开颜色选择器
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 颜色值输入
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '#000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: TextEditingController(
                  text: '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                ),
                onChanged: (value) {
                  if (value.startsWith('#') && value.length == 7) {
                    try {
                      final r = int.parse(value.substring(1, 3), radix: 16);
                      final g = int.parse(value.substring(3, 5), radix: 16);
                      final b = int.parse(value.substring(5, 7), radix: 16);
                      onChanged(Color.fromARGB(255, r, g, b));
                    } catch (e) {
                      // 忽略无效输入
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        children: [
          Text(
            '普通文本 (16px)',
            style: TextStyle(
              color: _foreground,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '大文本 (24px)',
            style: TextStyle(
              color: _foreground,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '超大文本 (32px)',
            style: TextStyle(
              color: _foreground,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastRatio() {
    final ratio = _result!['ratio'] as double;
    Color ratioColor;
    String level;

    if (ratio >= 7) {
      ratioColor = Colors.green;
      level = '优秀';
    } else if (ratio >= 4.5) {
      ratioColor = Colors.orange;
      level = '良好';
    } else if (ratio >= 3) {
      ratioColor = Colors.red;
      level = '一般';
    } else {
      ratioColor = Colors.red;
      level = '差';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ratioColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ratioColor),
      ),
      child: Column(
        children: [
          Text(
            '对比度',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${ratio.toStringAsFixed(2)}:1',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: ratioColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            level,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ratioColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWCAGChecks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WCAG 标准',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildCheckItem('AA 普通文本 (≥4.5:1)', _result!['AA_normal']),
        _buildCheckItem('AA 大文本 (≥3:1)', _result!['AA_large']),
        _buildCheckItem('AAA 普通文本 (≥7:1)', _result!['AAA_normal']),
        _buildCheckItem('AAA 大文本 (≥4.5:1)', _result!['AAA_large']),
      ],
    );
  }

  Widget _buildCheckItem(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: passed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final ratio = _result!['ratio'] as double;
    List<String> suggestions = [];

    if (ratio < 4.5) {
      suggestions.add('对比度不足，建议调整前景色或背景色');
      suggestions.add('可以尝试加深前景色或减淡背景色');
    }

    if (ratio < 3) {
      suggestions.add('对比度严重不足，不适合用于文本显示');
      suggestions.add('建议使用更高对比度的颜色组合');
    }

    if (suggestions.isEmpty) {
      suggestions.add('颜色组合符合 WCAG 无障碍标准');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '优化建议',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(suggestion)),
            ],
          ),
        )),
      ],
    );
  }
}
