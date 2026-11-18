import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_ai_flutter/main.dart';
import 'package:stitch_ai_flutter/screens/stats_screen.dart';
import 'package:stitch_ai_flutter/services/stats_report.dart';

void main() {
  testWidgets('统计入口显示账单统计，完整页面在手机宽度下无溢出', (tester) async {
    tester.view.physicalSize = const Size(399, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const StitchAiApp(initialRoute: '/home-stats'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('账单统计'), findsOneWidget);
    expect(find.text('预算控制中心'), findsNothing);
    expect(find.text('9,698.50'), findsOneWidget);
    expect(find.text('多维支出结构'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final scroll = find.descendant(
      of: find.byType(StatsScreen),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(scroll, const Offset(0, -1100));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('导出 Excel 报表'), findsOneWidget);
    expect(find.text('导出 PDF 账单'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('日期切换为空区间时不会继续展示五月金额', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: StatsScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('上个统计周期'));
    await tester.pumpAndSettle();
    expect(find.text('2025年 4月'), findsOneWidget);
    expect(find.text('本周期暂无账单'), findsOneWidget);
    expect(find.text('9,698.50'), findsNothing);
    await tester.tap(find.byTooltip('下个统计周期'));
    await tester.pumpAndSettle();
    expect(find.text('9,698.50'), findsOneWidget);
    await tester.tap(find.text('日'));
    await tester.pumpAndSettle();
    expect(find.text('本周期暂无账单'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Excel 导出金额可重读且分类总额一致', () async {
    final bytes = await StatsReport.build(
      format: StatsReportFormat.excel,
      period: '2025年 5月',
      hasData: true,
    );
    final workbook = Excel.decodeBytes(bytes);
    final sheet = workbook['账单统计'];
    expect(
      sheet.cell(CellIndex.indexByString('B3')).value,
      const DoubleCellValue(9698.5),
    );
    expect(StatsReport.breakdown.fold(0.0, (sum, row) => sum + row.$2), 9698.5);
  });

  test('空区间导出不包含五月金额，PDF 可生成', () async {
    final empty = Excel.decodeBytes(
      await StatsReport.build(
        format: StatsReportFormat.excel,
        period: '2025年 4月',
        hasData: false,
      ),
    );
    expect(
      empty['账单统计'].cell(CellIndex.indexByString('B3')).value,
      const IntCellValue(0),
    );
    final pdf = await StatsReport.build(
      format: StatsReportFormat.pdf,
      period: '2025年 5月',
      hasData: true,
    );
    expect(String.fromCharCodes(pdf.take(4)), '%PDF');
    expect(pdf.length, greaterThan(1000));
  });
}
