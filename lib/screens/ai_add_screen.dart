import 'dart:async';

import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 调色板缺少的 purple-400 / purple-700 / blue-700 原值（1:1 设计稿色）。
const Color _kPurple400 = Color(0xFFC084FC);
const Color _kPurple700 = Color(0xFF701A75);
const Color _kBlue700 = Color(0xFF1D4ED8);

/// 记一笔AI消费（设计稿 ai_3）— 三态类型分段器、订阅套餐预设宫格 /
/// 单次算力充值面板、平台与付款渠道归选，底部吸底保存操作条。
class AiAddScreen extends StatefulWidget {
  const AiAddScreen({super.key});

  @override
  State<AiAddScreen> createState() => _AiAddScreenState();
}

class _AiAddScreenState extends State<AiAddScreen> {
  static const double _rate = 7.20; // 记账折合汇率

  // ---- 顶部三态 Tabs（0 日常支出 / 1 日常收入 / 2 AI消费订阅，默认 AI）----
  final int _topTab = 2;
  // ---- 记账类型（0 周期订阅套餐 / 1 单次算力充值）----
  int _mode = 0;
  // ---- 订阅面板 ----
  bool _monthly = true;
  int _plan = 0;
  final _subAmountCtrl = TextEditingController(text: '20.00');
  bool _remindOn = true;
  // ---- 充值面板 ----
  bool _usd = true; // true 美元 / false 人民币
  final _amountCtrl = TextEditingController(text: '100.00');
  final _amountFocus = FocusNode();
  int _platform = 0;
  // ---- 通用付款渠道与属性 ----
  int _payment = 0;
  bool _budgetOn = true;
  bool _invoice = true;
  // ---- 保存动效 ----
  bool _saving = false;

  static const _plans = <(IconData, Color, String, String, String)>[
    (MSym.smart_toy, C.emerald600, 'ChatGPT Plus', 'GPT-4o & o3-mini', '20.00'),
    (MSym.psychology, C.amber600, 'Claude Pro', 'Claude 3.7 Sonnet', '20.00'),
    (MSym.terminal, C.indigo600, 'Cursor Pro', 'AI Code Editor', '20.00'),
    (MSym.palette, C.slate900, 'Midjourney', 'Standard 订阅', '30.00'),
    (MSym.code_blocks, C.blue600, 'GitHub Copilot', '个人订阅版', '10.00'),
  ];

