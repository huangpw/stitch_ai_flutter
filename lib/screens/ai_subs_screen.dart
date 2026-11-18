import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// AI 订阅与充值控制台（设计稿 ai_2）— 底部导航「AI订阅」Tab。
/// 展示订阅与充值记录；第三方余额监控待接入接口后启用。
class AiSubsScreen extends StatelessWidget {
  const AiSubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏 ----
          GlassHeader.tab(
            title: 'AI 订阅与充值',
            actions: [
              HeaderIconButton(
                icon: MSym.search,
                onTap: () => Navigator.of(context).pushNamed('/search'),
              ),
              const SizedBox(width: 8),
              HeaderIconButton(
                icon: MSym.notifications,
                badgeColor: C.emerald500,
                onTap: () => Navigator.of(context).pushNamed('/notifications'),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const PageContentInsets(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _heroBanner(context),
                  const SizedBox(height: kCardGap),
                  // 尚未接入第三方余额接口，暂不展示算力余量。
                  // _balanceSection(context),
                  // const SizedBox(height: kCardGap),
                  _subsSection(context),
                  const SizedBox(height: kCardGap),
                  _flowSection(context),
                  const SizedBox(height: kCardGap),
                  _addButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 顶部指标英雄横幅 =====================
  Widget _heroBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.emerald500.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            left: -32,
            bottom: -32,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.blue500.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const PulsingDot(color: C.emerald500, size: 8),
                      const SizedBox(width: 6),
                      Text('AI 算力与订阅控制台',
                          style: TS.mono(size: 11, weight: FontWeight.w600, color: C.slate500)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: C.emerald50,
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: C.emerald200.withValues(alpha: 0.7)),
                    ),
                    child: Row(
                      children: [
                        const MIcon(MSym.sync, size: 13, color: C.emerald700),
                        const SizedBox(width: 4),
                        Text('实时汇率 7.22',
                            style:
                                TS.mono(size: 13, weight: FontWeight.w500, color: C.emerald700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('本月 AI 订阅与充值总支出',
                      style: TS.body(size: 12, color: C.slate500)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('\$148.50',
                          style: TextStyle(
                            fontFamily: F.display,
                            fontSize: 32,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.02,
                            color: C.slate900,
                            leadingDistribution: TextLeadingDistribution.even,
                          )),
                      const SizedBox(width: 8),
                      Text('≈ ¥1,072.00',
                          style: TS.mono(size: 13, weight: FontWeight.w500, color: C.emerald600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 快捷状态徽标
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: C.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: C.slate100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: C.indigo50,
                                shape: BoxShape.circle,
                                border: Border.all(color: C.indigo100),
                              ),
                              child: const Center(
                                  child: MIcon(MSym.neurology,
                                      size: 18, color: C.indigo600)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('活跃订阅',
                                      style: TS.body(size: 11, color: C.slate500)),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text('5',
                                          style: TS.headline(
                                              size: 22,
                                              weight: FontWeight.w600,
                                              color: C.slate900)),
                                      const SizedBox(width: 3),
                                      Text('个方案',
                                          style: TS.body(size: 11, color: C.slate500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 余额预警依赖第三方余额接口，暂不展示。
                  /*
                  const SizedBox(width: kCardGap),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/ai-alert'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: C.red50.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: C.red100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: C.red100,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                  child: MIcon(MSym.warning,
                                      size: 18, color: C.red600)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('余额预警',
                                      style: TS.body(
                                          size: 11,
                                          weight: FontWeight.w500,
                                          color: C.red600)),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text('2',
                                          style: TS.headline(
                                              size: 22,
                                              weight: FontWeight.w600,
                                              color: C.red600)),
                                      const SizedBox(width: 3),
                                      Text('需充值',
                                          style: TS.body(size: 11, color: C.slate500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  */
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 待接入第三方余额接口后恢复该区域。
  /*
  // ===================== API 算力与充值余量 =====================
  Widget _balanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const MIcon(MSym.speed, size: 20, color: C.emerald600),
                const SizedBox(width: 6),
                Text('API 算力与充值余量',
                    style: TS.body(size: 18, weight: FontWeight.w600, color: C.slate900)),
              ],
            ),
            Row(
              children: [
                Text('设置预警阈值', style: TS.mono(size: 13, color: C.emerald600)),
                const MIcon(MSym.chevron_right, size: 14, color: C.emerald600),
              ],
            ),
          ],
        ),
        const SizedBox(height: kCardGap),
        const _ApiCard(
          icon: MSym.smart_toy,
          iconBg: C.slate100,
          iconBorder: C.slate200,
          iconColor: C.slate800,
          name: 'OpenAI Platform',
          badge: '余额不足',
          badgeStyle: _BadgeStyle.critical,
          models: 'gpt-4o / text-embedding-3',
          amount: '\$14.20',
          amountColor: C.red600,
          limitLabel: '上限 \$100.00',
          progress: 0.142,
          progressColor: C.red500,
          rate: '消耗速率: ~\$2.40/天',
          rateAlert: '预计 5.9 天后耗尽',
          footer: '自动扣款: 未开启',
          footerIcon: MSym.credit_card,
          actionLabel: '充值 \$50',
          actionIcon: MSym.bolt,
          leftAccent: true,
          onTapDetail: true,
        ),
        const SizedBox(height: kCardGap),
        const _ApiCard(
          icon: MSym.psychology,
          iconBg: C.indigo50,
          iconBorder: C.indigo100,
          iconColor: C.indigo600,
          name: 'Anthropic Claude',
          badge: '充足',
          badgeStyle: _BadgeStyle.healthy,
          models: 'claude-3-5-sonnet',
          amount: '\$48.60',
          amountColor: C.slate900,
          limitLabel: '自动阈值 \$20.00',
          progress: 0.65,
          progressColor: C.indigo500,
          rate: '日均消耗: ~\$1.15/天',
          rateAlert: '已绑定 Visa ****9014',
          rateAlertColor: C.slate600,
        ),
        const SizedBox(height: kCardGap),
        const _ApiCard(
          icon: MSym.token,
          iconBg: C.blue50,
          iconBorder: C.blue100,
          iconColor: C.blue600,
          name: 'DeepSeek (官方/SiliconFlow)',
          badge: '运行中',
          badgeStyle: _BadgeStyle.running,
          models: 'deepseek-v3 / deepseek-r1',
          amount: '¥156.80',
          amountColor: C.slate900,
          limitLabel: '约 \$21.72',
          limitLabelColor: C.emerald600,
          rate: '本地 IDE 映射已打通',
          rateAlert: '',
          footer: '本地 IDE 映射已打通',
          footerIcon: null,
          actionLabel: '充值 ¥100',
          actionIcon: MSym.arrow_forward,
          actionFilled: false,
          footerMono: true,
          footerDivider: true,
          onTapDetail: true,
        ),
      ],
    );
  }
  */

  // ===================== 活跃订阅清单 =====================
  Widget _subsSection(BuildContext context) {
    const subs = <_Sub>[
      _Sub(
        icon: MSym.forum,
        iconBg: C.emerald50,
        iconBorder: C.emerald100,
        iconColor: C.emerald600,
        name: 'ChatGPT Plus',
        tag: '月付',
        meta: '5月26日扣费 (8天后) · Visa ****4288',
        price: '\$20.00',
        note: '已确认扣款',
        noteColor: C.emerald600,
      ),
      _Sub(
        icon: MSym.code_blocks,
        iconBg: C.indigo50,
        iconBorder: C.indigo100,
        iconColor: C.indigo600,
        name: 'Claude Pro',
        tag: '月付',
        meta: '6月02日扣费 (15天后) · Apple 订阅',
        price: '\$20.00',
        note: '已连接',
        noteColor: C.indigo600,
      ),
      _Sub(
        icon: MSym.palette,
        iconBg: C.amber50,
        iconBorder: C.amber100,
        iconColor: C.amber600,
        name: 'Midjourney Standard',
        tag: '即将扣费',
        tagDanger: true,
        meta: '5月22日扣费 (4天后) · Mastercard ****8912',
        metaColor: C.red500,
        metaBold: true,
        price: '\$30.00',
        note: '4天后到期',
        noteColor: C.red600,
      ),
      _Sub(
        icon: MSym.terminal,
        iconBg: C.emerald50,
        iconBorder: C.emerald100,
        iconColor: C.emerald600,
        name: 'Cursor AI Pro',
        tag: '月付',
        meta: '5月29日扣费 · 自动续费生效中',
        price: '\$20.00',
        note: '正常',
        noteColor: C.slate500,
      ),
      _Sub(
        icon: MSym.laptop_mac,
        iconBg: C.slate100,
        iconBorder: C.slate200,
        iconColor: C.slate700,
        name: 'GitHub Copilot Pro',
        tag: '月付',
        meta: '6月10日扣费 · GitHub 账户直扣',
        price: '\$10.00',
        note: '正常',
        noteColor: C.slate500,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: kCardGap,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const MIcon(MSym.calendar_month, size: 20, color: C.slate700),
                const SizedBox(width: 6),
                Text('活跃订阅清单 (5)',
                    style: TS.body(size: 18, weight: FontWeight.w600, color: C.slate900)),
              ],
            ),
            Text('月固定 \$100.00', style: TS.mono(size: 13, color: C.slate500)),
          ],
        ),
        for (final s in subs) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/ai-detail'),
            child: _subItem(s),
          ),
        ],
      ],
    );
  }

  Widget _subItem(_Sub s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 3)],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: s.iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: s.iconBorder),
            ),
            child: Center(child: MIcon(s.icon, size: 20, color: s.iconColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(s.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.body(
                              size: 14, weight: FontWeight.w600, color: C.slate900)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: s.tagDanger ? C.red50 : C.slate100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: s.tagDanger ? C.red200 : C.slate200),
                      ),
                      child: Text(
                        s.tag,
                        style: TS.mono(
                          size: 9,
                          weight: s.tagDanger ? FontWeight.w600 : FontWeight.w400,
                          color: s.tagDanger ? C.red600 : C.slate600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(s.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(
                        size: 11,
                        weight: s.metaBold ? FontWeight.w500 : FontWeight.w400,
                        color: s.metaColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(s.price,
                  style: TS.mono(size: 14, weight: FontWeight.w700, color: C.slate900)),
              const SizedBox(height: 2),
              Text(s.note,
                  style: TS.mono(
                      size: 10, weight: FontWeight.w500, color: s.noteColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 充值与扣款明细 =====================
  Widget _flowSection(BuildContext context) {
    const items = <_Flow>[
      _Flow(
        icon: MSym.add_card,
        iconBg: C.emerald50,
        iconBorder: C.emerald100,
        iconColor: C.emerald600,
        title: 'OpenAI API 自动续费充值',
        meta: '5月15日 14:32 · 信用卡扣款',
        amount: '+\$50.00',
        amountColor: C.emerald600,
        note: '¥362.50',
      ),
      _Flow(
        icon: MSym.account_balance_wallet,
        iconBg: C.blue50,
        iconBorder: C.blue100,
        iconColor: C.blue600,
        title: 'DeepSeek 账户预充值',
        meta: '5月10日 09:15 · 微信支付',
        amount: '+¥100.00',
        amountColor: C.blue600,
        note: '已入账',
        noteMono: false,
        noteColor: C.emerald600,
      ),
      _Flow(
        icon: MSym.autorenew,
        iconBg: C.slate100,
        iconBorder: C.slate200,
        iconColor: C.slate500,
        title: 'Perplexity Pro 订阅扣费',
        meta: '5月02日 02:00 · 周期自动扣费',
        amount: '-\$20.00',
        amountColor: C.slate800,
        amountBold: false,
        note: '¥145.00 · 已记账',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: kCardGap,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const MIcon(MSym.receipt_long, size: 20, color: C.slate700),
                const SizedBox(width: 6),
                Text('充值与扣款明细',
                    style: TS.body(size: 18, weight: FontWeight.w600, color: C.slate900)),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/search'),
              child: Text('查看全部', style: TS.mono(size: 13, color: C.slate500)),
            ),
          ],
        ),
        for (final f in items) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/ai-detail'),
            child: _flowItem(f),
          ),
        ],
      ],
    );
  }

  Widget _flowItem(_Flow f) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 3)],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: f.iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: f.iconBorder),
            ),
            child: Center(child: MIcon(f.icon, size: 18, color: f.iconColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(size: 14, weight: FontWeight.w500, color: C.slate900)),
                const SizedBox(height: 2),
                Text(f.meta, style: TS.mono(size: 11, color: C.slate500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(f.amount,
                  style: TS.mono(
                      size: 14,
                      weight: f.amountBold ? FontWeight.w700 : FontWeight.w600,
                      color: f.amountColor)),
              const SizedBox(height: 2),
              Text(f.note,
                  style: f.noteMono
                      ? TS.mono(size: 11, color: C.slate500)
                      : TS.mono(size: 10, weight: FontWeight.w500, color: f.noteColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 添加按钮 + 快速记录弹窗 =====================
  Widget _addButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: GestureDetector(
        onTap: () => _showQuickAdd(context),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [C.emerald600, C.teal600]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MIcon(MSym.add_circle, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text('添加 AI 订阅 / 充值记录',
                  style: TS.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _QuickAddModal(),
    );
  }
}

// ===================== 私有数据与组件 =====================

// 余额监控组件暂存，待第三方余额接口接入后恢复。
/*
/// API 卡片徽标风格。
enum _BadgeStyle { critical, healthy, running }

/// API 算力余量卡片。
class _ApiCard extends StatelessWidget {
  const _ApiCard({
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.name,
    required this.badge,
    required this.badgeStyle,
    required this.models,
    required this.amount,
    required this.amountColor,
    required this.limitLabel,
    this.limitLabelColor = C.slate500,
    this.progress,
    this.progressColor,
    required this.rate,
    required this.rateAlert,
    this.rateAlertColor = C.red600,
    this.footer,
    this.footerIcon,
    this.actionLabel,
    this.actionIcon,
    this.leftAccent = false,
    this.footerDivider = false,
    this.onTapDetail = false,
    this.actionFilled = true,
    this.footerMono = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String name;
  final String badge;
  final _BadgeStyle badgeStyle;
  final String models;
  final String amount;
  final Color amountColor;
  final String limitLabel;
  final Color limitLabelColor;
  final double? progress;
  final Color? progressColor;
  final String rate;
  final String rateAlert;
  final Color rateAlertColor;
  final String? footer;
  final IconData? footerIcon;
  final String? actionLabel;
  final IconData? actionIcon;
  final bool leftAccent;
  final bool footerDivider;
  final bool onTapDetail;
  final bool actionFilled;
  final bool footerMono;

  @override
  Widget build(BuildContext context) {
    final badgeColors = switch (badgeStyle) {
      _BadgeStyle.critical => (C.red50, C.red600, C.red200),
      _BadgeStyle.healthy => (C.emerald50, C.emerald600, C.emerald200),
      _BadgeStyle.running => (C.blue50, C.blue600, C.blue200),
    };
    return GestureDetector(
      onTap: onTapDetail ? () => Navigator.of(context).pushNamed('/ai-detail') : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 3)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (leftAccent)
              Positioned(
                left: -16,
                top: 0,
                bottom: 0,
                child: Container(width: 6, color: C.red500),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: iconBorder),
                      ),
                      child: Center(child: MIcon(icon, size: 22, color: iconColor)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                            children: [
                              Text(name,
                                  maxLines: 1,
                                  style: TS.body(size: 16,
                                      weight: FontWeight.w600,
                                      color: C.slate900)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColors.$1,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: badgeColors.$3),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (badgeStyle == _BadgeStyle.critical) ...[
                                      const MIcon(MSym.priority_high,
                                          size: 11, color: C.red600),
                                      const SizedBox(width: 2),
                                    ] else if (badgeStyle ==
                                        _BadgeStyle.healthy) ...[
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                            color: C.emerald500,
                                            shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 4),
                                    ] else ...[
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                            color: C.blue500,
                                            shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(badge,
                                        style: TS.mono(size: 11,
                                            weight: FontWeight.w600,
                                            color: badgeColors.$2)),
                                  ],
                                ),
                              ),
                            ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(models, style: TS.mono(size: 11, color: C.slate500)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(amount,
                            style: TextStyle(
                              fontFamily: F.display,
                              fontSize: 22,
                              height: 1.0,
                              fontWeight: FontWeight.w700,
                              color: amountColor,
                              leadingDistribution:
                                  TextLeadingDistribution.even,
                            )),
                        const SizedBox(height: 2),
                        Text(limitLabel,
                            style: TS.mono(size: 11, weight: FontWeight.w500,
                                color: limitLabelColor)),
                      ],
                    ),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 8,
                      child: Stack(
                        children: [
                          Container(color: C.slate100),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(color: progressColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (footerDivider) const SizedBox(height: 10),
                if (footerDivider)
                  const Divider(color: C.slate100, height: 1, thickness: 1),
                if (footerDivider) const SizedBox(height: 8),
                if (rateAlert.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(rate,
                            style: TS.mono(size: 11, color: C.slate500)),
                      ),
                      Text(rateAlert,
                          style: TS.mono(size: 11, weight: FontWeight.w500,
                              color: rateAlertColor)),
                    ],
                  ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (footerIcon != null) ...[
                            MIcon(footerIcon!, size: 16, color: C.slate400),
                            const SizedBox(width: 4),
                          ],
                          Text(footer ?? '',
                              style: footerMono
                                  ? TS.mono(size: 11, color: C.slate500)
                                  : TS.body(size: 14, color: C.slate500)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/ai-detail'),
                        child: actionFilled
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: C.emerald500,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x14000000), blurRadius: 3),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    MIcon(actionIcon!, size: 16,
                                        color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(actionLabel!,
                                        style: TS.mono(size: 13,
                                            weight: FontWeight.w700,
                                            color: Colors.white)),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Text(actionLabel!,
                                      style: TS.mono(size: 11,
                                          weight: FontWeight.w500,
                                          color: C.emerald600)),
                                  const SizedBox(width: 2),
                                  const MIcon(MSym.arrow_forward,
                                      size: 14, color: C.emerald600),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/

/// 订阅条目数据。
class _Sub {
  const _Sub({
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.name,
    required this.tag,
    required this.meta,
    required this.price,
    required this.note,
    required this.noteColor,
    this.tagDanger = false,
    this.metaColor = C.slate500,
    this.metaBold = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String name;
  final String tag;
  final bool tagDanger;
  final String meta;
  final Color metaColor;
  final bool metaBold;
  final String price;
  final String note;
  final Color noteColor;
}

/// 充值扣款条目数据。
class _Flow {
  const _Flow({
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.title,
    required this.meta,
    required this.amount,
    required this.amountColor,
    required this.note,
    this.amountBold = true,
    this.noteMono = true,
    this.noteColor = C.slate500,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String title;
  final String meta;
  final String amount;
  final Color amountColor;
  final bool amountBold;
  final String note;
  final bool noteMono;
  final Color noteColor;
}

/// 「记录新 AI 开销」快速弹窗（对应 HTML hidden modal）。
class _QuickAddModal extends StatefulWidget {
  const _QuickAddModal();

  @override
  State<_QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends State<_QuickAddModal> {
  bool _apiType = true; // 服务类型：API 充值 / 周期性订阅

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const PageContentInsets(),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.slate200),
          boxShadow: const [
            BoxShadow(color: Color(0x59000000), blurRadius: 25, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const MIcon(MSym.add_card, size: 24, color: C.emerald600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('记录新 AI 开销',
                      style: TS.body(size: 18, weight: FontWeight.w600, color: C.slate900)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: C.slate100, shape: BoxShape.circle),
                    child: const Center(
                        child: MIcon(MSym.close, size: 18, color: C.slate500)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('服务类型', style: TS.body(size: 12, color: C.slate500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _apiType = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _apiType ? C.emerald50 : C.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _apiType ? C.emerald300 : Colors.transparent),
                      ),
                      child: Text('API 充值',
                          textAlign: TextAlign.center,
                          style: TS.body(
                              size: 14,
                              weight: FontWeight.w600,
                              color: _apiType ? C.emerald700 : C.slate600)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _apiType = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_apiType ? C.emerald50 : C.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: !_apiType ? C.emerald300 : Colors.transparent),
                      ),
                      child: Text('周期性订阅',
                          textAlign: TextAlign.center,
                          style: TS.body(
                              size: 14,
                              weight:
                                  !_apiType ? FontWeight.w600 : FontWeight.w400,
                              color: !_apiType ? C.emerald700 : C.slate600)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('平台 / 模型供应商', style: TS.body(size: 12, color: C.slate500)),
            const SizedBox(height: 8),
            const FieldX(hint: '例如 OpenAI, Claude, Midjourney...'),
            const SizedBox(height: 12),
            Text('金额 (\$ / ¥)', style: TS.body(size: 12, color: C.slate500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('\$',
                    style: TS.mono(size: 16, weight: FontWeight.w700, color: C.emerald600)),
                const SizedBox(width: 8),
                const Expanded(
                  child: FieldX(
                    hint: '20.00',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    mono: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: C.emerald500,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Center(
                  child: Text('确认入账',
                      style: TS.body(size: 14, weight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
