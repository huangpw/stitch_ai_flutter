import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 新增日常收入（设计稿 _11）— 顶部三轨切换、入账金额卡片（币种切换 +
/// 汇率折算）、收入来源类目九宫格、入账账户单选、日期与高级开关、
/// 底部固定「确认入账」操作条。
class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  bool _usd = false; // 币种切换：¥ CNY / $ USD
  bool _excludeFromStats = false; // 不计入月度常规收入统计
  bool _proxyPayment = false; // 标记为代收款项 / 待转交款
  bool _continueNext = false; // 保存后继续记下一笔
  int _category = 0; // 选中的收入来源类目
  int _account = 0; // 选中的入账账户
  bool _saving = false;
  final TextEditingController _noteCtrl = TextEditingController(
    text: '2025年5月份项目绩效与基本月薪',
  );

  static const _categories = <(IconData, String)>[
    (MSym.payments, '工资薪酬'),
    (MSym.trending_up, '理财投资'),
    (MSym.laptop_mac, '兼职副业'),
    (MSym.workspace_premium, '奖金补贴'),
    (MSym.featured_seasonal_and_gifts, '红包礼金'),
    (MSym.recycling, '二手闲置'),
    (MSym.receipt_long, '报销入账'),
    (MSym.more_horiz, '其他收入'),
  ];

  static const _accounts = <(IconData, Color, Color, String, String?, String, Color)>[
    (
      MSym.credit_card,
      C.rose100,
      C.rose500,
      '招商银行工资卡 (6821)',
      '推荐',
      '实时余额 ¥45,200.00',
      C.slate500,
    ),
    (
      MSym.chat,
      C.emerald100,
      C.emerald600,
      '微信钱包零钱',
      null,
      '零钱通理财可用',
      C.slate400,
    ),
    (
      MSym.account_balance,
      C.sky100,
      C.sky600,
      '支付宝余额 / 余利宝',
      null,
      '随时转出',
      C.slate400,
    ),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _usd = false;
      _excludeFromStats = false;
      _proxyPayment = false;
      _continueNext = false;
      _category = 0;
      _account = 0;
      _saving = false;
      _noteCtrl.text = '2025年5月份项目绩效与基本月薪';
    });
  }

  /// 确认入账：短暂落款动画后替换为首页。
  void _save() {
    if (_saving) return;
    setState(() => _saving = true);
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（标准返回键 + 标题 + 票据/重置）----
          GlassHeader.back(
            title: '新增日常收入',
            actions: [
              HeaderIconButton(icon: MSym.image, onTap: _reset),
              const SizedBox(width: 8),
              HeaderIconButton(icon: MSym.restart_alt, onTap: _reset),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const PageContentInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _modeSegment(),
                  const SizedBox(height: kCardGap),
                  _amountCard(),
                  const SizedBox(height: kCardGap),
                  _categoryCard(),
                  const SizedBox(height: kCardGap),
                  _accountCard(),
                  const SizedBox(height: kCardGap),
                  _advancedCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ===================== 三轨记账模式切换（收入轨激活） =====================
  Widget _modeSegment() {
    Widget seg(IconData icon, String label,
        {required bool active, bool fill = false, Color? iconColor}) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? const [
                    BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1)),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MIcon(icon, size: 16,
                  color: active ? iconColor ?? C.emerald600 : C.slate400,
                  fill: fill),
              const SizedBox(width: 4),
              Text(
                label,
                style: TS.body(
                  size: 12,
                  weight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? C.emerald600 : C.slate500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: C.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          seg(MSym.south_west, '日常支出', active: false),
          seg(MSym.north_east, '日常收入', active: true, fill: true),
          seg(MSym.memory, 'AI算力充值', active: false),
        ],
      ),
    );
  }

  // ===================== 入账金额卡片 =====================
  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 金额后方氛围光斑（blur-2xl）
          Positioned(
            right: -32,
            top: -32,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.emerald100.withValues(alpha: 0.45),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 币种标签 + 切换器
              Row(
                children: [
                  const MIcon(MSym.account_balance_wallet,
                      size: 18, color: C.emerald600),
                  const SizedBox(width: 6),
                  Text('入账金额',
                      style: TS.mono(
                          size: 11,
                          weight: FontWeight.w600,
                          color: C.slate400,
                          letterSpacing: 0.9)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: C.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _currencyBtn('¥ CNY', active: !_usd),
                        _currencyBtn('\$ USD', active: _usd),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // font-headline-lg（Space Grotesk 28 粗体）
                        Text(_usd ? '+\$' : '+¥',
                            style: TS.headline(
                                size: 28,
                                weight: FontWeight.w700,
                                color: C.emerald600,
                                letterSpacing: -0.02)),
                        const SizedBox(width: 4),
                        // font-display-lg-mobile（Space Grotesk 32 粗体大数字）
                        Text(
                          _usd ? '3,958.33' : '28,500.00',
                          style: TextStyle(
                            fontFamily: F.display,
                            fontSize: 32,
                            height: 40 / 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.02,
                            color: C.slate900,
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const MIcon(MSym.currency_exchange,
                            size: 14, color: C.slate400),
                        const SizedBox(width: 4),
                        Text(
                          _usd ? '≈ ¥28,500.00' : '≈ \$3,958.33',
                          style: TS.mono(size: 12, color: C.slate400),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.emerald50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.emerald100),
                          ),
                          child: Text('实时汇率 7.20',
                              style: TS.mono(size: 10, color: C.emerald700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 备注输入 + 语音 / 拍照增强
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: C.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
                ),
                child: Row(
                  children: [
                    const MIcon(MSym.edit_note, size: 20, color: C.slate400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _noteCtrl,
                        cursorColor: C.emerald500,
                        style: TS.body(size: 14, color: C.slate800),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '2025年5月工资薪金 / 咨询兼职收入',
                          hintStyle: TS.body(size: 14, color: C.slate400),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _roundToolBtn(MSym.mic),
                    const SizedBox(width: 8),
                    _roundToolBtn(MSym.add_a_photo),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currencyBtn(String label, {required bool active}) {
    return GestureDetector(
      onTap: () => setState(() => _usd = label.startsWith('\$')),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: active
              ? const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1)),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TS.mono(
            size: 13,
            weight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? C.emerald600 : C.slate500,
          ),
        ),
      ),
    );
  }

  Widget _roundToolBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: C.slate200.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 2),
        ],
      ),
      child: Center(child: MIcon(icon, size: 18, color: C.slate500)),
    );
  }

  // ===================== 收入来源类目九宫格 =====================
  Widget _categoryCard() {
    Widget item(int i) {
      final (icon, label) = _categories[i];
      final selected = _category == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _category = i),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? C.emerald50 : C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? C.emerald500 : C.slate100,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 3),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? C.emerald500 : C.slate200.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: MIcon(
                      icon,
                      size: 24,
                      color: selected ? Colors.white : C.slate600,
                      fill: selected,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // FittedBox 保证 4 字标签在窄格子中完整显示
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TS.body(
                      size: 12,
                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? C.emerald700 : C.slate600,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: C.emerald500,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('收入来源类目',
                  style: TS.body(size: 16, weight: FontWeight.w600, color: C.slate900)),
              const SizedBox(width: 6),
              Text('(8个分类)', style: TS.body(size: 12, color: C.slate400)),
              const Spacer(),
              // AI 智能预测徽标
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.violet50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: C.violet100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MIcon(MSym.auto_awesome,
                        size: 14, color: C.violet600, fill: true),
                    const SizedBox(width: 4),
                    Text('AI智能预测: 工资薪酬',
                        style: TS.mono(
                            size: 10,
                            weight: FontWeight.w600,
                            color: C.violet700,
                            letterSpacing: 0.8)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kCardGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item(0),
              item(1),
              item(2),
              item(3),
            ].withSpacing(kCardGap),
          ),
          const SizedBox(height: kCardGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item(4),
              item(5),
              item(6),
              item(7),
            ].withSpacing(kCardGap),
          ),
        ],
      ),
    );
  }

  // ===================== 入账账户 / 渠道 =====================
  Widget _accountCard() {
    Widget account(int i) {
      final (icon, tint, iconColor, title, badge, sub, subColor) =
          _accounts[i];
      final selected = _account == i;
      return GestureDetector(
        onTap: () => setState(() => _account = i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? C.emerald50.withValues(alpha: 0.7)
                : C.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? C.emerald300 : C.slate100),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint,
                  shape: BoxShape.circle,
                ),
                child: Center(child: MIcon(icon, size: 20, color: iconColor)),
              ),
              const SizedBox(width: 12),
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
                            style: TS.body(
                              size: 14,
                              weight: i == 0 ? FontWeight.w600 : FontWeight.w500,
                              color: i == 0 ? C.slate900 : C.slate800,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: C.emerald100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(badge,
                                style: TS.mono(
                                    size: 10,
                                    weight: FontWeight.w600,
                                    color: C.emerald700,
                                    letterSpacing: 0.8)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(sub, style: TS.mono(size: 12, color: subColor)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 单选圆点
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? C.emerald500 : Colors.transparent,
                  shape: BoxShape.circle,
                  border: selected ? null : Border.all(color: C.slate300, width: 2),
                ),
                child: selected
                    ? const Center(
                        child: MIcon(MSym.check,
                            size: 16, color: Colors.white, fill: true),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('入账账户 / 渠道',
                  style: TS.body(size: 16, weight: FontWeight.w600, color: C.slate900)),
              const Spacer(),
              Text('默认入账账户',
                  style: TS.mono(size: 12, weight: FontWeight.w500, color: C.emerald600)),
            ],
          ),
          const SizedBox(height: 12),
          account(0),
          const SizedBox(height: 4),
          account(1),
          const SizedBox(height: 4),
          account(2),
        ],
      ),
    );
  }

  // ===================== 日期与高级设置 =====================
  Widget _advancedCard() {
    Widget toggleRow(String title, String sub, bool value,
        ValueChanged<bool> onChanged) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TS.body(size: 14, weight: FontWeight.w500, color: C.slate800)),
                const SizedBox(height: 2),
                Text(sub, style: TS.body(size: 12, color: C.slate400)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _SwitchX(value: value, onChanged: onChanged),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 入账日期行
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.slate100),
            ),
            child: Row(
              children: [
                const MIcon(MSym.calendar_today, size: 20, color: C.emerald600),
                const SizedBox(width: 8),
                Text('入账日期',
                    style:
                        TS.body(size: 14, weight: FontWeight.w500, color: C.slate800)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: C.slate200.withValues(alpha: 0.8)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x08000000), blurRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text('2025年5月18日 · 今天',
                          style: TS.mono(
                              size: 14,
                              weight: FontWeight.w600,
                              color: C.emerald700)),
                      const SizedBox(width: 4),
                      const MIcon(MSym.arrow_drop_down,
                          size: 18, color: C.emerald700),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          toggleRow('不计入月度常规收入统计', '适用于大额资产变卖或偶然所得', _excludeFromStats,
              (v) => setState(() => _excludeFromStats = v)),
          const SizedBox(height: 16),
          toggleRow('标记为代收款项 / 待转交款', '稍后转付给第三方，不列入个人净结余', _proxyPayment,
              (v) => setState(() => _proxyPayment = v)),
        ],
      ),
    );
  }

  // ===================== 底部固定操作条 =====================
  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kCanvas,
        border: Border(top: BorderSide(color: C.slate100)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const PageContentInsets(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 辅助行：连续记账 + 云端状态
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _continueNext = !_continueNext),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          _CheckSquare(size: 16, checked: _continueNext),
                          const SizedBox(width: 8),
                          Text('保存后继续记下一笔',
                              style: TS.body(size: 12, color: C.slate500)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const PulsingDot(color: C.emerald500, size: 8),
                    const SizedBox(width: 6),
                    Text('FLOWAI 云端就绪',
                        style: TS.mono(
                            size: 11,
                            weight: FontWeight.w500,
                            color: C.slate500,
                            letterSpacing: 0.9)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // 确认入账主按钮
              GestureDetector(
                onTap: _saving ? null : _save,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _saving ? C.emerald600 : C.emerald500,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: C.emerald500.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MIcon(MSym.check_circle,
                          size: 20, color: Colors.white, fill: true),
                      const SizedBox(width: 8),
                      Text('确认入账',
                          style: TS.headline(
                              size: 16,
                              weight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HTML 原生勾选框（w-4 h-4 rounded text-emerald-600 border-slate-300）。
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
        color: checked ? C.emerald600 : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: checked ? C.emerald600 : C.slate300),
      ),
      child: checked
          ? Center(
              child: MIcon(MSym.check,
                  size: size - 4, color: Colors.white, fill: true))
          : null,
    );
  }
}

/// 设计稿 toggle 开关（w-11 h-6 圆角胶囊 + 白色圆形旋钮）。
class _SwitchX extends StatelessWidget {
  const _SwitchX({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? C.emerald500 : C.slate200,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x1A000000), blurRadius: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row 子项间距扩展（对应 Tailwind gap-x）。
extension _RowSpacing on List<Widget> {
  List<Widget> withSpacing(double gap) {
    final out = <Widget>[];
    for (var i = 0; i < length; i++) {
      if (i > 0) out.add(SizedBox(width: gap));
      out.add(this[i]);
    }
    return out;
  }
}
