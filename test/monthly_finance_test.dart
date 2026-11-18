import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_ai_flutter/main.dart';
import 'package:stitch_ai_flutter/screens/monthly_finance_screens.dart';
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

  Future<void> open(
    WidgetTester tester,
    String route, {
    double width = 360,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(StitchAiApp(initialRoute: route));
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> transition(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('首页收入卡打开明细，收入记录合计与首页一致，支持新增入口和返回', (tester) async {
    await open(tester, '/home');
    await tester.tap(find.text('本月总收入'));
    await transition(tester);
    expect(find.byType(MonthlyIncomeScreen), findsOneWidget);
    expect(find.text('¥24,500.00'), findsOneWidget);
    expect(find.text('+¥22,000.00'), findsOneWidget);
    expect(find.text('+¥2,000.00'), findsOneWidget);
    expect(find.text('+¥500.00'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('记一笔收入'), 250);
    await tester.tap(find.text('记一笔收入'));
    await transition(tester);
    expect(find.text('新增日常收入'), findsOneWidget);
    Navigator.of(tester.element(find.text('新增日常收入'))).pop();
    await transition(tester);
    Navigator.of(tester.element(find.byType(MonthlyIncomeScreen))).pop();
    await transition(tester);
    expect(find.text('日常记账'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('结余明细核算一致，可查看同月收入和预算并逐级返回', (tester) async {
    await open(tester, '/home');
    await tester.tap(find.text('财务净结余'));
    await transition(tester);
    expect(find.text('财务净结余明细'), findsOneWidget);
    expect(find.text('¥24,500.00'), findsOneWidget);
    expect(find.text('-¥8,450.00'), findsOneWidget);
    expect(find.text('+¥16,050.00'), findsNWidgets(2));
    expect(find.text('65.5%'), findsOneWidget);
    await tester.tap(find.text('本月总收入'));
    await transition(tester);
    final period = tester
        .widget<MonthlyIncomeScreen>(find.byType(MonthlyIncomeScreen))
        .month;
    expect(period!.month, DateTime.now().month);
    Navigator.of(tester.element(find.byType(MonthlyIncomeScreen))).pop();
    await transition(tester);
    await tester.scrollUntilVisible(find.text('查看本月预算明细'), 250);
    await tester.tap(find.text('查看本月预算明细'));
    await transition(tester);
    expect(
      tester
          .widget<MonthlyBudgetScreen>(find.byType(MonthlyBudgetScreen))
          .month,
      period,
    );
    Navigator.of(tester.element(find.byType(MonthlyBudgetScreen))).pop();
    await transition(tester);
    Navigator.of(tester.element(find.byType(MonthlyBalanceScreen))).pop();
    await transition(tester);
    expect(find.text('日常记账'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final route in ['/monthly-income', '/monthly-balance']) {
    testWidgets('$route 可直接打开，默认本月，320宽度无溢出', (tester) async {
      await open(tester, route, width: 320);
      final now = DateTime.now();
      expect(find.text('${now.year}年 ${now.month}月'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(route == '/monthly-income' ? '记一笔收入' : '查看本月预算明细'),
        250,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }
}
