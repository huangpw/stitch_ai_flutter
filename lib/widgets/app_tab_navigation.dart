import 'package:material_ui/material_ui.dart';

/// 页面内的入口切换现有主 Tab，保留导航栈和各页状态。
class AppTabNavigation extends InheritedWidget {
  const AppTabNavigation({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final ValueChanged<int> selectTab;

  static void openProfile(BuildContext context) {
    final navigation = context
        .getInheritedWidgetOfExactType<AppTabNavigation>();
    if (navigation != null) {
      navigation.selectTab(3);
    } else {
      Navigator.of(context).pushNamed('/home-profile');
    }
  }

  @override
  bool updateShouldNotify(AppTabNavigation oldWidget) => false;
}
