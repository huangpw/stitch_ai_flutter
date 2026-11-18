import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_ai_flutter/main.dart';

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

  testWidgets('分类胶囊可选中、过滤账单和分组金额，空分类可恢复全部', (tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const StitchAiApp(initialRoute: '/home'));
    await tester.pump(const Duration(milliseconds: 600));

    Finder pill(String label) => find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == label,
    );

    Future<void> select(String label) async {
      await Scrollable.ensureVisible(tester.element(pill(label)));
      await tester.pump();
      await tester.tap(pill(label));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<Semantics>(pill(label)).properties.selected, isTrue);
      expect(tester.takeException(), isNull);
    }

    await select('餐饮美食');
    expect(find.text('星巴克臻选咖啡'), findsOneWidget);
    expect(find.text('周末朋友聚餐AA分摊'), findsOneWidget);
    expect(find.text('工作日午餐'), findsOneWidget);
    expect(find.text('地铁通勤卡充值'), findsNothing);
    expect(find.text('盒马鲜生生鲜采买'), findsNothing);
    expect(find.text('今日支出 ¥38.00'), findsOneWidget);
    expect(find.text('昨日支出 ¥145.00'), findsOneWidget);
    // 历史分组的总额包含"上滑加载更多"分页追加的账单，会随加载进度增长，
    // 精确值取决于滚动时机，故只断言前缀。
    expect(find.textContaining('历史支出'), findsOneWidget);
    expect(tester.widget<Semantics>(pill('全部分类')).properties.selected, isFalse);

    await select('交通出行');
    expect(find.text('地铁通勤卡充值'), findsOneWidget);
    expect(find.text('星巴克臻选咖啡'), findsNothing);
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('昨天'), findsNothing);
    expect(find.text('历史'), findsNothing);
    expect(find.text('今日支出 ¥50.00'), findsOneWidget);

    await select('休闲娱乐');
    expect(find.text('暂无休闲娱乐账单'), findsOneWidget);
    expect(find.text('地铁通勤卡充值'), findsNothing);
    await select('休闲娱乐');
    expect(find.text('暂无休闲娱乐账单'), findsOneWidget);

    await select('全部分类');
    expect(find.text('星巴克臻选咖啡'), findsOneWidget);
    expect(find.text('地铁通勤卡充值'), findsOneWidget);
    expect(find.text('优衣库夏季服饰采买'), findsOneWidget);
    expect(find.text('今日支出 ¥274.50'), findsOneWidget);
    expect(find.text('昨日支出 ¥544.00'), findsOneWidget);
    expect(find.textContaining('历史支出'), findsOneWidget);
    expect(find.text('暂无休闲娱乐账单'), findsNothing);
  });
}
