import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 新增记账（设计稿 _6）— 支出/收入/AI算力 三态切换、金额与币种、
/// 备注语音录入、消费类目九宫格、扣款账户横滑与底部固定入账操作条。
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  int _type = 0; // 0=日常支出 1=日常收入 2=AI算力充值
  int _currency = 0; // 0=人民币 ¥ 1=美元 $
  int _category = 0;
  int _account = 0;
  bool _excludeBudget = false; // 不计入总预算统计
  bool _reimbursable = false; // 标记为待报销款项
  bool _continueNext = true; // 保存后继续记下一笔
  final _noteCtrl = TextEditingController(text: '瑞幸生椰拿铁 + 办公提神');

  static const _typeIcons = [MSym.trending_down, MSym.trending_up, MSym.neurology];
  static const _typeLabels = ['日常支出', '日常收入', 'AI算力充值'];
  static const _categories = <(IconData, String)>[
    (MSym.restaurant, '餐饮美食'),
    (MSym.directions_subway, '交通出行'),
    (MSym.shopping_bag, '日用购物'),
    (MSym.home, '居住房租'),
    (MSym.sports_esports, '数码娱乐'),
    (MSym.memory, '算力Token'),
    (MSym.medical_services, '医疗健康'),
    (MSym.more_horiz, '更多分类'),
  ];
  static const _accounts = <(IconData, Color, String, String)>[
    (MSym.account_balance, C.emerald600, '招商银行储蓄卡', '尾号 4288 · ¥28,450.00'),
    (MSym.chat, C.emerald600, '微信支付', '零钱通可用'),
    (MSym.account_balance_wallet, C.sky600, '支付宝', '余额宝'),
    (MSym.credit_card, C.violet600, 'Depay 虚拟卡', 'VISA 美元卡'),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ---- 重置为初始状态 ----
  void _reset() {
    setState(() {
      _type = 0;
      _currency = 0;
      _category = 0;
      _account = 0;
      _excludeBudget = false;
      _reimbursable = false;
      _continueNext = true;
      _noteCtrl.text = '瑞幸生椰拿铁 + 办公提神';
    });
  }

  void _save() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（返回 + 标题 + 票据识别/重置）----
          GlassHeader.back(
            title: '新增记账',
            actions: [
              // 智能票据识别入口
              HeaderIconButton(
                icon: MSym.image,
                onTap: () => Navigator.of(context).pushNamed('/ai-scan'),
              ),
              const SizedBox(width: 8),
              // 重置
              HeaderIconButton(icon: MSym.restart_alt, onTap: _reset),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.fromLTRB(16, 16, 16, 132 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _segmentedControl(),
                        const SizedBox(height: 16),
                        _amountCard(),
                        const SizedBox(height: 16),
                        _categoryCard(),
                        const SizedBox(height: 16),
                        _accountCard(),
                        const SizedBox(height: 16),
                        _advancedCard(),
                      ],
                    ),
                  ),
                ),
                // ---- 底部固定操作条 ----
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _footer(bottomInset),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- 底部固定操作条 ----
  Widget _footer(double bottomInset) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: C.slate100)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F0F172A), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 8 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _continueNext = !_continueNext),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    _CheckSquare(checked: _continueNext, size: 16),
                    const SizedBox(width: 6),
                    Text('保存后继续记下一笔',
                        style: TS.body(
                            size: 12,
                            weight: FontWeight.w500,
                            color: C.slate600)),
                  ],
                ),
              ),
              const Spacer(),
              Text('自动同步云端',
                  style: TS.mono(size: 11, weight: FontWeight.w400, color: C.slate400)),
            ],
          ),
          const SizedBox(height: 8),
          // 保存并入账
          GestureDetector(
            onTap: _save,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: C.emerald500,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: C.emerald500.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MIcon(MSym.check_circle, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('保存并入账',
                      style: TS.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 三态分段切换 ----
  Widget _segmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: C.slate200.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _segment(i)),
          ],
        ],
      ),
    );
  }

  Widget _segment(int i) {
    final active = _type == i;
    final Color iconColor;
    final Color textColor;
    if (active) {
      iconColor = i == 2 ? C.violet500 : C.emerald600;
      textColor = i == 2 ? C.violet700 : C.emerald800;
    } else {
      iconColor = i == 2 ? C.violet500 : C.slate400;
      textColor = C.slate600;
    }
    return GestureDetector(
      onTap: () => setState(() => _type = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MIcon(_typeIcons[i], size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(_typeLabels[i],
                maxLines: 1,
                style: TS.body(
                    size: 12,
                    weight: active ? FontWeight.w600 : FontWeight.w500,
                    color: textColor)),
          ],
        ),
      ),
    );
  }

  // ---- 金额与币种卡片 ----
  Widget _amountCard() {
    final symbol = _currency == 0 ? '¥' : r'$';
    final estimate = _currency == 0 ? '≈ \$17.82' : '≈ ¥925.20';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 头部：记账金额 + 币种切换
          Row(
            children: [
              const MIcon(MSym.payments, size: 16, color: C.emerald600),
              const SizedBox(width: 6),
              Text('记账金额',
                  style: TS.body(
                      size: 12, weight: FontWeight.w600, color: C.slate500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: C.slate100,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: C.slate200.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    _currencyBtn(0, '人民币 ¥'),
                    _currencyBtn(1, r'美元 $'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: C.slate100),
          const SizedBox(height: 8),
          // 大金额展示
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(symbol,
                  style: const TextStyle(
                      fontFamily: F.mono,
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: C.emerald600)),
              const SizedBox(width: 4),
              Expanded(
                child: Text('128.50',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(
                        size: 36,
                        weight: FontWeight.w700,
                        color: C.slate900,
                        height: 40 / 36)),
              ),
              const SizedBox(width: 4),
              _Pulse(
                child: Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    color: C.emerald500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: C.slate50,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: C.slate200.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MIcon(MSym.currency_exchange,
                        size: 14, color: C.emerald600),
                    const SizedBox(width: 4),
                    Text(estimate,
                        style: TS.mono(
                            size: 11, weight: FontWeight.w400, color: C.slate400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 备注与语音输入
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.slate200.withValues(alpha: 0.7)),
            ),
            child: Row(
              children: [
                const MIcon(MSym.edit_note, size: 18, color: C.slate400),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _noteCtrl,
                    cursorColor: C.emerald500,
                    maxLines: 1,
                    style: TS.body(size: 14, color: C.slate800),
                    decoration: InputDecoration.collapsed(
                      hintText: '添加备注，如：瑞幸生椰拿铁、服务器续费...',
                      hintStyle: TS.body(size: 14, color: C.slate400),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 语音记账
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: C.emerald100.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: MIcon(MSym.mic, size: 16, color: C.emerald700)),
                ),
                const SizedBox(width: 6),
                // 附加收据凭证
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: C.slate200.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child:
                          MIcon(MSym.attach_file, size: 16, color: C.slate600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyBtn(int i, String label) {
    final active = _currency == i;
    return GestureDetector(
      onTap: () => setState(() => _currency = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)]
              : null,
        ),
        child: Text(label,
            style: TS.body(
                size: 12,
                weight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? C.emerald700 : C.slate500)),
      ),
    );
  }

  // ---- 消费类目九宫格 ----
  Widget _categoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('选择消费类目',
                  style: TS.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: C.slate700,
                      height: 1.0)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.emerald50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: C.emerald400.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulsingDot(color: C.emerald500, size: 6),
                    const SizedBox(width: 4),
                    Text('AI建议：餐饮美食',
                        style: TS.body(
                            size: 11,
                            weight: FontWeight.w500,
                            color: C.emerald700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.15,
            children: [
              for (var i = 0; i < _categories.length; i++) _catTile(i),
            ],
          ),
        ],
      ),
    );
  }

  Color _catIconColor(int i) =>
      i == 5 ? C.violet600 : (i == 7 ? C.slate500 : C.slate600);

  Widget _catTile(int i) {
    final active = _category == i;
    final (icon, label) = _categories[i];
    return GestureDetector(
      onTap: () => setState(() => _category = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? C.emerald50 : C.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? C.emerald400 : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: active ? C.emerald500 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: active
                    ? null
                    : Border.all(color: C.slate200.withValues(alpha: 0.6)),
                boxShadow: active
                    ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)]
                    : null,
              ),
              child: Center(
                child: MIcon(icon,
                    size: 20,
                    color: active ? Colors.white : _catIconColor(i)),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TS.body(
                    size: 12,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? C.emerald700 : C.slate700)),
          ],
        ),
      ),
    );
  }

  // ---- 扣款账户 / 渠道 ----
  Widget _accountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('扣款账户 / 渠道',
                  style: TS.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: C.slate700,
                      height: 1.0)),
              const Spacer(),
              Text('默认支付账户', style: TS.body(size: 11, color: C.slate400)),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (var i = 0; i < _accounts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _accountChip(i),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountChip(int i) {
    final active = _account == i;
    final (icon, tint, name, sub) = _accounts[i];
    final isBank = i == 0;
    return GestureDetector(
      onTap: () => setState(() => _account = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? C.emerald50 : C.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? C.emerald400 : C.slate200.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBank && active)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: C.emerald500,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: MIcon(MSym.check, size: 14, color: Colors.white)),
              )
            else
              MIcon(icon, size: 20, color: tint),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TS.body(
                        size: 12,
                        weight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active ? C.slate900 : C.slate800)),
                const SizedBox(height: 1),
                Text(sub,
                    style: isBank
                        ? TS.mono(
                            size: 10,
                            weight: FontWeight.w400,
                            color: active ? C.emerald700 : C.slate400)
                        : TS.body(size: 10, color: C.slate400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- 日期与高级选项 ----
  Widget _advancedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: C.emerald50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                    child: MIcon(MSym.calendar_month,
                        size: 18, color: C.emerald600)),
              ),
              const SizedBox(width: 8),
              Text('记账日期',
                  style: TS.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: C.slate700,
                      height: 1.0)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: C.emerald50.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: C.emerald400.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('2025年5月18日 · 今天',
                        style: TS.body(
                            size: 12,
                            weight: FontWeight.w500,
                            color: C.emerald700)),
                    const SizedBox(width: 4),
                    const MIcon(MSym.expand_more,
                        size: 15, color: C.emerald700),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: C.slate100),
          const SizedBox(height: 12),
          _toggleRow(
            title: '不计入总预算统计',
            subtitle: '该笔账单仅作记录，不占用本月消费配额',
            value: _excludeBudget,
            onChanged: (v) => setState(() => _excludeBudget = v),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: C.slate50),
          const SizedBox(height: 12),
          _toggleRow(
            title: '标记为待报销款项',
            subtitle: '报销后可一键核销冲账',
            value: _reimbursable,
            onChanged: (v) => setState(() => _reimbursable = v),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TS.body(
                      size: 12, weight: FontWeight.w500, color: C.slate700)),
              const SizedBox(height: 2),
              Text(subtitle, style: TS.body(size: 10, color: C.slate400)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onChanged(!value),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: _CheckSquare(checked: value, size: 16),
          ),
        ),
      ],
    );
  }
}

/// 勾选方块（w-4 h-4 rounded，参考 login_screen 的 _CheckSquare 样式）。
class _CheckSquare extends StatelessWidget {
  const _CheckSquare({required this.checked, this.size = 16});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? C.emerald500 : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: checked ? C.emerald500 : C.slate300,
          width: 1,
        ),
      ),
      child: checked
          ? Center(
              child: MIcon(MSym.check,
                  size: size - 6, color: Colors.white, fill: true))
          : null,
    );
  }
}

/// 呼吸光标条（amount-display 后的 animate-pulse 竖条）。
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.35).animate(_c),
      child: widget.child,
    );
  }
}
