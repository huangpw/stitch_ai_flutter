import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 日常记账首页（设计稿 _13）— 月份选择、月度支出总览、快捷动作、
/// 分类过滤、账单明细与 AI 订阅分流提示。
class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（头像 + 标题 + 搜索/通知）----
          GlassHeader.tab(
            title: '日常记账',
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _monthBar(),
                  const SizedBox(height: 14),
                  _overviewCard(),
                  const SizedBox(height: 10),
                  _quickActions(context),
                  const SizedBox(height: 12),
                  _categoryPills(),
                  const SizedBox(height: 14),
                  _TxGroup(
                    header: '今天',
                    dateLabel: '5月18日 星期日',
                    totalLabel: '今日支出 ¥274.50',
                    items: const [
                      _Tx(
                        icon: MSym.local_cafe,
                        tint: C.emerald50,
                        border: C.emerald100,
                        iconColor: C.emerald600,
                        title: '星巴克臻选咖啡',
                        category: '餐饮支出',
                        channel: '微信支付',
                        channelStyle: _ChannelStyle.emerald,
                        time: '09:42',
                        amount: '-¥38.00',
                        note: '已自动核对',
                        noteColor: C.emerald600,
                      ),
                      _Tx(
                        icon: MSym.shopping_basket,
                        tint: C.sky50,
                        border: C.sky100,
                        iconColor: C.sky600,
                        title: '盒马鲜生生鲜采买',
                        category: '食品日用',
                        channel: '支付宝',
                        channelStyle: _ChannelStyle.sky,
                        time: '14:15',
                        amount: '-¥186.50',
                        note: '电子小票已存',
                      ),
                      _Tx(
                        icon: MSym.directions_subway,
                        tint: C.indigo50,
                        border: C.indigo100,
                        iconColor: C.indigo600,
                        title: '地铁通勤卡充值',
                        category: '交通出行',
                        channel: '快捷免密',
                        channelStyle: _ChannelStyle.slate,
                        time: '18:30',
                        amount: '-¥50.00',
                        note: '享交通补贴',
                      ),
                    ],
                  ),
                  _TxGroup(
                    header: '昨天',
                    dateLabel: '5月17日 星期六',
                    totalLabel: '昨日支出 ¥544.00',
                    items: const [
                      _Tx(
                        icon: MSym.checkroom,
                        tint: C.emerald50,
                        border: C.emerald100,
                        iconColor: C.emerald600,
                        title: '优衣库夏季服饰采买',
                        category: '服饰购物',
                        channel: '招商信用卡',
                        channelStyle: _ChannelStyle.sky,
                        time: '16:40',
                        amount: '-¥399.00',
                        note: '个人生活',
                      ),
                      _Tx(
                        icon: MSym.restaurant,
                        tint: C.amber50,
                        border: C.amber100,
                        iconColor: C.amber600,
                        title: '周末朋友聚餐AA分摊',
                        category: '餐饮美食',
                        channel: '微信支付',
                        channelStyle: _ChannelStyle.emerald,
                        time: '20:18',
                        amount: '-¥145.00',
                        note: '社交聚会',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _aiSplitCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 月份选择器 & AI 状态徽标 ----
  Widget _monthBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 3),
              ],
            ),
            child: Row(
              children: [
                const MIcon(MSym.calendar_month, size: 18, color: C.emerald600),
                const SizedBox(width: 6),
                Text('2025年 5月',
                    style: TS.headline(size: 15, weight: FontWeight.w600, color: C.slate800)),
                const SizedBox(width: 4),
                const MIcon(MSym.expand_more, size: 16, color: C.slate400),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: C.emerald50,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: C.emerald100),
            ),
            child: Row(
              children: [
                const PulsingDot(color: C.emerald500, size: 6),
                const SizedBox(width: 6),
                Text('AI智能分流中',
                    style: TS.mono(size: 11, weight: FontWeight.w500, color: C.emerald700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- 本月日常累计支出主卡片 ----
  Widget _overviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0D000000)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
          BoxShadow(
              color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 柔和背景渐变饰斑
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.emerald100.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFCFFAFE).withValues(alpha: 0.3),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标签与预算分析入口
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: C.emerald50,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: C.emerald100),
                    ),
                    child: Row(
                      children: [
                        const MIcon(MSym.verified_user,
                            size: 14, color: C.emerald700),
                        const SizedBox(width: 6),
                        Text('日常消费 (已剔除AI模型算力开销)',
                            style: TS.mono(
                                size: 11, weight: FontWeight.w500, color: C.emerald700)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text('预算分析',
                          style: TS.body(size: 12, color: C.slate500)),
                      const MIcon(MSym.chevron_right, size: 14, color: C.slate500),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 主支出大金额
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('本月日常累计综合支出',
                      style: TS.mono(size: 11, weight: FontWeight.w500, color: C.slate500)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('¥8,450',
                          style: TextStyle(
                              fontFamily: F.display,
                              fontSize: 34,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.02,
                              color: C.slate900,
                              leadingDistribution:
                                  TextLeadingDistribution.even)),
                      Text('.00',
                          style: TS.headline(size: 20, weight: FontWeight.w600, color: C.slate500)),
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(left: 0),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: C.slate100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('折合人民币 · 纯生活开销',
                            style: TS.mono(size: 11, color: C.slate500)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 月度预算进度
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.slate100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('月度预算限额 ¥12,000.00',
                            style: TS.body(size: 12, color: C.slate500)),
                        Text.rich(
                          TextSpan(
                            style: TS.mono(size: 12, color: C.slate700),
                            children: const [
                              TextSpan(text: '剩余额度 '),
                              TextSpan(
                                  text: '¥3,550.00',
                                  style: TextStyle(
                                      color: C.emerald600,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 8,
                        child: Stack(
                          children: [
                            Container(color: C.slate200),
                            FractionallySizedBox(
                              widthFactor: 0.704,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [C.emerald500, C.teal400]),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('支出进度 70.4%',
                            style: TS.mono(size: 11, color: C.slate500)),
                        Text('按日均节奏预计平稳正常',
                            style: TS.mono(size: 11, color: C.slate500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // 收入与净结余
              Row(
                children: [
                  Expanded(
                    child: _miniStat(
                      icon: MSym.arrow_downward,
                      iconColor: C.sky500,
                      label: '本月总收入',
                      value: '¥24,500.00',
                      valueColor: C.slate900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _miniStat(
                      icon: MSym.account_balance,
                      iconColor: C.emerald600,
                      label: '财务净结余',
                      value: '+¥16,050.00',
                      valueColor: C.emerald600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MIcon(icon, size: 15, color: iconColor),
              const SizedBox(width: 4),
              Text(label, style: TS.body(size: 12, color: C.slate500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: TS.headline(size: 17, weight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }

  // ---- 快捷动作三联 ----
  Widget _quickActions(BuildContext context) {
    const actions = <(IconData, String, Color, Color, Color, String)>[
      (MSym.mic, '语音记账', C.emerald50, C.emerald600, C.emerald300, '/add-expense'),
      (MSym.document_scanner, '拍照识别票据', C.sky50, C.sky600, C.sky300, '/ai-scan'),
      (MSym.edit_square, '手动极速录入', C.violet50, C.violet600, C.violet300, '/add-expense'),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).pushNamed(actions[i].$6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: actions[i].$3,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: MIcon(actions[i].$1,
                                size: 19, color: actions[i].$4)),
                      ),
                      const SizedBox(height: 6),
                      Text(actions[i].$2,
                          style: TS.body(
                              size: 12,
                              weight: FontWeight.w500,
                              color: C.slate800)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---- 分类胶囊过滤 ----
  Widget _categoryPills() {
    const cats = <(String, String)>[
      ('餐饮美食', '¥3,240'),
      ('居住房租', '¥3,500'),
      ('交通出行', '¥680'),
      ('休闲娱乐', '¥580'),
      ('数码生活', '¥450'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: C.emerald500,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 3),
              ],
            ),
            child: Text('全部分类',
                style: TS.body(size: 12, weight: FontWeight.w500, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          for (final (name, amount) in cats) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
              ),
              child: Row(
                children: [
                  Text(name, style: TS.body(size: 12, color: C.slate600)),
                  const SizedBox(width: 4),
                  Text(amount, style: TS.mono(size: 11, color: C.slate400)),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  // ---- AI 订阅分流提示卡片 ----
  Widget _aiSplitCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.violet50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.violet100),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: C.violet100,
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: MIcon(MSym.psychology, size: 18, color: C.violet700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI订阅自动分离机制生效中',
                    style: TS.body(size: 12, weight: FontWeight.w600, color: const Color(0xFF4C1D95))),
                const SizedBox(height: 2),
                Text('本月折合 ¥1,248.50 的接口调用与大模型订阅已转入专用算力账本',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(size: 11, color: C.violet700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 账单支付渠道标签配色。
enum _ChannelStyle { emerald, sky, slate }

/// 日期分组账单列表。
class _TxGroup extends StatelessWidget {
  const _TxGroup({
    required this.header,
    required this.dateLabel,
    required this.totalLabel,
    required this.items,
  });

  final String header;
  final String dateLabel;
  final String totalLabel;
  final List<_Tx> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(header,
                      style: TS.body(size: 15, weight: FontWeight.w600, color: C.slate900)),
                  const SizedBox(width: 8),
                  Text(dateLabel, style: TS.mono(size: 11, color: C.slate500)),
                ],
              ),
              Text(totalLabel, style: TS.mono(size: 12, color: C.slate500)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final tx in items) ...[
          tx,
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// 单条账单项。
class _Tx extends StatelessWidget {
  const _Tx({
    required this.icon,
    required this.tint,
    required this.border,
    required this.iconColor,
    required this.title,
    required this.category,
    required this.channel,
    required this.channelStyle,
    required this.time,
    required this.amount,
    required this.note,
    this.noteColor = C.slate400,
  });

  final IconData icon;
  final Color tint;
  final Color border;
  final Color iconColor;
  final String title;
  final String category;
  final String channel;
  final _ChannelStyle channelStyle;
  final String time;
  final String amount;
  final String note;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    final (channelBg, channelFg) = switch (channelStyle) {
      _ChannelStyle.emerald => (C.emerald50, C.emerald700),
      _ChannelStyle.sky => (C.sky50, C.sky700),
      _ChannelStyle.slate => (C.slate100, C.slate600),
    };
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/tx-detail'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 3),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: Center(child: MIcon(icon, size: 20, color: iconColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 14, weight: FontWeight.w500, color: C.slate900)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _chip(category, C.slate100, C.slate600, mono: false),
                      const SizedBox(width: 6),
                      _chip(channel, channelBg, channelFg, mono: true),
                      const SizedBox(width: 6),
                      Text(time, style: TS.mono(size: 11, color: C.slate400)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount,
                    style: TS.headline(size: 16, weight: FontWeight.w600, color: C.slate900)),
                const SizedBox(height: 2),
                Text(note,
                    style: TS.mono(size: 10, weight: FontWeight.w500, color: noteColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg, {required bool mono}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: mono
              ? TS.mono(size: 10, color: fg)
              : TS.mono(size: 10, weight: FontWeight.w500, color: fg)),
    );
  }
}
