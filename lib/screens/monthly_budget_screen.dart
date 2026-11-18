import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 日常记账预算分析。沿用首页与预算控制中心的演示预算。
class MonthlyBudgetScreen extends StatelessWidget {
  const MonthlyBudgetScreen({super.key, this.month});

  final DateTime? month;

  static const _budget = 12000.0;
  static const _categories = [
    (
      name: '餐饮美食',
      detail: '三餐、生鲜与咖啡',
      icon: MSym.restaurant,
      spent: 3240.0,
      budget: 4500.0,
      color: C.orange500,
    ),
    (
      name: '居住房租',
      detail: '固定房租与物业开支',
      icon: MSym.home,
      spent: 3500.0,
      budget: 3500.0,
      color: C.blue500,
    ),
    (
      name: '日用通勤',
      detail: '交通 ¥680 · 娱乐 ¥580 · 数码 ¥450',
      icon: MSym.directions_subway,
      spent: 1710.0,
      budget: 2500.0,
      color: C.emerald500,
    ),
  ];

  double get _spent => _categories.fold(0.0, (sum, item) => sum + item.spent);
  double get _allocated =>
      _categories.fold(0.0, (sum, item) => sum + item.budget);

  String _money(double value) =>
      '¥${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (match) => '${match[1]},')}';

  @override
  Widget build(BuildContext context) {
    final period = month ?? DateTime.now();
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          GlassHeader.back(title: '本月预算明细'),
          Expanded(
            child: SingleChildScrollView(
              padding: PageContentInsets(
                bottom: MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const MIcon(
                        MSym.calendar_month,
                        size: 18,
                        color: C.slate500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${period.year}年 ${period.month}月',
                          style: TS.body(
                            size: 15,
                            weight: FontWeight.w600,
                            color: C.slate900,
                          ),
                        ),
                      ),
                      _badge('日常消费', C.emerald600),
                    ],
                  ),
                  const SizedBox(height: kCardGap),
                  _overview(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '分类预算明细',
                          style: TS.body(
                            size: 16,
                            weight: FontWeight.w600,
                            color: C.slate900,
                          ),
                        ),
                      ),
                      Text(
                        '共 ${_categories.length} 项',
                        style: TS.body(size: 12, color: C.slate500),
                      ),
                    ],
                  ),
                  const SizedBox(height: kCardGap),
                  for (final category in _categories) ...[
                    _categoryCard(category),
                    const SizedBox(height: kCardGap),
                  ],
                  CardX(
                    border: cardBorder(color: C.slate100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '预算分配',
                          style: TS.body(
                            size: 14,
                            weight: FontWeight.w600,
                            color: C.slate900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _line('已分配至分类', _money(_allocated)),
                        const SizedBox(height: 10),
                        _line('未分配预算', _money(_budget - _allocated)),
                        const SizedBox(height: 12),
                        Text(
                          '未分配预算保留在月度总额度中，可在预算控制中心调整分类分配。',
                          style: TS.body(size: 12, color: C.slate500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kCardGap),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.emerald50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MIcon(
                          MSym.call_split,
                          size: 18,
                          color: C.emerald600,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '此处仅统计日常消费，AI 订阅与算力开支计入独立预算。',
                            style: TS.body(size: 12, color: C.emerald700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/budget'),
                    icon: const MIcon(MSym.tune, size: 18, color: Colors.white),
                    label: const Text('前往预算控制中心'),
                    style: FilledButton.styleFrom(
                      backgroundColor: C.emerald600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overview() => CardX(
    border: cardBorder(color: C.emerald100),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, C.emerald50],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('月度总预算', style: TS.body(size: 13, color: C.slate500)),
            ),
            _badge('预算内', C.emerald600),
          ],
        ),
        const SizedBox(height: 8),
        Text(_money(_budget), style: TS.headline(size: 32, color: C.slate900)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _stat('已支出', _money(_spent), C.slate900)),
            const SizedBox(width: 12),
            Expanded(
              child: _stat('剩余额度', _money(_budget - _spent), C.emerald700),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _progress(_spent / _budget, C.emerald500),
        const SizedBox(height: 10),
        _line('预算使用率', '${(_spent / _budget * 100).toStringAsFixed(1)}%'),
      ],
    ),
  );

  Widget _categoryCard(
    ({
      String name,
      String detail,
      IconData icon,
      double spent,
      double budget,
      Color color,
    })
    item,
  ) {
    final ratio = item.spent / item.budget;
    final atLimit = ratio >= 1;
    final statusColor = atLimit ? C.amber600 : item.color;
    return CardX(
      border: cardBorder(color: C.slate100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: MIcon(item.icon, size: 20, color: item.color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: TS.body(
                    size: 14,
                    weight: FontWeight.w600,
                    color: C.slate900,
                  ),
                ),
              ),
              _badge(
                atLimit ? '额度已用满' : '预算内',
                atLimit ? C.amber600 : C.emerald600,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _money(item.spent),
                style: TS.headline(size: 20, color: C.slate900),
              ),
              Text(
                '/ ${_money(item.budget)}',
                style: TS.body(size: 12, color: C.slate500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _progress(ratio, statusColor),
          const SizedBox(height: 10),
          _line(
            '已用 ${(ratio * 100).toStringAsFixed(1)}%',
            '剩余 ${_money(item.budget - item.spent)}',
          ),
          const SizedBox(height: 10),
          Text(item.detail, style: TS.body(size: 11, color: C.slate400)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TS.body(size: 12, color: C.slate500)),
      const SizedBox(height: 6),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(value, style: TS.headline(size: 22, color: color)),
      ),
    ],
  );

  Widget _line(String label, String value) => Row(
    children: [
      Expanded(
        child: Text(label, style: TS.body(size: 12, color: C.slate500)),
      ),
      Text(
        value,
        style: TS.body(size: 12, weight: FontWeight.w600, color: C.slate700),
      ),
    ],
  );

  Widget _progress(double ratio, Color color) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(
      value: ratio.clamp(0.0, 1.0),
      minHeight: 7,
      color: color,
      backgroundColor: C.slate100,
    ),
  );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TS.body(size: 11, weight: FontWeight.w500, color: color),
    ),
  );
}
