import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_ai_flutter/main.dart';
import 'package:stitch_ai_flutter/screens/profile_screen.dart';
import 'package:stitch_ai_flutter/widgets/common.dart';
import 'package:stitch_ai_flutter/widgets/nav_shell.dart';

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
  Future<void> openApp(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(399, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(StitchAiApp(initialRoute: route));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('所有主页面顶栏头像切换到我的且不重复创建主导航', (tester) async {
    await openApp(tester, '/home');
    for (final label in ['记账', 'AI订阅', '统计', '我的']) {
      await tester.tap(find.text(label).last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(HeaderProfileButton));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('个人中心'), findsOneWidget);
      expect(find.byType(NavShell, skipOffstage: false), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('开启语义树后连续切换Tab和打开弹层不产生脏节点异常', (tester) async {
    await openApp(tester, '/home');
    // 模拟系统在页面已经挂载后启用无障碍语义。
    final semantics = tester.ensureSemantics();
    await tester.pump();
    for (var round = 0; round < 3; round++) {
      for (final label in ['AI订阅', '统计', '我的', '记账']) {
        await tester.tap(find.text(label).last);
        for (var frame = 0; frame < 18; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.takeException(), isNull, reason: '$label frame $frame');
        }
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      final quickEntry = find.byKey(const ValueKey('quick-entry-button'));
      await tester.tap(quickEntry);
      await tester.pump();
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: '弹层 frame $frame');
      }
      expect(find.text('选择记账类型'), findsOneWidget);
      Navigator.of(tester.element(find.text('选择记账类型'))).pop();
      await tester.pump();
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: '关闭弹层 frame $frame');
      }
    }
    semantics.dispose();
  }, semanticsEnabled: false);

  testWidgets('我的页面入口和二级页面名称与跳转一致', (tester) async {
    await openApp(tester, '/home-profile');
    final scroll = find.descendant(
      of: find.byType(ProfileScreen),
      matching: find.byType(SingleChildScrollView),
    );
    for (final entry in <(String, String)>[
      ('扣费预警', 'AI月度预算预警'),
      ('预算控制', '预算控制中心'),
      ('账本管理', '账本管理'),
      ('偏好设置', '偏好设置'),
      ('数据备份', '数据备份'),
      ('关于我们', '关于我们'),
    ]) {
      await tester.scrollUntilVisible(
        find.text(entry.$1).first,
        220,
        scrollable: find.descendant(
          of: scroll,
          matching: find.byType(Scrollable),
        ),
      );
      await Scrollable.ensureVisible(
        tester.element(find.text(entry.$1).first),
        alignment: 0.4,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(entry.$1).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text(entry.$2),
        findsWidgets,
        reason: '${entry.$1} 应打开 ${entry.$2}',
      );
      expect(tester.takeException(), isNull, reason: entry.$1);
      Navigator.of(tester.element(find.text(entry.$2).first)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
  });

  testWidgets('消息页面顶栏和内容标题均为消息通知', (tester) async {
    await openApp(tester, '/notifications');
    expect(find.text('消息通知'), findsNWidgets(2));
    expect(find.text('消息中心与通知'), findsNothing);
    expect(find.text('消息流动审计'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
