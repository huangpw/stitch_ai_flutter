/// 与日常记账首页一致的演示数据，收入和结余明细共用同一份金额。
class MonthlyFinance {
  MonthlyFinance._();

  static const incomes = [
    (title: '工资薪酬', note: '月度工资 · 招商银行工资卡', day: 8, amount: 22000),
    (title: '兼职收入', note: '项目咨询 · 支付宝', day: 15, amount: 2000),
    (title: '理财收益', note: '收益入账 · 招商银行储蓄卡', day: 18, amount: 500),
  ];

  static const expenses = [
    (title: '居住房租', amount: 3500),
    (title: '餐饮美食', amount: 3240),
    (title: '交通出行', amount: 680),
    (title: '休闲娱乐', amount: 580),
    (title: '数码生活', amount: 450),
  ];

  static int get income => incomes.fold(0, (sum, item) => sum + item.amount);
  static int get expense => expenses.fold(0, (sum, item) => sum + item.amount);
  static int get balance => income - expense;
  static double get savingsRate => income == 0 ? 0 : balance / income;

  static String money(num value, {bool signed = false}) {
    final digits = value
        .abs()
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+\.)'),
          (match) => '${match[1]},',
        );
    final sign = value < 0 ? '-' : (signed && value > 0 ? '+' : '');
    return '$sign¥$digits';
  }
}
