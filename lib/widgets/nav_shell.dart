import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../screens/ai_subs_screen.dart';
import '../screens/ledger_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/stats_screen.dart';
import 'common.dart';
import 'app_tab_navigation.dart';
import 'm_icon.dart';

/// 悬浮胶囊底部导航（记账 / AI订阅 / [+] / 统计 / 我的）。
/// "+" 记一笔按键嵌在胶囊中央，与设计稿 `<nav class="fixed bottom-6 ...">` 一致。
class NavShell extends StatefulWidget {
  const NavShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  late int _tab = widget.initialTab;

  static const _tabs = <Widget>[
    LedgerScreen(), // 记账
    AiSubsScreen(), // AI订阅
    StatsScreen(), // 账单统计
    ProfileScreen(), // 我的
  ];

  void _selectTab(int tab) {
    if (_tab != tab) setState(() => _tab = tab);
  }

  Future<void> _openQuickEntry() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QuickEntrySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      extendBody: true,
      body: AppTabNavigation(
        selectTab: _selectTab,
        child: IndexedStack(
          index: _tab,
          children: [
            for (var i = 0; i < _tabs.length; i++)
              TickerMode(
                enabled: _tab == i,
                child: ExcludeSemantics(excluding: _tab != i, child: _tabs[i]),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNav(context),
    );
  }

  Widget _buildNav(BuildContext context) {
    const inactive = C.slate400;
    const active = C.emerald800;
    Widget item(int i, IconData icon, String label) {
      final selected = _tab == i;
      return Semantics(
        container: true,
        excludeSemantics: true,
        label: label,
        button: true,
        selected: selected,
        onTap: () => _selectTab(i),
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: () => _selectTab(i),
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              height: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 保持图标几何尺寸稳定，只对颜色做过渡。
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: selected ? active : inactive),
                    duration: const Duration(milliseconds: 220),
                    builder: (_, color, _) =>
                        MIcon(icon, size: 22, color: color),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TS.body(
                      size: 11,
                      weight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? active : inactive,
                    ),
                    child: Text(label),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selected ? active : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 0.75,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          item(0, MSym.account_balance_wallet, '记账'),
                          item(1, MSym.neurology, 'AI订阅'),
                        ],
                      ),
                    ),
                    // 中央 "+" 快捷记一笔按键（嵌在胶囊内）
                    GestureDetector(
                      key: const ValueKey('quick-entry-button'),
                      onTap: _openQuickEntry,
                      child: Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: C.emerald500,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: C.emerald500.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: MIcon(MSym.add, size: 26, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          item(2, MSym.query_stats, '统计'),
                          item(3, MSym.account_circle, '我的'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// FAB 快捷记一笔选择器：日常支出 / 日常收入 / AI 消费。
class QuickEntrySheet extends StatelessWidget {
  const QuickEntrySheet({super.key});

  @override
  Widget build(BuildContext context) {
    const entries = <(IconData, String, String, Color, String)>[
      (
        MSym.payments,
        '新增日常记账',
        '餐饮 · 交通 · 购物等日常开销',
        C.emerald500,
        '/add-expense',
      ),
      (MSym.savings, '新增日常收入', '工资 · 兼职 · 理财收益入账', C.teal500, '/add-income'),
      (
        MSym.memory,
        '记一笔 AI 消费',
        'API 调用 · Token 计费 · 订阅续费',
        C.violet500,
        '/ai-add',
      ),
    ];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '选择记账类型',
              textAlign: TextAlign.center,
              style: TS.headline(size: 17, color: C.slate900),
            ),
            const SizedBox(height: 4),
            Text(
              '双轨记账 · 日常消费与 AI 算力开支分开记录',
              textAlign: TextAlign.center,
              style: TS.body(size: 12, color: C.slate500),
            ),
            const SizedBox(height: 16),
            for (final (icon, title, sub, color, route) in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(route);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x14E2E8F0)),
                        color: C.slate50,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: MIcon(icon, size: 22, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TS.body(
                                    size: 15,
                                    weight: FontWeight.w600,
                                    color: C.slate900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sub,
                                  style: TS.body(size: 12, color: C.slate500),
                                ),
                              ],
                            ),
                          ),
                          const MIcon(
                            MSym.chevron_right,
                            size: 20,
                            color: C.slate400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