  @override
  void initState() {
    super.initState();
    _subAmountCtrl.addListener(() => setState(() {}));
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _subAmountCtrl.dispose();
    _amountCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _mode = 0;
      _monthly = true;
      _plan = 0;
      _remindOn = true;
      _usd = true;
      _platform = 0;
      _payment = 0;
      _budgetOn = true;
      _invoice = true;
      _subAmountCtrl.text = '20.00';
      _amountCtrl.text = '100.00';
    });
  }

  double _parse(String text) => double.tryParse(text) ?? 0;

  String _subConverted() =>
      '≈ ¥${(_parse(_subAmountCtrl.text) * _rate).toStringAsFixed(2)}';

  String _rechargeConverted() {
    final v = _parse(_amountCtrl.text);
    return _usd ? '≈ ¥${(v * _rate).toStringAsFixed(2)}' : '≈ \u0024${(v / _rate).toStringAsFixed(2)}';
  }

  DateTime get _nextBillingDate => _monthly
      ? DateTime(2025, 6, 18)
      : DateTime(2026, 5, 18);

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
          // ---- 统一毛玻璃顶栏（返回 + 标题 + 拍照识别/重置）----
          GlassHeader.back(
            title: '记一笔AI消费',
            actions: [
              HeaderIconButton(
                icon: MSym.document_scanner,
                onTap: () => Navigator.of(context).pushNamed('/ai-scan'),
              ),
              const SizedBox(width: 8),
              HeaderIconButton(icon: MSym.restart_alt, onTap: _reset),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _topTabs(),
                  const SizedBox(height: 12),
                  _modeSwitcher(),
                  const SizedBox(height: 14),
                  if (_mode == 0) ...[
                    _planCard(),
                    const SizedBox(height: 14),
                    _billingCard(),
                  ] else ...[
                    _rechargeAmountCard(),
                    const SizedBox(height: 14),
                    _platformCard(),
                  ],
                  const SizedBox(height: 14),
                  _paymentCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ===================== 顶部三态 Tabs 分段器 =====================
  Widget _topTabs() {
    Widget item(int i, IconData icon, String label, {bool fill = false}) {
      final active = _topTab == i;
      final fg = active ? C.purple600 : C.slate500;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (i == _topTab) return;
            // 日常支出 / 日常收入 跳转至对应记账屏幕
            Navigator.of(context).pushNamed(i == 0 ? '/add-expense' : '/add-income');
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: active ? Border.all(color: C.slate100) : null,
              boxShadow: active
                  ? const [
                      BoxShadow(
                          color: Color(0x0A000000), blurRadius: 2),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MIcon(icon, size: 16,
                    color: active ? C.purple600 : C.slate400, fill: active && fill),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 13,
                          weight: active ? FontWeight.w600 : FontWeight.w500,
                          color: fg)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: C.slate100.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          item(0, MSym.trending_down, '日常支出'),
          item(1, MSym.trending_up, '日常收入'),
          item(2, MSym.auto_awesome, 'AI消费/订阅', fill: true),
        ],
      ),
    );
  }

  // ===================== 记账类型分段切换器 =====================
  Widget _modeSwitcher() {
    Widget seg(int i, IconData icon, String label) {
      final active = _mode == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? C.emerald50 : C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? C.emerald500 : Colors.transparent,
                width: active ? 1 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MIcon(icon, size: 17,
                    color: active ? C.emerald600 : C.slate500),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 13,
                          weight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active ? C.emerald600 : C.slate600)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          seg(0, MSym.autorenew, '周期订阅套餐'),
          const SizedBox(width: 4),
          seg(1, MSym.bolt, '单次算力充值'),
        ],
      ),
    );
  }

  // ===================== 视图 1：订阅套餐预设卡片 =====================
  Widget _planCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const MIcon(MSym.loyalty,
                        size: 20, color: C.purple600, fill: true),
                    const SizedBox(width: 8),
                    Flexible(
                      // FittedBox 保证标题完整显示（与设计稿一致）
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('选择订阅服务与计划',
                            maxLines: 1,
                            style: TS.body(size: 15, weight: FontWeight.w600,
                                color: C.slate900)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 周期频次切换（月付 / 年付）
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: C.slate100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.slate200.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    _cycleBtn('按月订阅', _monthly,
                        () => setState(() => _monthly = true)),
                    _cycleBtn('按年订阅', !_monthly,
                        () => setState(() => _monthly = false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 常见 AI 订阅预设宫格（一键填充）
          Column(
            children: [
              for (var row = 0; row < 3; row++) ...[
                if (row > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _planCell(row * 2)),
                    const SizedBox(width: 10),
                    Expanded(child: _planCell(row * 2 + 1)),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // 消费金额输入显示区（输入框形态容器：bg-slate-50 rounded-xl border-slate-200）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.slate200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('\u0024',
                          style: TS.mono(size: 30, weight: FontWeight.w700,
                              color: C.emerald600)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _subAmountCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          cursorColor: C.emerald500,
                          style: TS.mono(size: 34, weight: FontWeight.w700,
                              color: C.slate900),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: C.emerald50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: C.emerald100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MIcon(MSym.currency_exchange,
                              size: 14, color: C.emerald600),
                          const SizedBox(width: 4),
                          Text(_subConverted(),
                              style: TS.mono(size: 12, weight: FontWeight.w600,
                                  color: C.emerald600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('记账折合汇率 7.20',
                        style: TS.body(size: 11, color: C.slate400)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cycleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 2)]
              : null,
        ),
        child: Text(
          label,
          style: TS.body(
            size: 12,
            weight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? C.emerald600 : C.slate500,
          ),
        ),
      ),
    );
  }

  Widget _planCell(int i) {
    if (i == 5) return _customPlanCell(i);
    final selected = _plan == i;
    final p = _plans[i];
    final price = p.$5;
    // 选中态：bg-emerald-50 border-2 emerald-500
    return GestureDetector(
      onTap: () {
        setState(() {
          _plan = i;
          _subAmountCtrl.text = price;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? C.emerald50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: C.emerald500, width: 2)
              : Border.all(color: C.slate200.withValues(alpha: 0.9)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: p.$2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: MIcon(p.$1, size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.body(size: 12, weight: FontWeight.w700,
                              color: C.slate900),
                        ),
                        Text(
                          p.$4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.mono(size: 11, weight: FontWeight.w400,
                              color: C.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\u0024${price.split('.').first}',
                    style: TS.mono(size: 13, weight: FontWeight.w700,
                        color: selected ? C.emerald600 : C.slate800)),
                Text(_monthly ? '/月' : '/年',
                    style: TS.body(size: 10, color: C.slate400, height: 1.2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 自定义订阅套餐（虚线边框占位，Flutter 无内建 dashed border → 简化为浅色实线）。
  Widget _customPlanCell(int i) {
    final selected = _plan == i;
    return GestureDetector(
      onTap: () {
        setState(() {
          _plan = i;
          _subAmountCtrl.text = '0.00';
        });
        _amountFocus.requestFocus();
        _subAmountCtrl.selection = TextSelection(
            baseOffset: 0, extentOffset: _subAmountCtrl.text.length);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? C.emerald50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: C.emerald500, width: 2)
              : Border.all(color: C.slate300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: C.slate100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: MIcon(MSym.add_circle,
                          size: 20, color: C.slate600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('其他AI服务',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TS.body(size: 12, weight: FontWeight.w700,
                                color: C.slate800)),
                        Text('自定义金额',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TS.body(size: 11, color: C.slate400)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const MIcon(MSym.edit, size: 18, color: C.slate400),
          ],
        ),
      ),
    );
  }

  // ===================== 订阅周期与自动续费提醒卡片 =====================
  Widget _billingCard() {
    final next =
        '${_nextBillingDate.year}-${_nextBillingDate.month.toString().padLeft(2, '0')}-${_nextBillingDate.day.toString().padLeft(2, '0')}';
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const MIcon(MSym.event_repeat, size: 19, color: C.slate700),
              const SizedBox(width: 8),
              Text('生效账期与续费设定',
                  style: TS.body(size: 15, weight: FontWeight.w600,
                      color: C.slate900)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  label: '本次扣费扣款日',
                  value: '2025-05-18',
                  valueStyle: TS.body(size: 12, weight: FontWeight.w600,
                      color: C.slate800),
                  icon: MSym.calendar_today,
                  iconColor: C.slate400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateBox(
                  label: '预计下期续费日',
                  value: next,
                  valueStyle: TS.mono(size: 12, weight: FontWeight.w600,
                      color: _kPurple700),
                  icon: MSym.notifications_active,
                  iconColor: _kPurple400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 自动续费待付开关
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: C.emerald50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.emerald100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MIcon(MSym.update, size: 20, color: C.emerald600),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('开启下期续费日前待付提醒',
                          style: TS.body(size: 12, weight: FontWeight.w600,
                              color: C.slate800)),
                      const SizedBox(height: 1),
                      Text('续费前 3 天推送到期提醒，避免被意外扣款',
                          style: TS.body(size: 11, color: C.slate500)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _WideToggle(on: _remindOn, onChanged: (v) => setState(() => _remindOn = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 视图 2 卡片 1：充值金额核心卡片 =====================
  Widget _rechargeAmountCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const MIcon(MSym.payments,
                        size: 19, color: C.purple600, fill: true),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('充值金额记录',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.body(size: 15, weight: FontWeight.w600,
                              color: C.slate800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 币种切换
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: C.slate100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.slate200.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    _cycleBtn('美元 \u0024', _usd,
                        () => setState(() => _usd = true)),
                    _cycleBtn('人民币 ¥', !_usd,
                        () => setState(() => _usd = false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 动态金额输入展示（输入框形态容器：bg-slate-50 rounded-xl border-slate-200）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.slate200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(_usd ? '\u0024' : '¥',
                          style: TS.mono(size: 30, weight: FontWeight.w700,
                              color: C.purple600)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          focusNode: _amountFocus,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          cursorColor: C.purple500,
                          style: TS.mono(size: 34, weight: FontWeight.w700,
                              color: C.slate900),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: C.emerald50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: C.emerald100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MIcon(MSym.currency_exchange,
                              size: 14, color: C.emerald600),
                          const SizedBox(width: 4),
                          Text(_rechargeConverted(),
                              style: TS.mono(size: 12, weight: FontWeight.w600,
                                  color: C.emerald600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('中行实时汇率 7.20',
                        style: TS.body(size: 11, color: C.slate400)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 档位预设胶囊组
          Column(
            children: [
              for (final row in const [
                <String>['20.00', '50.00', '100.00'],
                <String>['200.00', '500.00', '_custom'],
              ]) ...[
                Row(
                  children: [
                    for (var i = 0; i < row.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: _presetCell(row[i])),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetCell(String val) {
    final custom = val == '_custom';
    final selected =
        !custom && _amountCtrl.text == val && _usd;
    if (custom) {
      return GestureDetector(
        onTap: () {
          _amountFocus.requestFocus();
          _amountCtrl.selection = TextSelection(
              baseOffset: 0, extentOffset: _amountCtrl.text.length);
        },
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: C.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
          ),
          child: Text('自定义',
              style: TS.mono(size: 14, weight: FontWeight.w400,
                  color: C.slate600)),
        ),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _amountCtrl.text = val),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? C.purple50 : C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _kPurple400 : C.slate200.withValues(alpha: 0.8),
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              '\u0024${val.split('.').first}',
              style: TS.mono(
                size: 14,
                weight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? _kPurple700 : C.slate700,
              ),
            ),
          ),
          // 「常用」角标固定悬挂于 $100 档位
          if (val == '100.00')
            Positioned(
              top: -8,
              right: -4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: C.emerald500,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('常用',
                    style: TS.body(size: 10, weight: FontWeight.w600,
                        color: Colors.white, height: 1.2)),
              ),
            ),
        ],
      ),
    );
  }

  // ===================== 视图 2 卡片 2：充值渠道平台归类 =====================
  Widget _platformCard() {
    Widget option({
      required int index,
      required IconData icon,
      required Color iconBg,
      required Color iconFg,
      Color? iconBorder,
      required String name,
      required String? tag,
      required String sub,
      required Color subColor,
    }) {
      final selected = _platform == index;
      return GestureDetector(
        onTap: () => setState(() => _platform = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? C.purple50.withValues(alpha: 0.7) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _kPurple400 : C.slate200.withValues(alpha: 0.9),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                        border: iconBorder != null
                            ? Border.all(color: iconBorder)
                            : null,
                      ),
                      child: Center(
                          child: MIcon(icon, size: 22, color: iconFg)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TS.body(size: 14,
                                        weight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: selected
                                            ? C.slate900
                                            : C.slate800)),
                              ),
                              if (tag != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: C.purple100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(tag,
                                      style: TS.mono(size: 10,
                                          weight: FontWeight.w600,
                                          color: _kPurple700)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.mono(size: 12, weight: FontWeight.w400,
                                  color: subColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 单选指示器
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _kPurple700 : C.slate100,
                  border: selected
                      ? null
                      : Border.all(color: C.slate300.withValues(alpha: 0.8)),
                ),
                child: selected
                    ? const Center(
                        child: MIcon(MSym.check,
                            size: 16, color: Colors.white))
                    : Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: C.slate300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const MIcon(MSym.hub, size: 19, color: C.purple600),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('充值目标平台与渠道',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.body(size: 15, weight: FontWeight.w600,
                              color: C.slate800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.slate100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('用于API开销分类',
                    style: TS.body(size: 11, weight: FontWeight.w500,
                        color: C.slate500)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              option(
                index: 0,
                icon: MSym.smart_toy,
                iconBg: C.purple600,
                iconFg: Colors.white,
                name: 'OpenAI Platform',
                tag: 'GPT-4o / o3',
                sub: 'org-8y9T...prod • 当前可用 \u002412.40',
                subColor: C.slate500,
              ),
              const SizedBox(height: 10),
              option(
                index: 1,
                icon: MSym.psychology,
                iconBg: C.slate100,
                iconFg: C.slate700,
                name: 'Anthropic Console (Claude 3.7)',
                tag: null,
                sub: 'wksp-core • 当前余量 \u00248.50',
                subColor: C.slate400,
              ),
              const SizedBox(height: 10),
              option(
                index: 2,
                icon: MSym.blur_on,
                iconBg: C.sky50,
                iconFg: C.sky600,
                iconBorder: C.sky100,
                name: 'DeepSeek API (深度求索 V3/R1)',
                tag: null,
                sub: '国内人民币渠道 • 当前余量 ¥48.20',
                subColor: C.slate400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 卡片 3：付款账户与账单属性（记账通用） =====================
  Widget _paymentCard() {
    Widget channel({
      required int index,
      required Widget badge,
      required String title,
      required String? titleTag,
      required String titleTagColor,
      required String sub,
      required Color subColor,
    }) {
      final selected = _payment == index;
      return GestureDetector(
        onTap: () => setState(() => _payment = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? C.emerald50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? C.emerald500 : C.slate200.withValues(alpha: 0.8),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              badge,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.body(size: 12,
                                  weight: FontWeight.w600,
                                  color: selected ? C.slate900 : C.slate800)),
                        ),
                        if (titleTag != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: titleTagColor == 'emerald'
                                  ? C.emerald100
                                  : C.slate100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(titleTag,
                                style: TS.body(size: 10,
                                    weight: FontWeight.w500,
                                    color: titleTagColor == 'emerald'
                                        ? C.emerald600
                                        : C.slate600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TS.body(size: 11, color: subColor)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? C.emerald500 : C.slate100,
                  border: selected
                      ? null
                      : Border.all(color: C.slate300),
                ),
                child: selected
                    ? const Center(
                        child: MIcon(MSym.check,
                            size: 14, color: Colors.white))
                    : Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: C.slate300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    Widget cardBadge({
      required Widget child,
      required Color bg,
      required Color border,
    }) {
      return Container(
        width: 40,
        height: 28,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border),
        ),
        child: Center(child: child),
      );
    }

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const MIcon(MSym.credit_card, size: 19, color: C.slate700),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('扣款账户与付款渠道',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.body(size: 15, weight: FontWeight.w600,
                              color: C.slate800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text('切换账户',
                      style: TS.body(size: 12, weight: FontWeight.w600,
                          color: C.purple600)),
                  const MIcon(MSym.chevron_right,
                      size: 14, color: C.purple600),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              channel(
                index: 0,
                badge: cardBadge(
                  bg: Colors.white,
                  border: C.slate200,
                  child: Text('VISA',
                      style: TS.mono(size: 12, weight: FontWeight.w700,
                          color: _kBlue700)),
                ),
                title: '招行双币信用卡 (4390)',
                titleTag: '默认海淘',
                titleTagColor: 'emerald',
                sub: 'USD / CNY 自动购汇记账 • 额度充裕',
                subColor: C.slate500,
              ),
              const SizedBox(height: 8),
              channel(
                index: 1,
                badge: cardBadge(
                  bg: C.emerald50,
                  border: C.emerald100,
                  child: const MIcon(MSym.payments,
                      size: 18, color: C.emerald600),
                ),
                title: '微信支付',
                titleTag: '零钱通 / 储蓄卡',
                titleTagColor: 'slate',
                sub: '国内镜像与聚合平台极速结算',
                subColor: C.slate400,
              ),
              const SizedBox(height: 8),
              channel(
                index: 2,
                badge: cardBadge(
                  bg: C.sky50,
                  border: C.sky100,
                  child: const MIcon(MSym.account_balance_wallet,
                      size: 18, color: C.sky600),
                ),
                title: '支付宝支付',
                titleTag: '余额宝 / 花呗',
                titleTagColor: 'slate',
                sub: '免手续费实时扣划',
                subColor: C.slate400,
              ),
              const SizedBox(height: 8),
              channel(
                index: 3,
                badge: cardBadge(
                  bg: C.slate900,
                  border: C.slate900,
                  child: const MIcon(MSym.contactless,
                      size: 18, color: Colors.white),
                ),
                title: 'Apple Pay / Stripe',
                titleTag: '海外官方',
                titleTagColor: 'slate',
                sub: '支持全球通用卡、虚拟卡订阅',
                subColor: C.slate400,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 记账属性开关组
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 开关 1: 预算同步标记
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: C.slate50.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.slate100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MIcon(MSym.pie_chart, size: 20, color: C.emerald600),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('计入本月 AI 研发与订阅预算',
                              style: TS.body(size: 12,
                                  weight: FontWeight.w500,
                                  color: C.slate800)),
                          const SizedBox(height: 1),
                          Text('纳入月度 AI 预算统计与分类图表',
                              style: TS.body(size: 11, color: C.slate400)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _WideToggle(on: _budgetOn, onChanged: (v) => setState(() => _budgetOn = v)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 勾选项: 企业报销凭据
              GestureDetector(
                onTap: () => setState(() => _invoice = !_invoice),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      _CheckSquare(size: 16, checked: _invoice),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('生成企业报销 Invoice 凭据与待报销标签',
                            style: TS.body(size: 12, color: C.slate600)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 底部吸底操作栏 =====================
  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCanvas.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: C.slate100)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 记账安全与同步说明
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const MIcon(MSym.check_circle,
                            size: 16, color: C.emerald600, fill: true),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('数据将自动同步至AI订阅统计与月度预算',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.body(size: 12,
                                  weight: FontWeight.w500,
                                  color: C.slate700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const MIcon(MSym.cloud_done, size: 13, color: C.slate400),
                      const SizedBox(width: 4),
                      Text('本地与云端已加密备份',
                          style: TS.body(size: 11, color: C.slate400)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 确认保存账单操作按钮
              GestureDetector(
                onTap: _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: _saving ? C.emerald600 : C.emerald500,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x5910B981),
                          blurRadius: 14,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_saving)
                        const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white),
                        )
                      else
                        const MIcon(MSym.check,
                            size: 19, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _saving ? '正在保存AI消费账单...' : '保存AI消费账单',
                        style: TS.body(size: 15, weight: FontWeight.w600,
                            color: Colors.white),
                      ),
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

// =====================================================================
// 私有组件
// =====================================================================

/// 白色圆角卡片（rounded-2xl border-slate-100 shadow）。
class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

/// 账期信息小盒（bg-slate-50 p-2.5 rounded-xl border-slate-200/70）。
class _DateBox extends StatelessWidget {
  const _DateBox({
    required this.label,
    required this.value,
    required this.valueStyle,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final TextStyle valueStyle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: C.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.slate200.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TS.body(size: 11, weight: FontWeight.w500,
              color: C.slate400)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle),
              ),
              const SizedBox(width: 4),
              MIcon(icon, size: 16, color: iconColor),
            ],
          ),
        ],
      ),
    );
  }
}

/// 宽版 iOS 开关（w-12 h-6，emerald-500 激活）。
class _WideToggle extends StatelessWidget {
  const _WideToggle({required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const h = 24.0;
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: h,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? C.emerald500 : C.slate200,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: h - 4,
            height: h - 4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}

/// 勾选方块（w-4 h-4 rounded accent-emerald）。
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
            color: checked ? C.emerald500 : C.slate300),
      ),
      child: checked
          ? Center(
              child: MIcon(MSym.check,
                  size: size - 4, color: Colors.white))
          : null,
    );
  }
}
