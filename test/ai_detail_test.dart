import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_ai_flutter/main.dart';
import 'package:stitch_ai_flutter/screens/ai_detail_screen.dart';
import 'package:stitch_ai_flutter/screens/ai_subs_screen.dart';
import 'package:stitch_ai_flutter/widgets/common.dart';

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

  for (final width in [360.0, 440.0]) {
    testWidgets('AI详情在${width.toInt()}px手机宽度和语义树启用时可布局和滚动', (tester) async {
      tester.view.physicalSize = Size(width, 956);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StitchAiApp(initialRoute: '/ai-detail'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(find.text('AI 充值与订阅详情'), findsOneWidget);
      final scrollable = find.descendant(
        of: find.byType(AiDetailScreen),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('告警机制与记账备忘'),
        300,
        scrollable: scrollable,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('AI订阅与充值的全部记录可进入详情并返回，语义树无异常', (tester) async {
    tester.view.physicalSize = const Size(360, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const StitchAiApp(initialRoute: '/home-ai'));
    await tester.pump(const Duration(milliseconds: 600));
    final semantics = tester.ensureSemantics();
    await tester.pump();

    Future<void> pumpTransition(String phase) async {
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: '$phase frame $frame');
      }
    }

    for (final label in [
      'ChatGPT Plus',
      'Claude Pro',
      'Midjourney Standard',
      'Cursor AI Pro',
      'GitHub Copilot Pro',
      'OpenAI API 自动续费充值',
      'DeepSeek 账户预充值',
      'Perplexity Pro 订阅扣费',
    ]) {
      final record = find.descendant(
        of: find.byType(AiSubsScreen),
        matching: find.text(label),
      );
      await Scrollable.ensureVisible(tester.element(record), alignment: 0.3);
      await tester.pump();
      await tester.tap(record);
      await pumpTransition('打开 $label');
      expect(find.byType(AiDetailScreen), findsOneWidget);
      expect(find.text('AI 充值与订阅详情'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('告警机制与记账备忘'),
        300,
        scrollable: find.descendant(
          of: find.byType(AiDetailScreen),
          matching: find.byType(Scrollable),
        ),
      );
      await pumpTransition('滚动 $label');
      await tester.tap(find.byType(NavBarBackButton));
      await pumpTransition('返回 $label');
      expect(find.byType(AiDetailScreen), findsNothing);
      expect(find.text('AI 订阅与充值'), findsOneWidget);
    }
    semantics.dispose();
  }, semanticsEnabled: false);
}
