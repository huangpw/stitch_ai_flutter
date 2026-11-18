import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_ai_flutter/main.dart';
import 'package:stitch_ai_flutter/screens/ledger_screen.dart';
import 'package:stitch_ai_flutter/screens/monthly_budget_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final (family, file) in [
      ('Inter', 'Inter-Regular.ttf'),
      ('SpaceGrotesk', 'SpaceGrotesk-Bold.ttf'),
      ('JetBrainsMono', 'JetBrainsMono-Regular.ttf'),
    ]) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$file'))).load();
    }
  });

  testWidgets('预算分析打开当前月明细，金额一致且可以进入预算控制中心并逐级返回', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const StitchAiApp(initialRoute: '/home'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('预算分析'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final now = DateTime.now();
    expect(find.text('本月预算明细'), findsOneWidget);
    expect(find.text('${now.year}年 ${now.month}月'), findsOneWidget);
    expect(find.text('¥12,000.00'), findsOneWidget);
    expect(find.text('¥8,450.00'), findsOneWidget);
    expect(find.text('¥3,550.00'), findsOneWidget);
    expect(find.text('70.4%'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('前往预算控制中心'),
      240,
      scrollable: find.descendant(
        of: find.byType(MonthlyBudgetScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('¥1,500.00'), findsOneWidget);
    expect(find.text('额度已用满'), findsOneWidget);
    await tester.tap(find.text('前往预算控制中心'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('预算控制中心'), findsOneWidget);
    Navigator.of(tester.element(find.text('预算控制中心'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    Navigator.of(tester.element(find.byType(MonthlyBudgetScreen))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(LedgerScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('直接打开明细路由默认当前月，窄屏没有溢出', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const StitchAiApp(initialRoute: '/monthly-budget'));
    await tester.pump(const Duration(milliseconds: 600));
    final now = DateTime.now();
    expect(find.text('${now.year}年 ${now.month}月'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('前往预算控制中心'), 220);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
