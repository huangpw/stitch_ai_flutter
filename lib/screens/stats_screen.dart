import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../services/stats_report.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 账单统计：按提供的 analytics-reports HTML 还原，数据为现有设计稿样例。
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const _periods = ['日', '周', '月', '季', '年'];
  int _period = 2;
  DateTime _date = DateTime(2025, 5, 18);
  bool _exporting = false;

  // 现有应用仅有 2025 年 5 月的月度统计样例；其他区间明确显示空状态。
  bool get _hasData => switch (_period) {
    2 => _date.year == 2025 && _date.month == 5,
    3 => _date.year == 2025 && (_date.month - 1) ~/ 3 == 1,
    4 => _date.year == 2025,
    _ => false,
  };

  String get _dateLabel => switch (_period) {
    0 => '${_date.year}年 ${_date.month}月${_date.day}日',
    1 =>
      '${_date.month}月${_weekStart.day}日 — ${_weekEnd.month}月${_weekEnd.day}日',
    2 => '${_date.year}年 ${_date.month}月',
    3 => '${_date.year}年 第${(_date.month - 1) ~/ 3 + 1}季度',
    _ => '${_date.year}年',
  };

  DateTime get _weekStart => _date.subtract(Duration(days: _date.weekday - 1));
  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  void _movePeriod(int direction) {
    setState(() {
      _date = switch (_period) {
        0 => _date.add(Duration(days: direction)),
        1 => _date.add(Duration(days: direction * 7)),
        2 => DateTime(_date.year, _date.month + direction, 1),
        3 => DateTime(_date.year, _date.month + direction * 3, 1),
        _ => DateTime(_date.year + direction, _date.month, 1),
      };
    });
  }

  Future<void> _pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      helpText: '选择统计日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (chosen != null) setState(() => _date = chosen);
  }

  Future<void> _export(StatsReportFormat format) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final box = context.findRenderObject() as RenderBox?;
      await StatsReport.share(
        format: format,
        period: _dateLabel,
        hasData: _hasData,
        shareOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('导出失败，请重试')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showExportOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('导出账单统计', style: _text(17, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(_dateLabel, style: _text(12, color: C.slate500)),
              const SizedBox(height: 16),
              for (final format in StatsReportFormat.values)
                ListTile(
                  leading: MIcon(
                    format == StatsReportFormat.excel
                        ? MSym.table_view
                        : Icons.picture_as_pdf_outlined,
                    color: format == StatsReportFormat.excel
                        ? C.emerald600
                        : C.indigo600,
                  ),
                  title: Text(
                    format == StatsReportFormat.excel
                        ? '导出 Excel 报表'
                        : '导出 PDF 账单',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _export(format);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.iceCanvas,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey('bill-statistics'),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                math.max(112, MediaQuery.paddingOf(context).bottom + 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  _periodControls(),
                  if (_hasData) ...[
                    _overview(),
                    _spendingStructure(),
                    _budgetTrend(),
                  ] else
                    _emptyState(),
                  _exportActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return GlassHeader.tab(
      title: '账单统计',
      actions: [
        Tooltip(
          message: '分享导出',
          child: HeaderIconButton(
            icon: MSym.ios_share,
            onTap: _exporting ? null : _showExportOptions,
          ),
        ),
      ],
    );
  }

  Widget _periodControls() {
    return Column(
      spacing: 10,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: C.slate200.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: C.slate200.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: List.generate(5, (i) {
              final selected = i == _period;
              return Expanded(
                child: Semantics(
                  selected: selected,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _period = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _periods[i],
                        style: _text(
                          12,
                          color: selected ? C.emerald600 : C.slate500,
                          weight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _dateLabel,
                          style: TS.headline(size: 18, color: C.slate900),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const MIcon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: C.slate400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _circleButton(MSym.chevron_left, '上个统计周期', () => _movePeriod(-1)),
              const SizedBox(width: 6),
              _circleButton(MSym.chevron_right, '下个统计周期', () => _movePeriod(1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overview() {
    return _card(
      gradient: const RadialGradient(
        center: Alignment(0.95, -0.9),
        radius: 1.1,
        colors: [Color(0xC8ECFDF5), Colors.white],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              _dot(C.emerald500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '月度总支出 MONTHLY OUTLAY',
                  style: TS
                      .mono(size: 11, color: C.slate500)
                      .copyWith(letterSpacing: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.emerald50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: C.emerald100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MIcon(
                      MSym.trending_down,
                      size: 14,
                      color: C.emerald700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '-3.2% 环比',
                      style: TS.mono(
                        size: 12,
                        weight: FontWeight.w700,
                        color: C.emerald700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('¥', style: TS.headline(size: 20, color: C.emerald600)),
              const SizedBox(width: 4),
              Text(
                '9,698.50',
                style: TS.headline(
                  size: 30,
                  color: C.slate900,
                  letterSpacing: -0.75,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '较上月省 ¥321.50',
                  style: _text(12, color: C.slate400),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              spacing: 6,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 871,
                        child: ColoredBox(
                          color: C.emerald500,
                          child: SizedBox(height: 10),
                        ),
                      ),
                      Expanded(
                        flex: 129,
                        child: ColoredBox(
                          color: C.indigo500,
                          child: SizedBox(height: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('日常支出 87.1%', style: _text(11, color: C.slate400)),
                    Text('AI算力订阅 12.9%', style: _text(11, color: C.slate400)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _summaryTile(false)),
                const SizedBox(width: 10),
                Expanded(child: _summaryTile(true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(bool ai) {
    return _tile(
      ai: ai,
      padding: 12,
      minHeight: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Row(
            children: [
              _dot(ai ? C.indigo500 : C.emerald500),
              const SizedBox(width: 6),
              Text(
                ai ? 'AI 算力订阅' : '日常消费',
                style: _text(
                  12,
                  color: ai ? C.indigo900 : C.slate500,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            ai ? '¥1,248.50' : '¥8,450.00',
            style: TS.mono(
              size: 15,
              weight: FontWeight.w700,
              color: ai ? C.indigo700 : C.slate800,
            ),
          ),
          Text(
            ai ? '6 项模型及服务' : '共 42 笔常规支出',
            style: _text(11, color: ai ? C.indigo400 : C.slate400),
          ),
        ],
      ),
    );
  }

  Widget _spendingStructure() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _sectionTitle(
            '多维支出结构',
            '分类占比与核心模型排行',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: C.slate100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('总计 7 类', style: _text(11, color: C.slate600)),
            ),
          ),
          SizedBox(
            height: 184,
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: _SpendingRingPainter()),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '支出重心',
                          style: TS
                              .mono(size: 10, color: C.slate400)
                              .copyWith(letterSpacing: 1),
                        ),
                        Text(
                          '居住+餐饮',
                          style: TS.headline(size: 24, color: C.slate800),
                        ),
                        Text(
                          '合计 69.5%',
                          style: _text(
                            12,
                            color: C.emerald600,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              spacing: 8,
              children: [
                _rankRow(
                  ai: true,
                  icon: MSym.neurology,
                  title: 'AI 算力与订阅',
                  subtitle: 'OpenAI API、Claude Pro、Cursor',
                  amount: '¥1,248.50',
                  percent: '12.9%',
                  tint: C.indigo100,
                  ink: C.indigo600,
                ),
                _rankRow(
                  icon: Icons.apartment_outlined,
                  title: '居住房租',
                  subtitle: '固定房租与物业暖气',
                  amount: '¥3,500.00',
                  percent: '36.1%',
                  tint: C.sky100,
                  ink: C.sky600,
                ),
                _rankRow(
                  icon: MSym.restaurant,
                  title: '餐饮美食',
                  subtitle: '日常三餐、生鲜采购与咖啡',
                  amount: '¥3,240.00',
                  percent: '33.4%',
                  tint: C.emerald100,
                  ink: C.emerald600,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: _smallMetric('交通出行', '¥680.00', '7.0%', false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _smallMetric(
                          'Claude Pro',
                          '¥145.00',
                          '1.5%',
                          true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _smallMetric(
                          'OpenAI API',
                          '¥360.00',
                          '3.7%',
                          true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankRow({
    bool ai = false,
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String percent,
    required Color tint,
    required Color ink,
  }) {
    return _tile(
      ai: ai,
      minHeight: 60,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: MIcon(icon, size: 18, color: ink)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _text(
                          14,
                          weight: ai ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (ai) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: C.indigo100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '高价值',
                          style: _text(
                            10,
                            color: C.indigo700,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _text(12, color: ai ? C.slate500 : C.slate400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TS.mono(
                  size: 14,
                  color: ai ? C.indigo700 : C.slate800,
                  weight: FontWeight.w600,
                ),
              ),
              Text(percent, style: _text(11, color: C.slate400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallMetric(String title, String amount, String percentage, bool ai) {
    return _tile(
      minHeight: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _text(11, color: C.slate500)),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TS.mono(
              size: 12,
              color: ai ? C.indigo600 : C.slate800,
              weight: FontWeight.w600,
            ),
          ),
          Text(percentage, style: _text(10, color: C.slate400)),
        ],
      ),
    );
  }

  Widget _budgetTrend() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 15,
        children: [
          _sectionTitle(
            '收支趋势与预算达成',
            '30天支出动态与预算控制',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(C.emerald500),
                const SizedBox(width: 6),
                Text(
                  '正常控制中',
                  style: _text(
                    12,
                    color: C.emerald600,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _budgetTile(false)),
              const SizedBox(width: 10),
              Expanded(child: _budgetTile(true)),
            ],
          ),
          _tile(
            padding: 12,
            color: C.slate50.withValues(alpha: 0.8),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _legend('常规日均波动', C.emerald500),
                    _legend('AI 充值波峰', C.indigo500),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  height: 136,
                  width: double.infinity,
                  child: CustomPaint(painter: _SpendingTrendPainter()),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 4,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _chartDate('5/01'),
                        ),
                      ),
                      Expanded(
                        flex: 14,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _chartDate('5/09 (Token充值)', ai: true),
                        ),
                      ),
                      Expanded(
                        flex: 12,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _chartDate('5/16 (Pro续费)', ai: true),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _chartDate('5/24'),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: _chartDate('5/31'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetTile(bool ai) {
    return _tile(
      padding: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  ai ? 'AI 专属预算 ¥1,500' : '月预算 ¥12,000',
                  style: _text(12, color: C.slate500),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ai ? '83.2%' : '80.8%',
                style: _text(
                  12,
                  color: ai ? C.indigo700 : C.slate800,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ai ? 0.832 : 0.808,
              minHeight: 6,
              color: ai ? C.indigo500 : C.emerald500,
              backgroundColor: C.slate200,
            ),
          ),
          Text(
            ai ? '剩余额度 ¥251.50' : '结余可支配 ¥2,301.50',
            style: _text(
              11,
              color: ai ? C.indigo600 : C.emerald600,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportActions() {
    return Row(
      children: [
        Expanded(child: _exportButton(StatsReportFormat.excel)),
        const SizedBox(width: 10),
        Expanded(child: _exportButton(StatsReportFormat.pdf)),
      ],
    );
  }

  Widget _exportButton(StatsReportFormat format) {
    final excel = format == StatsReportFormat.excel;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.slate200.withValues(alpha: 0.9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: _exporting ? null : () => _export(format),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MIcon(
              excel ? MSym.table_view : Icons.picture_as_pdf_outlined,
              size: 18,
              color: excel ? C.emerald600 : C.indigo600,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                excel ? '导出 Excel 报表' : '导出 PDF 账单',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(12, weight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => _card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          const MIcon(MSym.bar_chart, size: 40, color: C.slate300),
          const SizedBox(height: 12),
          Text('本周期暂无账单', style: _text(16, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('切换统计周期，查看已有账单分析', style: _text(12, color: C.slate400)),
        ],
      ),
    ),
  );

  Widget _circleButton(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool filled = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: filled ? C.slate100 : Colors.white,
          shape: CircleBorder(
            side: filled
                ? BorderSide.none
                : BorderSide(color: C.slate200.withValues(alpha: 0.8)),
          ),
          elevation: filled ? 0 : 1,
          shadowColor: const Color(0x14000000),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: MIcon(icon, size: filled ? 18 : 17, color: C.slate600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle, {
    required Widget trailing,
  }) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _text(15, weight: FontWeight.w700)),
            Text(subtitle, style: _text(12, color: C.slate400)),
          ],
        ),
      ),
      const SizedBox(width: 8),
      trailing,
    ],
  );

  Widget _legend(String title, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      const SizedBox(width: 6),
      Text(title, style: _text(11, color: C.slate500)),
    ],
  );

  Widget _chartDate(String title, {bool ai = false}) => Text(
    title,
    style: TS.mono(
      size: 10,
      color: ai ? C.indigo600 : C.slate400,
      weight: ai ? FontWeight.w500 : FontWeight.w400,
    ),
  );

  Widget _dot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _card({required Widget child, Gradient? gradient}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: child,
  );

  Widget _tile({
    required Widget child,
    bool ai = false,
    double padding = 10,
    double? minHeight,
    Color? color,
  }) => Container(
    constraints: minHeight == null
        ? null
        : BoxConstraints(minHeight: minHeight),
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color ?? (ai ? C.indigo50.withValues(alpha: 0.5) : C.slate50),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: ai ? C.indigo100.withValues(alpha: 0.7) : C.slate100,
      ),
    ),
    child: child,
  );
}

TextStyle _text(
  double size, {
  Color color = C.slate900,
  FontWeight weight = FontWeight.w400,
}) => TS.px('$size', color: color, weight: weight);

/// 与参考 SVG 使用同一半径、线宽、起始角和分类比例。
class _SpendingRingPainter extends CustomPainter {
  const _SpendingRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: 38 * scale,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11 * scale;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = C.slate100);
    const segments = [
      (0.361, C.sky400),
      (0.334, C.emerald500),
      (0.129, C.indigo500),
      (0.070, C.amber500),
      (0.060, C.pink500),
      (0.046, C.slate400),
    ];
    var start = -math.pi / 2;
    for (var i = 0; i < segments.length; i++) {
      final (fraction, color) = segments[i];
      paint
        ..color = color
        ..strokeWidth = (i == 2 ? 13 : 11) * scale;
      canvas.drawArc(rect, start, fraction * math.pi * 2, false, paint);
      start += fraction * math.pi * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _SpendingRingPainter oldDelegate) => false;
}

/// 逐点还原参考 SVG 的二次贝塞尔曲线与两次 AI 充值尖峰。
class _SpendingTrendPainter extends CustomPainter {
  const _SpendingTrendPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 300, size.height / 110);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = C.slate200;
    for (final y in [25.0, 65.0]) {
      for (var x = 0.0; x < 300; x += 6) {
        canvas.drawLine(Offset(x, y), Offset(x + 3, y), line);
      }
    }
    canvas.drawLine(
      const Offset(0, 100),
      const Offset(300, 100),
      line..color = C.slate300,
    );
    final routine = Path()
      ..moveTo(0, 85)
      ..quadraticBezierTo(40, 78, 75, 82)
      ..quadraticBezierTo(110, 86, 150, 75)
      ..quadraticBezierTo(190, 64, 225, 80)
      ..quadraticBezierTo(260, 96, 300, 70);
    final ai = Path()
      ..moveTo(0, 100)
      ..lineTo(70, 100)
      ..lineTo(85, 25)
      ..lineTo(100, 100)
      ..lineTo(140, 100)
      ..lineTo(155, 18)
      ..lineTo(170, 100)
      ..lineTo(300, 100);
    for (final (path, color, alpha) in [
      (routine, C.emerald500, 0.2),
      (ai, C.indigo500, 0.25),
    ]) {
      final area = Path.from(path)
        ..lineTo(300, 100)
        ..lineTo(0, 100)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(const Rect.fromLTWH(0, 18, 300, 82)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    for (final point in [const Offset(85, 25), const Offset(155, 18)]) {
      canvas.drawCircle(point, 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 2.5, Paint()..color = C.indigo500);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpendingTrendPainter oldDelegate) => false;
}
