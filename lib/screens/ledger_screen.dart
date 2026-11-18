import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/monthly_finance.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 日常记账首页（设计稿 _13）— 月份选择、月度支出总览、快捷动作、
/// 分类过滤、账单明细与 AI 订阅分流提示。
class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  late DateTime _selectedMonth;
  String? _selectedCategory;

  static const _historyPageSize = 3;
  // 历史分页的本地示例数据；后续可替换为按年月查询的接口。
  static const _moreHistoryTransactions = <_Tx>[
    _Tx(
      icon: MSym.local_cafe,
      tint: C.emerald50,
      border: C.emerald100,
      iconColor: C.emerald600,
      title: '咖啡与早餐',
      category: '餐饮美食',
      channel: '微信支付',
      channelStyle: _ChannelStyle.emerald,
      time: '08:35',
      amount: '-¥28.00',
      note: '5月13日',
    ),
    _Tx(
      icon: MSym.shopping_basket,
      tint: C.sky50,
      border: C.sky100,
      iconColor: C.sky600,
      title: '超市生鲜采购',
      category: '食品日用',
      channel: '支付宝',
      channelStyle: _ChannelStyle.sky,
      time: '18:15',
      amount: '-¥120.00',
      note: '5月12日',
    ),
    _Tx(
      icon: MSym.shopping_bag,
      tint: C.indigo50,
      border: C.indigo100,
      iconColor: C.indigo600,
      title: '文具与办公用品',
      category: '日用购物',
      channel: '银行卡',
      channelStyle: _ChannelStyle.slate,
      time: '15:20',
      amount: '-¥69.00',
      note: '5月11日',
    ),
    _Tx(
      icon: MSym.restaurant,
      tint: C.amber50,
      border: C.amber100,
      iconColor: C.amber600,
      title: '周末晚餐',
      category: '餐饮美食',
      channel: '微信支付',
      channelStyle: _ChannelStyle.emerald,
      time: '19:10',
      amount: '-¥98.00',
      note: '5月10日',
    ),
    _Tx(
      icon: MSym.directions_subway,
      tint: C.indigo50,
      border: C.indigo100,
      iconColor: C.indigo600,
      title: '交通卡充值',
      category: '交通出行',
      channel: '支付宝',
      channelStyle: _ChannelStyle.sky,
      time: '09:00',
      amount: '-¥45.00',
      note: '5月9日',
    ),
    _Tx(
      icon: MSym.local_cafe,
      tint: C.emerald50,
      border: C.emerald100,
      iconColor: C.emerald600,
      title: '下午茶',
      category: '餐饮美食',
      channel: '微信支付',
      channelStyle: _ChannelStyle.emerald,
      time: '16:25',
      amount: '-¥18.00',
      note: '5月8日',
    ),
  ];

  final _scrollController = ScrollController();
  final _loadedHistoryTransactions = <_Tx>[];
  int _nextHistoryIndex = 0;
  int _historyLoadVersion = 0;
  bool _isLoadingHistory = false;

  bool get _hasMoreHistory =>
      _nextHistoryIndex < _moreHistoryTransactions.length;

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter <= 160) {
      _loadMoreHistory();
    }
  }

  void _scheduleHistoryCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScroll();
    });
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingHistory || !_hasMoreHistory) return;
    final loadVersion = _historyLoadVersion;
    setState(() => _isLoadingHistory = true);
    // 模拟异步分页，让加载状态在示例数据下也有明确反馈。
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted || loadVersion != _historyLoadVersion) return;
    final page = _moreHistoryTransactions
        .skip(_nextHistoryIndex)
        .take(_historyPageSize)
        .toList();
    setState(() {
      _loadedHistoryTransactions.addAll(page);
      _nextHistoryIndex += page.length;
      _isLoadingHistory = false;
    });
    // 筛选后本页可能不足一屏，继续补齐直到可滚动或没有更多数据。
    _scheduleHistoryCheck();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _scrollController.addListener(_onScroll);
    _scheduleHistoryCheck();
  }

  Future<void> _pickMonth() async {
    final currentYear = DateTime.now().year;
    final firstYear = currentYear - 100;
    final picker = Picker(
      adapter: PickerDataAdapter<String>(
        isArray: true,
        pickerData: [
          [
            for (var year = firstYear; year <= currentYear + 100; year++)
              '$year年',
          ],
          [for (var month = 1; month <= 12; month++) '$month月'],
        ],
      ),
      selecteds: [_selectedMonth.year - firstYear, _selectedMonth.month - 1],
      hideHeader: true,
      height: 220,
      itemExtent: 44,
      diameterRatio: 1.6,
      squeeze: 1.1,
      textAlign: TextAlign.center,
      backgroundColor: Colors.white,
      textStyle: TS.body(size: 21, color: C.slate400),
      selectedTextStyle: TS.body(
        size: 22,
        weight: FontWeight.w600,
        color: C.slate900,
      ),
      selectionOverlay: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: C.slate400.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    final selected = await picker.showModal<List<int>>(
      context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext, pickerWidget) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: C.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => picker.doCancel(sheetContext),
                    child: Text(
                      '取消',
                      style: TS.body(size: 16, color: C.slate500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '选择年月',
                      textAlign: TextAlign.center,
                      style: TS.body(
                        size: 17,
                        weight: FontWeight.w600,
                        color: C.slate900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => picker.doConfirm(sheetContext),
                    child: Text(
                      '确定',
                      style: TS.body(
                        size: 16,
                        weight: FontWeight.w600,
                        color: C.emerald600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5, color: C.slate100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: pickerWidget,
            ),
            TextButton(
              onPressed: () {
                final now = DateTime.now();
                final controllers = picker.state?.scrollController;
                if (controllers == null) return;
                controllers[0].animateToItem(
                  now.year - firstYear,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
                controllers[1].animateToItem(
                  now.month - 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
              },
              child: Text(
                '回到本月',
                style: TS.body(size: 14, color: C.emerald600),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    final month = DateTime(firstYear + selected[0], selected[1] + 1);
    if (month == _selectedMonth) return;
    setState(() {
      _selectedMonth = month;
      _historyLoadVersion++;
      _loadedHistoryTransactions.clear();
      _nextHistoryIndex = 0;
      _isLoadingHistory = false;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _scheduleHistoryCheck();
  }

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
              controller: _scrollController,
              padding: const PageContentInsets(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _monthBar(),
                  const SizedBox(height: kCardGap),
                  _overviewCard(),
                  const SizedBox(height: kCardGap),
                  _quickActions(context),
                  const SizedBox(height: kCardGap),
                  _categoryPills(),
                  const SizedBox(height: kCardGap),
                  ..._transactionList(),
                  const SizedBox(height: kCardGap),
                  // _aiSplitCard(),
                  _historyLoadFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_TxGroup> get _transactionGroups => const [
    _TxGroup(
      header: '今天',
      dateLabel: '5月18日 星期日',
      totalLabel: '今日支出 ¥274.50',
      items: [
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
      items: [
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
    _TxGroup(
      header: '历史',
      dateLabel: '5月16日及以前',
      totalLabel: '历史支出 ¥260.00',
      items: [
        _Tx(
          icon: MSym.restaurant,
          tint: C.amber50,
          border: C.amber100,
          iconColor: C.amber600,
          title: '工作日午餐',
          category: '餐饮美食',
          channel: '微信支付',
          channelStyle: _ChannelStyle.emerald,
          time: '12:30',
          amount: '-¥32.00',
          note: '5月16日',
        ),
        _Tx(
          icon: MSym.shopping_bag,
          tint: C.sky50,
          border: C.sky100,
          iconColor: C.sky600,
          title: '生活日用品补货',
          category: '食品日用',
          channel: '支付宝',
          channelStyle: _ChannelStyle.sky,
          time: '19:45',
          amount: '-¥128.00',
          note: '5月15日',
        ),
        _Tx(
          icon: MSym.home,
          tint: C.indigo50,
          border: C.indigo100,
          iconColor: C.indigo600,
          title: '五月宽带费用',
          category: '生活缴费',
          channel: '银行卡',
          channelStyle: _ChannelStyle.slate,
          time: '08:20',
          amount: '-¥100.00',
          note: '5月14日',
        ),
      ],
    ),
  ];

  List<Widget> _transactionList() {
    final groups = <_TxGroup>[];
    for (final group in _transactionGroups) {
      final source = group.header == '历史'
          ? [...group.items, ..._loadedHistoryTransactions]
          : group.items;
      final items = source.where((tx) {
        if (_selectedCategory == null) return true;
        final category = tx.category == '餐饮支出' ? '餐饮美食' : tx.category;
        return category == _selectedCategory;
      }).toList();
      if (items.isEmpty) continue;
      final total = items.fold<double>(
        0,
        (sum, tx) =>
            sum + double.parse(tx.amount.replaceAll(RegExp(r'[^0-9.]'), '')),
      );
      groups.add(
        _TxGroup(
          header: group.header,
          dateLabel: group.dateLabel,
          totalLabel: group.totalLabel.replaceFirst(
            RegExp(r'¥.*$'),
            '¥${total.toStringAsFixed(2)}',
          ),
          items: items,
        ),
      );
    }
    if (groups.isEmpty) {
      return [
        CardX(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              '暂无$_selectedCategory账单',
              textAlign: TextAlign.center,
              style: TS.body(size: 14, color: C.slate500),
            ),
          ),
        ),
      ];
    }
    return [
      for (var i = 0; i < groups.length; i++) ...[
        if (i > 0) const SizedBox(height: kCardGap),
        groups[i],
      ],
    ];
  }

  Widget _historyLoadFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoadingHistory) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: C.emerald500,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _isLoadingHistory
                ? '正在加载更多账单…'
                : _hasMoreHistory
                ? '上滑加载更多'
                : '没有更多了',
            style: TS.body(size: 12, color: C.slate400),
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
          Semantics(
            button: true,
            label: '选择年月',
            child: InkWell(
              onTap: _pickMonth,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                    const MIcon(
                      MSym.calendar_month,
                      size: 18,
                      color: C.emerald600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedMonth.year}年 ${_selectedMonth.month}月',
                      style: TS.headline(
                        size: 15,
                        weight: FontWeight.w600,
                        color: C.slate800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const MIcon(MSym.expand_more, size: 16, color: C.slate400),
                  ],
                ),
              ),
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
                Text(
                  'AI自动归档',
                  style: TS.mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: C.emerald700,
                  ),
                ),
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
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: C.emerald50,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: C.emerald100),
                    ),
                    child: Row(
                      children: [
                        const MIcon(
                          MSym.verified_user,
                          size: 14,
                          color: C.emerald700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '日常消费统计',
                          style: TS.mono(
                            size: 11,
                            weight: FontWeight.w500,
                            color: C.emerald700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/monthly-budget', arguments: _selectedMonth),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '预算分析',
                            style: TS.body(size: 12, color: C.slate500),
                          ),
                          const MIcon(
                            MSym.chevron_right,
                            size: 14,
                            color: C.slate500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 主支出大金额
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本月日常累计综合支出',
                    style: TS.mono(
                      size: 11,
                      weight: FontWeight.w500,
                      color: C.slate500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '¥8,450',
                        style: TextStyle(
                          fontFamily: F.display,
                          fontSize: 34,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.02,
                          color: C.slate900,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                      Text(
                        '.00',
                        style: TS.headline(
                          size: 20,
                          weight: FontWeight.w600,
                          color: C.slate500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(left: 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: C.slate100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '折合人民币 · 纯生活开销',
                          style: TS.mono(size: 11, color: C.slate500),
                        ),
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
                        Text(
                          '月度预算限额 ¥12,000.00',
                          style: TS.body(size: 12, color: C.slate500),
                        ),
                        Text.rich(
                          TextSpan(
                            style: TS.mono(size: 12, color: C.slate700),
                            children: const [
                              TextSpan(text: '剩余额度 '),
                              TextSpan(
                                text: '¥3,550.00',
                                style: TextStyle(
                                  color: C.emerald600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
                                    colors: [C.emerald500, C.teal400],
                                  ),
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
                        Text(
                          '支出进度 70.4%',
                          style: TS.mono(size: 11, color: C.slate500),
                        ),
                        Text(
                          '按日均节奏预计平稳正常',
                          style: TS.mono(size: 11, color: C.slate500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kCardGap),
              // 收入与净结余
              Row(
                children: [
                  Expanded(
                    child: _miniStat(
                      icon: MSym.arrow_downward,
                      iconColor: C.sky500,
                      label: '本月总收入',
                      value: MonthlyFinance.money(MonthlyFinance.income),
                      valueColor: C.slate900,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed('/monthly-income', arguments: _selectedMonth),
                    ),
                  ),
                  const SizedBox(width: kCardGap),
                  Expanded(
                    child: _miniStat(
                      icon: MSym.account_balance,
                      iconColor: C.emerald600,
                      label: '财务净结余',
                      value: MonthlyFinance.money(
                        MonthlyFinance.balance,
                        signed: true,
                      ),
                      valueColor: C.emerald600,
                      onTap: () => Navigator.of(context).pushNamed(
                        '/monthly-balance',
                        arguments: _selectedMonth,
                      ),
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: C.slate50,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
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
                  Expanded(
                    child: Text(
                      label,
                      style: TS.body(size: 12, color: C.slate500),
                    ),
                  ),
                  const MIcon(MSym.chevron_right, size: 14, color: C.slate400),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TS.headline(
                  size: 17,
                  weight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- 快捷动作三联 ----
  Widget _quickActions(BuildContext context) {
    const actions = <(IconData, String, Color, Color, Color, String)>[
      (
        MSym.mic,
        '语音记账',
        C.emerald50,
        C.emerald600,
        C.emerald300,
        '/add-expense',
      ),
      (MSym.image, '拍照识别', C.sky50, C.sky600, C.sky300, '/ai-scan'),
      (
        MSym.edit_square,
        '手动录入',
        C.violet50,
        C.violet600,
        C.violet300,
        '/add-expense',
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: kCardGap),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).pushNamed(actions[i].$6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: C.slate200.withValues(alpha: 0.8),
                    ),
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
                          child: MIcon(
                            actions[i].$1,
                            size: 19,
                            color: actions[i].$4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        actions[i].$2,
                        style: TS.body(
                          size: 12,
                          weight: FontWeight.w500,
                          color: C.slate800,
                        ),
                      ),
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
    Widget pill(String label, {String? amount, String? category}) {
      final selected = _selectedCategory == category;
      void select() {
        setState(() => _selectedCategory = category);
        _scheduleHistoryCheck();
      }

      return Semantics(
        button: true,
        selected: selected,
        label: label,
        onTap: select,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: select,
          excludeFromSemantics: true,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? C.emerald500 : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? C.emerald500
                    : C.slate200.withValues(alpha: 0.8),
              ),
              boxShadow: selected
                  ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 3)]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TS.body(
                    size: 12,
                    weight: FontWeight.w500,
                    color: selected ? Colors.white : C.slate600,
                  ),
                ),
                if (amount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    amount,
                    style: TS.mono(
                      size: 11,
                      color: selected ? Colors.white : C.slate400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        spacing: 8,
        children: [
          pill('全部分类'),
          for (final (name, amount) in cats)
            pill(name, amount: amount, category: name),
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
                  Text(
                    header,
                    style: TS.body(
                      size: 15,
                      weight: FontWeight.w600,
                      color: C.slate900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(dateLabel, style: TS.mono(size: 11, color: C.slate500)),
                ],
              ),
              Text(totalLabel, style: TS.mono(size: 12, color: C.slate500)),
            ],
          ),
        ),
        for (final tx in items) ...[const SizedBox(height: kCardGap), tx],
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
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 3)],
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
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(
                      size: 14,
                      weight: FontWeight.w500,
                      color: C.slate900,
                    ),
                  ),
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
                Text(
                  amount,
                  style: TS.headline(
                    size: 16,
                    weight: FontWeight.w600,
                    color: C.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TS.mono(
                    size: 10,
                    weight: FontWeight.w500,
                    color: noteColor,
                  ),
                ),
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
      child: Text(
        text,
        style: mono
            ? TS.mono(size: 10, color: fg)
            : TS.mono(size: 10, weight: FontWeight.w500, color: fg),
      ),
    );
  }
}
