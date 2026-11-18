import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 全局搜索（设计稿 _14）— 搜索框即时过滤本地账单、双轨/收入过滤胶囊、
/// 最近搜索与智流快搜场景、匹配结果列表（点击进单笔详情）。
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum _BadgeStyle { emerald, purple, slate }

enum _Track { all, daily, ai, income }

/// 本地匹配结果数据（与设计稿 5 条账单一致）。
class _Hit {
  const _Hit({
    required this.icon,
    required this.tint,
    required this.border,
    required this.iconColor,
    required this.title,
    required this.meta,
    required this.amount,
    required this.cnyValue,
    required this.track,
    required this.tags,
    this.badge,
    this.badgeStyle = _BadgeStyle.emerald,
    this.footLabel,
    this.cnyNote,
    this.aiFoot = false,
    this.aiBorder = false,
  });

  final IconData icon;
  final Color tint;
  final Color border;
  final Color iconColor;
  final String title;
  final String meta;
  final String amount; // 展示金额（可能为美元）
  final double cnyValue; // 折合人民币数值，用于合计
  final _Track track;
  final String tags; // 可搜索关键词池（空格分隔）
  final String? badge;
  final _BadgeStyle badgeStyle;
  final String? footLabel; // 右下角轨道标签（label-caps）
  final String? cnyNote; // 右下角折合备注（label-code）
  final bool aiFoot; // 是否带 AI 汇率核销脚注
  final bool aiBorder; // AI 卡片紫色描边
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl =
      TextEditingController(text: '近期消费'); // 设计稿默认演示查询
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  int _filter = 0; // 0 全部 / 1 日常 / 2 AI / 3 收入 / 4 筛选(不参与)
  List<String> _history = const [
    '星巴克',
    'OpenAI API',
    'ChatGPT Plus',
    '盒马生鲜',
    'Claude 3.5',
    '房租',
    '优衣库',
  ];

