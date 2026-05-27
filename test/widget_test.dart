import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fmoment/app/app.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FMomentApp(),
      ),
    );

    // 验证应用标题
    expect(find.text('截图'), findsOneWidget);
    expect(find.text('取色'), findsOneWidget);
    expect(find.text('色卡'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('Navigation should work correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FMomentApp(),
      ),
    );

    // 点击取色标签
    await tester.tap(find.text('取色'));
    await tester.pump();

    // 验证取色页面显示
    expect(find.text('取色器'), findsOneWidget);
  });
}
