import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_ai_flutter/main.dart';
import 'package:stitch_ai_flutter/screens/monthly_budget_screen.dart';
import 'package:stitch_ai_flutter/screens/monthly_finance_screens.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final (family, file) in [
      ('Inter', 'Inter-Regular.ttf'),
      ('SpaceGrotesk', 'SpaceGrotesk-Bold.ttf'),
      ('JetBrainsMono', 'JetBrainsMono-Regular.ttf'),
    ]) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$file'));
      await loader.load();
    }
  });

  testWidgets('记账月份默认当前年月，选择后更新，取消保留原值，本月恢复当前年月', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final currentLabel = '${now.year}年 ${now.month}月';
    final chosenYear = now.year - 1;
    final chosenMonth = now.month == 12 ? 11 : now.month + 1;

    await tester.pumpWidget(const StitchAiApp(initialRoute: '/home'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(currentLabel), findsOneWidget);

    Future<void> openPicker(String label) async {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('选择年月'), findsOneWidget);
    }

    Future<void> scrollWheel(int field, double distance) async {
      await tester.drag(
        find.byType(ListWheelScrollView).at(field),
        Offset(0, distance),
        touchSlopY: 0,
      );
      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    int selectedIndex(int field) {
      final wheel = tester.widget<ListWheelScrollView>(
        find.byType(ListWheelScrollView).at(field),
      );
      return (wheel.controller! as FixedExtentScrollController).selectedItem;
    }

    await openPicker(currentLabel);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    await scrollWheel(0, 44);
    await scrollWheel(1, now.month == 12 ? 44 : -44);
    expect(selectedIndex(0), 99);
    expect(selectedIndex(1), chosenMonth - 1);
    await tester.tap(find.text('确定'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    final chosenLabel = '$chosenYear年 $chosenMonth月';
    expect(find.text(chosenLabel), findsOneWidget);

    await tester.tap(find.text('预算分析'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('本月预算明细'), findsOneWidget);
    expect(
      tester
          .widget<MonthlyBudgetScreen>(find.byType(MonthlyBudgetScreen))
          .month,
      DateTime(chosenYear, chosenMonth),
    );
    Navigator.of(tester.element(find.byType(MonthlyBudgetScreen))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(chosenLabel), findsOneWidget);

    for (final label in ['本月总收入', '财务净结余']) {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final screen = label == '本月总收入'
          ? find.byType(MonthlyIncomeScreen)
          : find.byType(MonthlyBalanceScreen);
      final selected = label == '本月总收入'
          ? tester.widget<MonthlyIncomeScreen>(screen).month
          : tester.widget<MonthlyBalanceScreen>(screen).month;
      expect(selected, DateTime(chosenYear, chosenMonth));
      expect(find.text(chosenLabel), findsOneWidget);
      Navigator.of(tester.element(screen)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    await openPicker(chosenLabel);
    // 再次打开时保留已选年月。
    expect(selectedIndex(0), 99);
    expect(selectedIndex(1), chosenMonth - 1);
    await tester.tap(find.text('回到本月'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(selectedIndex(0), 100);
    expect(selectedIndex(1), now.month - 1);
    await tester.tap(find.text('取消'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(chosenLabel), findsOneWidget);

    await openPicker(chosenLabel);
    await tester.tap(find.text('回到本月'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('确定'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(currentLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
