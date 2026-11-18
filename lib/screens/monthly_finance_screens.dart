import 'package:material_ui/material_ui.dart';

import '../core/monthly_finance.dart';
import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

class MonthlyIncomeScreen extends StatelessWidget {
  const MonthlyIncomeScreen({super.key, this.month});
  final DateTime? month;

  @override
  Widget build(BuildContext context) {
    final period = month ?? DateTime.now();
    return _FinancePage(
      title: '本月收入明细',
      month: period,
      tag: '日常收入',
      children: [
        _SummaryCard(
          label: '本月总收入',
          amount: MonthlyFinance.money(MonthlyFinance.income),
          color: C.sky600,
          child: Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '入账笔数',
                  value: '${MonthlyFinance.incomes.length} 笔',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: '收入来源',
                  value: '${MonthlyFinance.incomes.length} 类',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('收入来源'),
        _FinanceCard(
          child: Column(
            children: [
              for (var i = 0; i < MonthlyFinance.incomes.length; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                _AmountRow(
                  label: MonthlyFinance.incomes[i].title,
                  amount: MonthlyFinance.money(
                    MonthlyFinance.incomes[i].amount,
                  ),
                  ratio:
                      MonthlyFinance.incomes[i].amount / MonthlyFinance.income,
                  color: _incomeColors[i],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('入账记录', trailing: '按时间倒序'),
        for (final item in MonthlyFinance.incomes.reversed) ...[
          _FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const _IconTile(MSym.arrow_downward, C.sky600),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TS.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: C.slate900,
                        ),
                      ),
                    ),
                    Text(
                      MonthlyFinance.money(item.amount, signed: true),
                      style: TS.headline(size: 17, color: C.sky600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.note, style: TS.body(size: 12, color: C.slate500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${period.month}月${item.day}日',
                        style: TS.body(size: 11, color: C.slate400),
                      ),
                    ),
                    Text('已入账', style: TS.body(size: 11, color: C.emerald600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: kCardGap),
        ],
        const SizedBox(height: 8),
        _PageButton(
          label: '记一笔收入',
          icon: MSym.add,
          color: C.sky600,
          onPressed: () => Navigator.of(context).pushNamed('/add-income'),
        ),
      ],
    );
  }
}

class MonthlyBalanceScreen extends StatelessWidget {
  const MonthlyBalanceScreen({super.key, this.month});
  final DateTime? month;

  @override
  Widget build(BuildContext context) {
    final period = month ?? DateTime.now();
    return _FinancePage(
      title: '财务净结余明细',
      month: period,
      tag: '日常收支',
      children: [
        _SummaryCard(
          label: '本月财务净结余',
          amount: MonthlyFinance.money(MonthlyFinance.balance, signed: true),
          color: C.emerald600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '结余率',
                      style: TS.body(size: 12, color: C.slate500),
                    ),
                  ),
                  Text(
                    '${(MonthlyFinance.savingsRate * 100).toStringAsFixed(1)}%',
                    style: TS.mono(
                      size: 14,
                      color: C.emerald700,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Progress(MonthlyFinance.savingsRate, C.emerald500),
            ],
          ),
        ),
        const SizedBox(height: kCardGap),
        _FinanceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '本月收支核算',
                style: TS.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: C.slate900,
                ),
              ),
              const SizedBox(height: 12),
              _BalanceLine(
                label: '本月总收入',
                amount: MonthlyFinance.money(MonthlyFinance.income),
                color: C.sky600,
                onTap: () =>
                    Navigator.of(context)
                        .pushNamed('/monthly-income', arguments: period),
              ),
              const SizedBox(height: 12),
              _BalanceLine(
                label: '日常总支出',
                amount: MonthlyFinance.money(-MonthlyFinance.expense),
                color: C.slate700,
              ),
              const Divider(height: 28, color: C.slate100),
              _BalanceLine(
                label: '财务净结余',
                amount: MonthlyFinance.money(
                  MonthlyFinance.balance,
                  signed: true,
                ),
                color: C.emerald600,
              ),
              const SizedBox(height: 12),
              Text(
                '净结余 = 本月总收入 − 日常总支出',
                style: TS.body(size: 11, color: C.slate400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('日常支出构成', trailing: '共 5 类'),
        _FinanceCard(
          child: Column(
            children: [
              for (var i = 0; i < MonthlyFinance.expenses.length; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                _AmountRow(
                  label: MonthlyFinance.expenses[i].title,
                  amount: MonthlyFinance.money(
                    MonthlyFinance.expenses[i].amount,
                  ),
                  ratio:
                      MonthlyFinance.expenses[i].amount /
                      MonthlyFinance.expense,
                  color: _expenseColors[i],
                ),
              ],
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
              const MIcon(MSym.info, size: 18, color: C.emerald600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '与记账首页口径一致，仅计算日常收支；AI 订阅与算力开支独立归档。净结余为所选月份的收支差额，不代表账户总资产。',
                  style: TS.body(size: 12, color: C.emerald700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _PageButton(
          label: '查看本月预算明细',
          icon: MSym.bar_chart,
          color: C.emerald600,
          onPressed: () =>
              Navigator.of(context)
                  .pushNamed('/monthly-budget', arguments: period),
        ),
      ],
    );
  }
}

const _incomeColors = [C.sky500, C.emerald500, C.violet500];
const _expenseColors = [
  C.blue500,
  C.orange500,
  C.emerald500,
  C.violet500,
  C.sky500,
];

class _FinancePage extends StatelessWidget {
  const _FinancePage({
    required this.title,
    required this.month,
    required this.tag,
    required this.children,
  });
  final String title;
  final DateTime month;
  final String tag;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kCanvas,
    body: Column(
      children: [
        GlassHeader.back(title: title),
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
                        '${month.year}年 ${month.month}月',
                        style: TS.body(
                          size: 15,
                          weight: FontWeight.w600,
                          color: C.slate900,
                        ),
                      ),
                    ),
                    Text(tag, style: TS.body(size: 12, color: C.slate500)),
                  ],
                ),
                const SizedBox(height: kCardGap),
                ...children,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.child,
  });
  final String label;
  final String amount;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => CardX(
    padding: const EdgeInsets.all(20),
    border: cardBorder(color: color.withValues(alpha: 0.12)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, color.withValues(alpha: 0.07)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: TS.body(size: 13, color: C.slate500)),
        const SizedBox(height: 10),
        FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(amount, style: TS.headline(size: 32, color: color)),
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

class _FinanceCard extends StatelessWidget {
  const _FinanceCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => CardX(
    border: cardBorder(color: C.slate100),
    child: child,
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TS.body(size: 12, color: C.slate500)),
      const SizedBox(height: 6),
      Text(value, style: TS.headline(size: 20, color: C.slate900)),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.trailing});
  final String title;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: kCardGap),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TS.body(
              size: 16,
              weight: FontWeight.w600,
              color: C.slate900,
            ),
          ),
        ),
        if (trailing != null)
          Text(trailing!, style: TS.body(size: 12, color: C.slate500)),
      ],
    ),
  );
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.color,
  });
  final String label;
  final String amount;
  final double ratio;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(label, style: TS.body(size: 13, color: C.slate700)),
          ),
          Text(amount, style: TS.headline(size: 15, color: C.slate900)),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              '${(ratio * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.end,
              style: TS.mono(size: 11, color: C.slate500),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _Progress(ratio, color),
    ],
  );
}

class _Progress extends StatelessWidget {
  const _Progress(this.ratio, this.color);
  final double ratio;
  final Color color;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(
      value: ratio.clamp(0.0, 1.0),
      minHeight: 6,
      color: color,
      backgroundColor: C.slate100,
    ),
  );
}

class _IconTile extends StatelessWidget {
  const _IconTile(this.icon, this.color);
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(child: MIcon(icon, size: 18, color: color)),
  );
}

class _BalanceLine extends StatelessWidget {
  const _BalanceLine({
    required this.label,
    required this.amount,
    required this.color,
    this.onTap,
  });
  final String label;
  final String amount;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TS.body(size: 13, color: C.slate500)),
          ),
          Text(amount, style: TS.headline(size: 17, color: color)),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const MIcon(MSym.chevron_right, size: 16, color: C.slate400),
          ],
        ],
      ),
    );
    return onTap == null
        ? content
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: content,
          );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: MIcon(icon, size: 18, color: Colors.white),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