  static const _hits = <_Hit>[
    _Hit(
      icon: MSym.local_cafe,
      tint: C.emerald50,
      border: C.emerald100,
      iconColor: C.emerald600,
      title: '星巴克臻选咖啡',
      badge: '已自动核对',
      badgeStyle: _BadgeStyle.emerald,
      meta: '餐饮美食 · 微信支付 · 05-18 09:42',
      amount: '-¥38.00',
      cnyValue: 38.00,
      track: _Track.daily,
      footLabel: '日常轨道',
      tags: '近期消费 星巴克 咖啡 餐饮 美食 微信支付 餐饮聚餐发票凭据 发票 凭据',
    ),
    _Hit(
      icon: MSym.memory,
      tint: C.purple50,
      border: C.purple100,
      iconColor: C.purple600,
      title: 'OpenAI 额度充值',
      badge: 'Tier-4 算力',
      badgeStyle: _BadgeStyle.purple,
      meta: 'AI生产力 · 招行外币卡 · 05-15 14:32',
      amount: '-\$50.00',
      cnyValue: 362.50,
      track: _Track.ai,
      cnyNote: '折合 -¥362.50',
      aiFoot: true,
      aiBorder: true,
      tags:
          '近期消费 OpenAI OpenAI API API 额度 充值 AI 生产力 算力 Tier-4 招行外币卡 外币 信用卡 支付 外币信用卡支付 本月 AI 订阅 续费 订阅续费 本月AI订阅续费 Token 预存 汇率 折算',
    ),
    _Hit(
      icon: MSym.shopping_basket,
      tint: C.sky50,
      border: C.sky100,
      iconColor: C.sky600,
      title: '盒马生鲜日用采买',
      badge: '小票已存',
      badgeStyle: _BadgeStyle.slate,
      meta: '食品日用 · 支付宝 · 05-18 14:15',
      amount: '-¥186.50',
      cnyValue: 186.50,
      track: _Track.daily,
      footLabel: '日常消费',
      tags: '近期消费 盒马 生鲜 日用 采买 食品日用 支付宝 小票',
    ),
    _Hit(
      icon: MSym.autorenew,
      tint: C.purple50,
      border: C.purple100,
      iconColor: C.purple600,
      title: 'ChatGPT Plus 订阅扣费',
      badge: 'AI月结',
      badgeStyle: _BadgeStyle.purple,
      meta: 'AI周期订阅 · Stripe月结 · 05-01 08:00',
      amount: '-\$20.00',
      cnyValue: 145.00,
      track: _Track.ai,
      cnyNote: '折合 -¥145.00',
      tags:
          '近期消费 ChatGPT ChatGPT Plus Plus 订阅 扣费 AI 周期订阅 Stripe 月结 外币 本月 AI 订阅 续费 订阅续费 本月AI订阅续费 外币信用卡支付',
    ),
    _Hit(
      icon: MSym.checkroom,
      tint: C.slate100,
      border: C.slate200,
      iconColor: C.slate700,
      title: '优衣库夏季服饰采买',
      meta: '服饰购物 · 招商信用卡 · 05-17 16:40',
      amount: '-¥399.00',
      cnyValue: 399.00,
      track: _Track.daily,
      footLabel: '信用卡分期可选',
      tags: '近期消费 优衣库 夏季 服饰 采买 服饰购物 招商信用卡 信用卡 分期 大额 大额开销',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _query => _ctrl.text.trim();

  /// 输入即时过滤：查询词按空格分词，每个词都需命中条目关键词池；
  /// 同时叠加双轨/收入过滤胶囊。
  List<_Hit> get _filtered {
    final tokens = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    final track = _Track.values[_filter];
    return _hits.where((h) {
      if (track != _Track.all && h.track != track) return false;
      if (tokens.isEmpty) return true;
      final hay = h.tags.toLowerCase();
      return tokens.every(hay.contains);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（标准返回键 + 标题；搜索框在内容区顶部）----
          GlassHeader.back(title: '全局搜索'),
          Expanded(
            child: SingleChildScrollView(
              padding: const PageContentInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _searchBar(),
                  const SizedBox(height: kCardGap),
                  _filterPills(),
                  const SizedBox(height: kCardGap),
                  _historySection(),
                  const SizedBox(height: kCardGap),
                  _resultsSection(),
                  const SizedBox(height: kCardGap),
                  _footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 搜索框（focus-within 发光） =====================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _focused
                    ? Colors.white
                    : C.slate100.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _focused ? C.emerald500 : const Color(0xB3E2E8F0),
                ),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: C.emerald500.withValues(alpha: 0.3),
                          blurRadius: 0,
                          spreadRadius: 2.5,
                        ),
                      ]
                    : const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 3),
                      ],
              ),
              child: Row(
                children: [
                  const MIcon(MSym.search, size: 18, color: C.slate400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      cursorColor: C.emerald500,
                      style: TS.body(size: 14, color: C.slate800),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: '搜索账单、商户、分类、模型名称或备注...',
                        hintStyle: TS.body(size: 14, color: C.slate400),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _ctrl.clear();
                        setState(() {});
                        _focus.requestFocus();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: const BoxDecoration(
                          color: C.slate200,
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Center(child: MIcon(MSym.close, size: 14, color: C.slate500)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text('取消',
                  style:
                      TS.body(size: 14, weight: FontWeight.w500, color: C.emerald600)),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 双轨与收入过滤胶囊 =====================
  Widget _filterPills() {
    Widget pill({
      required String label,
      required int index,
      bool purpleTint = false,
      bool withDot = false,
      IconData? trailingIcon,
    }) {
      final active = _filter == index;
      final (bg, fg, border) = purpleTint && !active
          ? (C.purple50, C.violet700, C.violet200) // purple-50/200/700
          : (Colors.white, C.slate500, C.slate200);
      return GestureDetector(
        onTap: index == 4 ? null : () => setState(() => _filter = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? C.emerald500 : bg,
            borderRadius: BorderRadius.circular(999),
            border: active ? null : Border.all(color: border),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 3),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (withDot) ...[
                PulsingDot(color: C.purple500, size: 6),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TS.mono(
                  size: 11,
                  weight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : fg,
                  letterSpacing: 0.9,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 2),
                MIcon(trailingIcon, size: 14, color: C.slate500),
              ],
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          pill(label: '全部', index: 0),
          const SizedBox(width: 4),
          pill(label: '日常消费 (已剔除AI)', index: 1),
          const SizedBox(width: 4),
          pill(label: 'AI算力与模型', index: 2, purpleTint: true, withDot: true),
          const SizedBox(width: 4),
          pill(label: '收入明细', index: 3),
          const SizedBox(width: 4),
          pill(label: '筛选 (日期/金额)', index: 4, trailingIcon: MSym.arrow_drop_down),
        ],
      ),
    );
  }

  // ===================== 最近搜索 + 智流快搜 =====================
  Widget _historySection() {
    Widget chip(String label, {bool purple = false, IconData? icon}) {
      return GestureDetector(
        onTap: () {
          _ctrl.text = label;
          _ctrl.selection =
              TextSelection.collapsed(offset: _ctrl.text.length);
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: purple ? C.purple50 : C.slate100,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: purple
                    ? C.purple100.withValues(alpha: 0.7)
                    : const Color(0xB3E2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                MIcon(icon, size: 13, color: C.violet700), // purple-700
                const SizedBox(width: 4),
              ],
              Text(label,
                  style: TS.body(
                      size: 12,
                      weight: FontWeight.w500,
                      color: purple ? C.violet700 : C.slate700)),
            ],
          ),
        ),
      );
    }

    Widget shortcut(String label, IconData icon, Color tint, Color tintBorder,
        Color iconColor) {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            _ctrl.text = label;
            _ctrl.selection =
                TextSelection.collapsed(offset: _ctrl.text.length);
            setState(() {});
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1FE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 3),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tintBorder),
                  ),
                  child: Center(child: MIcon(icon, size: 18, color: iconColor)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(
                          size: 12, weight: FontWeight.w500, color: C.slate800)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 最近搜索卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1FE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 3),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const MIcon(MSym.history, size: 16, color: C.slate400),
                  const SizedBox(width: 6),
                  Text('最近搜索',
                      style: TS.body(
                          size: 12, weight: FontWeight.w600, color: C.slate400)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _history = const []),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child:
                          MIcon(MSym.delete_sweep, size: 16, color: C.slate400),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('暂无最近搜索记录',
                      style: TextStyle(
                          fontFamily: F.sans,
                          fontSize: 12,
                          color: C.slate600)),
                )
              else
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in _history)
                      chip(tag,
                          purple: tag == 'OpenAI API' ||
                              tag == 'ChatGPT Plus' ||
                              tag == 'Claude 3.5',
                          icon: tag == 'OpenAI API' ? MSym.smart_toy : null),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 常用筛选场景
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text('常用筛选场景',
                      style: TS.body(
                          size: 12, weight: FontWeight.w600, color: C.slate400)),
                  const Spacer(),
                  Text('智流快搜',
                      style: TS.body(
                          size: 12, weight: FontWeight.w600, color: C.emerald600)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                shortcut('超过 ¥500 大额开销', MSym.payments, C.emerald50,
                    C.emerald100, C.emerald600),
                const SizedBox(width: 4),
                shortcut('本月 AI 订阅续费', MSym.cached, C.purple50, C.purple100,
                    C.purple600),
              ],
            ),
            const SizedBox(width: 4, height: 4),
            Row(
              children: [
                shortcut('餐饮聚餐发票凭据', MSym.receipt_long, C.amber50,
                    C.amber100, C.amber600),
                const SizedBox(width: 4),
                shortcut('外币信用卡支付', MSym.credit_card, C.indigo50,
                    C.indigo100, C.indigo600),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ===================== 匹配结果列表 =====================
  Widget _resultsSection() {
    final hits = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: C.emerald500, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('找到 ${hits.length} 笔相关账单',
                  style:
                      TS.mono(size: 13, weight: FontWeight.w500, color: C.slate700)),
              const Spacer(),
              Text.rich(
                TextSpan(
                  style: TS.mono(size: 13, color: C.slate500),
                  children: [
                    const TextSpan(text: '合计支出 '),
                    // 设计稿固定值（其明细清单本身加总为 ¥1,131.00，
                    // 1:1 还原以设计稿展示数值为准）
                    const TextSpan(
                      text: '¥1,673.50',
                      style: TextStyle(
                        fontFamily: F.mono,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: C.slate900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (hits.isEmpty)
          _emptyState()
        else
          for (var i = 0; i < hits.length; i++) ...[
            if (i > 0) const SizedBox(height: kCardGap),
            _ResultCard(hit: hits[i]),
          ],
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1FE2E8F0)),
      ),
      child: Column(
        children: [
          const MIcon(MSym.search, size: 36, color: C.slate300),
          const SizedBox(height: 12),
          Text('未找到相关账单',
              style: TS.body(size: 15, weight: FontWeight.w600, color: C.slate500)),
          const SizedBox(height: 4),
          Text('换个关键词，或清空筛选条件再试试',
              style: TS.body(size: 12, color: C.slate400)),
        ],
      ),
    );
  }

  // ===================== 结尾指示与导出 =====================
  Widget _footer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MIcon(MSym.verified, size: 16, color: C.emerald500),
            const SizedBox(width: 8),
            Text('已显示全部匹配账单 · 支持高级按月导出',
                style: TS.mono(size: 13, color: C.slate400)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: C.emerald50,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: C.emerald200),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 3),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MIcon(MSym.download, size: 16, color: C.emerald600),
                const SizedBox(width: 6),
                Text('导出搜索筛选结果 (CSV / PDF)',
                    style: TS.mono(
                        size: 11,
                        weight: FontWeight.w600,
                        color: C.emerald700,
                        letterSpacing: 0.9)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 单条匹配结果卡片。
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.hit});

  final _Hit hit;

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg, badgeBorder) = switch (hit.badgeStyle) {
      _BadgeStyle.emerald => (C.emerald50, C.emerald700, C.emerald200),
      _BadgeStyle.purple => (C.purple50, C.violet700, C.violet200), // purple-50/200/700
      _BadgeStyle.slate => (C.slate100, C.slate600, C.slate200),
    };
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/tx-detail'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hit.aiBorder ? C.purple100 : const Color(0x1FE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 3),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hit.tint,
                    shape: BoxShape.circle,
                    border: Border.all(color: hit.border),
                  ),
                  child: Center(
                      child: MIcon(hit.icon, size: 20, color: hit.iconColor)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(hit.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TS.body(
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: C.slate900)),
                          ),
                          if (hit.badge != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: badgeBorder),
                              ),
                              child: Text(hit.badge!,
                                  style: TS.mono(
                                      size: 10,
                                      weight: FontWeight.w600,
                                      color: badgeFg,
                                      letterSpacing: 0.8)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(hit.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.body(size: 12, color: C.slate400)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // font-headline-md（Space Grotesk 22 粗体）
                    Text(hit.amount,
                        style: TS.headline(
                            size: 22,
                            weight: FontWeight.w700,
                            color: C.slate900,
                            letterSpacing: -0.01)),
                    const SizedBox(height: 2),
                    if (hit.footLabel != null)
                      Text(hit.footLabel!,
                          style: TS.mono(
                              size: 10,
                              weight: FontWeight.w600,
                              color: C.slate400,
                              letterSpacing: 0.8))
                    else if (hit.cnyNote != null)
                      Text(hit.cnyNote!,
                          style:
                              TS.mono(size: 12, weight: FontWeight.w500, color: C.slate400)),
                  ],
                ),
              ],
            ),
            // AI 卡片的汇率核销脚注
            if (hit.aiFoot) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: C.slate50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.slate100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: C.emerald500, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('汇率核销 7.2500 · 智能折算入账',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.mono(
                              size: 10,
                              weight: FontWeight.w600,
                              color: C.slate500,
                              letterSpacing: 0.8)),
                    ),
                    const SizedBox(width: 8),
                    Text('Token预存',
                        style: TS.mono(
                            size: 10,
                            weight: FontWeight.w500,
                            color: C.purple600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
