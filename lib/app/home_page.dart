import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/screenshot/screenshot_page.dart';
import '../features/color_picker/color_picker_page.dart';
import '../features/color_card/color_card_page.dart';
import '../features/gradient/gradient_editor.dart';
import '../features/color_check/color_check_page.dart';
import '../features/settings/settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ScreenshotPage(),
    ColorPickerPage(),
    ColorCardPage(),
    GradientEditor(),
    ColorCheckPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧功能栏
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(Icons.camera_alt),
                label: Text('截图'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.colorize_outlined),
                selectedIcon: Icon(Icons.colorize),
                label: Text('取色'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.palette_outlined),
                selectedIcon: Icon(Icons.palette),
                label: Text('色卡'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.gradient_outlined),
                selectedIcon: Icon(Icons.gradient),
                label: Text('渐变'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_circle_outlined),
                selectedIcon: Icon(Icons.check_circle),
                label: Text('合规'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('设置'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // 中间内容区
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
