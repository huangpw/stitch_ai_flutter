import 'package:flutter_test/flutter_test.dart';

import 'package:stitch_ai_flutter/core/msym.dart';
import 'package:stitch_ai_flutter/main.dart';

void main() {
  test('Material Symbols 图标常量无重复码点', () {
    final seen = <int>{};
    final dup = <int>[];
    for (final icon in MSym.all) {
      if (!seen.add(icon.codePoint)) dup.add(icon.codePoint);
    }
    expect(dup, isEmpty);
  });

  test('MSymFill 实心镜像表与 MSym 码点一一对应', () {
    for (final icon in MSym.all) {
      if (icon.fontFamily != 'MaterialSymbolsOutlined') continue;
      final fill = MSymFill.byCode[icon.codePoint];
      expect(fill, isNotNull,
          reason: '缺少码点 0x${icon.codePoint.toRadixString(16)} 的实心字形');
    }
  });

  testWidgets('应用能启动并渲染登录页', (tester) async {
    await tester.pumpWidget(const StitchAiApp());
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('立即登录 / 开始体验'), findsOneWidget);
    expect(find.text('FlowAI'), findsOneWidget);
  });
}
