import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'core/palette.dart';
import 'core/semantics_diagnostics.dart';
import 'core/type.dart';
import 'screens/about_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/ai_add_screen.dart';
import 'screens/ai_alert_screen.dart';
import 'screens/ai_detail_screen.dart';
import 'screens/ai_scan_screen.dart';
import 'screens/assets_screen.dart';
import 'screens/books_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/monthly_budget_screen.dart';
import 'screens/monthly_finance_screens.dart';
import 'screens/notifications_screen.dart';
import 'screens/register_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tx_detail_screen.dart';
import 'widgets/common.dart';
import 'widgets/nav_shell.dart';

/// FlowAI Ledger 智流记账 — 双轨记账与 AI 算力开支一站式把控。
/// 依据 Stitch 设计稿 1:1 还原（glacial_cyber_finance / light_luxury_cyber_finance 设计系统）。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  assert(() {
    installSemanticsDiagnostics();
    return true;
  }());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(StitchAiApp(initialRoute: _webInitialRoute()));
}

/// Web 端支持 URL fragment 深链（如 /#/home 直达对应屏幕），
/// 便于分屏验收；移动端始终从登录页进入。
String _webInitialRoute() {
  if (!kIsWeb) return '/';
  final fragment = Uri.base.fragment;
  return fragment.startsWith('/') ? fragment : '/';
}

class StitchAiApp extends StatelessWidget {
  const StitchAiApp({super.key, this.initialRoute = '/'});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowAI Ledger 智流记账',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: C.emerald500,
          primary: C.emerald600,
        ),
        scaffoldBackgroundColor: kCanvas,
        splashFactory: InkSparkle.splashFactory,
        textTheme: TextTheme(
          bodyLarge: TS.body(size: 16),
          bodyMedium: TS.body(size: 14),
          bodySmall: TS.body(size: 12),
        ),
      ),
      builder: (context, child) {
        // 移动端设计稿（<400px 内容宽度），在宽屏上居中呈现为手机画幅。
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        );
      },
      initialRoute: initialRoute,
      routes: {
        '/': (_) => const LoginScreen(), // _4 登录
        '/register': (_) => const RegisterScreen(), // _1 注册
        '/home': (_) => const NavShell(), // 底部导航主壳
        '/home-ai': (_) => const NavShell(initialTab: 1), // AI订阅 Tab（深链）
        '/home-stats': (_) => const NavShell(initialTab: 2), // 统计 Tab（深链）
        '/home-profile': (_) => const NavShell(initialTab: 3), // 我的 Tab（深链）
        '/add-expense': (_) => const AddExpenseScreen(), // _6 新增记账
        '/add-income': (_) => const AddIncomeScreen(), // _11 新增日常收入
        '/ai-add': (_) => const AiAddScreen(), // ai_3 记一笔AI消费
        '/tx-detail': (_) => const TxDetailScreen(), // _8 单笔消费详情
        '/assets': (_) => const AssetsScreen(), // _9 账户资产管理
        '/notifications': (_) => const NotificationsScreen(), // _5 消息中心
        '/settings': (_) => const SettingsScreen(), // _7 偏好设置
        '/backup': (_) => const SettingsScreen(backupOnly: true),
        '/about': (_) => const AboutScreen(),
        '/edit-profile': (_) => const EditProfileScreen(), // _3 编辑个人资料
        '/books': (_) => const BooksScreen(), // _12 账本管理
        '/budget': (_) => const BudgetScreen(), // 独立预算控制中心
        '/monthly-budget': (context) {
          final month = ModalRoute.of(context)?.settings.arguments;
          return MonthlyBudgetScreen(month: month is DateTime ? month : null);
        },
        '/monthly-income': (context) {
          final month = ModalRoute.of(context)?.settings.arguments;
          return MonthlyIncomeScreen(month: month is DateTime ? month : null);
        },
        '/monthly-balance': (context) {
          final month = ModalRoute.of(context)?.settings.arguments;
          return MonthlyBalanceScreen(month: month is DateTime ? month : null);
        },
        '/search': (_) => const SearchScreen(), // _14 全局搜索
        '/ai-detail': (_) => const AiDetailScreen(), // ai_1 AI充值与订阅详情
        '/ai-scan': (_) => const AiScanScreen(), // ai_4 智能票据识别
        '/ai-alert': (_) => const AiAlertScreen(), // ai_5 AI算力月度预算超支预警
      },
    );
  }
}
