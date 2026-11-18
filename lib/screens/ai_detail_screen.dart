import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// AI 充值与订阅详情（设计稿 ai_1）— OpenAI 组织规格、资金与额度监控仪表盘、
/// 交易凭据会计归集、周期扣费流水与自动化规则备忘，底部吸底续订操作条。
class AiDetailScreen extends StatefulWidget {
  const AiDetailScreen({super.key});

  @override
  State<AiDetailScreen> createState() => _AiDetailScreenState();
}

class _AiDetailScreenState extends State<AiDetailScreen> {
  bool _autoTopUp = true; // 低于阈值自动补扣充值
  bool _pushAlert = true; // 低额度极速推送
  bool _profitReport = true; // 计入企业月度损益报表

  void _copy(String text, String tip) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: C.slate900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(tip, style: TS.body(size: 12, color: Colors.white)),
      ));
  }

  /// 底部「立即续订与充值」— 弹出确认对话框（保持静态逻辑）。
  void _confirmRecharge() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const MIcon(MSym.bolt, size: 20, color: C.emerald600, fill: true),
            const SizedBox(width: 8),
            Text('确认续订与充值',
                style: TS.headline(size: 17, weight: FontWeight.w700,
                    color: C.slate900)),
          ],
        ),
        content: Text(
          '本次将支付 \$149.00（ChatGPT Plus 订阅 \$20.00 + 算力充值 \$129.00），'
          '将从「招商双币虚拟外币卡 (•••• 4288)」扣款并同步至算力账本。',
          style: TS.body(size: 13, color: C.slate600, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('取消',
                style: TS.body(size: 14, weight: FontWeight.w500,
                    color: C.slate500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _copy('TXN_0AI_202505159821034', '已发起续订与充值请求');
            },
            child: Text('确认支付',
                style: TS.body(size: 14, weight: FontWeight.w600,
                    color: C.emerald600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（返回 + 标题 + 更多/头像）----
          GlassHeader.back(
            title: 'AI 充值与订阅详情',
            actions: const [
              HeaderIconButton(icon: MSym.more_horiz),
              SizedBox(width: 8),
              HeaderIconButton(icon: MSym.person),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const PageContentInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _toastBanner(),
                  const SizedBox(height: kCardGap),
                  _orgCard(),
                  const SizedBox(height: kCardGap),
                  _fundsCard(),
                  const SizedBox(height: kCardGap),
                  _voucherCard(),
                  const SizedBox(height: kCardGap),
                  _flowCard(),
                  const SizedBox(height: kCardGap),
                  _rulesCard(),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ===================== Toast 动效提醒 =====================
  Widget _toastBanner() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.emerald50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.emerald100.withValues(alpha: 0.9)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: C.emerald500,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: C.emerald200.withValues(alpha: 0.9),
                      blurRadius: 2,
                      offset: const Offset(0, 1)),
                ],
              ),
              child: const Center(
                child: MIcon(MSym.check_circle,
                    size: 18, color: Colors.white, fill: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text('充值成功 · 已同步至算力账本',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TS.body(size: 13, weight: FontWeight.w600,
                                color: C.emerald950)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: C.emerald100,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: C.emerald200.withValues(alpha: 0.6)),
                        ),
                        child: Text('LIVE',
                            style: TS.mono(size: 10, weight: FontWeight.w600,
                                color: C.emerald800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+\$50.00 额度瞬时入账 (折合 ¥362.50 · 实时汇率 7.2500)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(size: 11, color: C.emerald700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('14:32:08',
                style: TS.mono(
                    size: 11, weight: FontWeight.w400,
                    color: C.emerald600.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  // ===================== 1. 组织与模型规格卡片 =====================
  Widget _orgCard() {
    return _BigCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 深色渐变 Logo 方块（设计稿为 OpenAI SVG 标志，
              // 素材库无对应矢量 → 以最接近的 smart_toy 实心字形代替）
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [C.slate900, C.slate800, C.indigo950],
                  ),
                ),
                child: const Center(
                  child: MIcon(MSym.smart_toy,
                      size: 26, color: Colors.white, fill: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text('OpenAI Platform',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.body(size: 17, weight: FontWeight.w700,
                                  color: C.slate900)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.emerald50,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: C.emerald200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const PulsingDot(
                                  color: C.emerald500, size: 6),
                              const SizedBox(width: 4),
                              Text('运行中',
                                  style: TS.body(size: 10,
                                      weight: FontWeight.w600,
                                      color: C.emerald700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('ChatGPT Plus & API 统一计费组织',
                        style: TS.body(size: 12, weight: FontWeight.w500,
                            color: C.slate500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 标签徽章阵列
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _TagChip(
                background: C.violet50,
                border: C.violet100,
                radius: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MIcon(MSym.auto_awesome,
                        size: 13, color: C.violet500),
                    const SizedBox(width: 4),
                    Text('GPT-4o 默认优先',
                        style: TS.body(size: 11, weight: FontWeight.w500,
                            color: C.violet700)),
                  ],
                ),
              ),
              _TagChip(
                background: C.slate100,
                border: C.slate200.withValues(alpha: 0.6),
                radius: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text('Tier-4 Org',
                    style: TS.mono(size: 11, weight: FontWeight.w500,
                        color: C.slate700)),
              ),
              GestureDetector(
                onTap: () => _copy('org-k892xnl8', '组织 ID 已复制到剪贴板'),
                child: _TagChip(
                  background: C.slate50,
                  border: C.slate200.withValues(alpha: 0.6),
                  radius: 12,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('org-k892xnl8',
                          style: TS.mono(size: 11, weight: FontWeight.w500,
                              color: C.slate500)),
                      const SizedBox(width: 4),
                      const MIcon(MSym.content_copy,
                          size: 12, color: C.slate500),
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

  // ===================== 2. 资金与额度监控 =====================
  Widget _fundsCard() {
    return _BigCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('资金与额度监控',
                  style: TS.body(
                      size: 13, weight: FontWeight.w600,
                      color: C.slate400, height: 1.2)
                  // uppercase tracking-wider
                  ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: C.emerald50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: C.emerald100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MIcon(MSym.verified, size: 13, color: C.emerald600),
                    const SizedBox(width: 4),
                    Text('已对账·无逾期',
                        style: TS.body(size: 11, weight: FontWeight.w500,
                            color: C.emerald600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 主余额展示
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('\$',
                  style: TS.mono(size: 20, weight: FontWeight.w700,
                      color: C.slate400)),
              const SizedBox(width: 6),
              Text('54.20',
                  style: TS.mono(size: 36, weight: FontWeight.w700,
                      color: C.slate900)),
              const SizedBox(width: 6),
              Text('USD',
                  style: TS.body(size: 14, weight: FontWeight.w700,
                      color: C.slate400)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text('折合 ¥392.95 CNY',
                  style: TS.body(size: 13, weight: FontWeight.w500,
                      color: C.slate500)),
              const SizedBox(width: 8),
              Text('•', style: TS.body(size: 13, color: C.slate300)),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  style: TS.body(size: 11, color: C.slate400),
                  children: [
                    const TextSpan(text: '充值前余额: '),
                    TextSpan(
                        text: '\$4.20',
                        style: TS.mono(size: 11, weight: FontWeight.w500,
                            color: C.slate600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 额度上限与进度条
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.slate100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const MIcon(MSym.shield_with_heart,
                              size: 16, color: C.slate400),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('月度硬性消费上限 (Hard CAP)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TS.body(size: 12,
                                    weight: FontWeight.w500,
                                    color: C.slate600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('\$200.00',
                        style: TS.mono(size: 12, weight: FontWeight.w700,
                            color: C.slate800)),
                  ],
                ),
                const SizedBox(height: 8),
                // 进度条 27.1%
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 10,
                    child: Stack(
                      children: [
                        Container(
                            color: C.slate200.withValues(alpha: 0.8)),
                        FractionallySizedBox(
                          widthFactor: 0.271,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [C.emerald400, C.teal500]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('已消耗 \$54.20 (27.1%)',
                        style: TS.mono(size: 10, weight: FontWeight.w500,
                            color: C.slate400)),
                    Text('剩余可用缓冲 \$145.80',
                        style: TS.mono(size: 10, weight: FontWeight.w500,
                            color: C.slate400)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 7 天算力水位平滑图表与智能预测
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text('近 7 天消耗与水位推演',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.body(size: 13,
                                  weight: FontWeight.w600,
                                  color: C.slate800)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.emerald50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.emerald100),
                          ),
                          child: Text('稳健水位',
                              style: TS.body(size: 10,
                                  weight: FontWeight.w500,
                                  color: C.emerald700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('均值 \$2.26 / 天',
                      style: TS.body(size: 12, weight: FontWeight.w500,
                          color: C.slate500)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.slate50.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.slate100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 曲线图（SVG 还原为 CustomPaint）
                    SizedBox(
                      height: 96,
                      width: double.infinity,
                      child: CustomPaint(painter: _WaterChartPainter()),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final label in const [
                            '05-09',
                            '05-11',
                            '05-13',
                            '今日 (05-15)',
                          ])
                            Text(label,
                                style: TS.mono(size: 10,
                                    weight: FontWeight.w500,
                                    color: C.slate400)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 预测卡片标签
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.slate100),
                      ),
                      child: Row(
                        children: [
                          const MIcon(MSym.hourglass_top,
                              size: 16, color: C.emerald600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: TS.body(size: 11, color: C.slate600),
                                children: [
                                  const TextSpan(
                                      text: '按现有负载频率，当前总额度预计可支撑运行约 '),
                                  TextSpan(
                                      text: '22 ~ 24 天',
                                      style: TS.mono(size: 11,
                                          weight: FontWeight.w600,
                                          color: C.slate900)),
                                ],
                              ),
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
          const SizedBox(height: 16),
          // 自动化补扣阈值配置
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.slate100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: C.emerald100.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: MIcon(MSym.sync_saved_locally,
                        size: 16, color: C.emerald700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('低于阈值自动补扣充值',
                          style: TS.body(size: 13, weight: FontWeight.w600,
                              color: C.slate800)),
                      const SizedBox(height: 2),
                      Text('余额低于 \$10.00 时，从默认卡自动补扣 \$50.00',
                          style: TS.body(size: 11, color: C.slate500)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _Toggle(
                    on: _autoTopUp,
                    onChanged: (v) => setState(() => _autoTopUp = v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 3. 交易凭证与会计归集 =====================
  Widget _voucherCard() {
    return _BigCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('交易凭据与会计核算',
                  style: TS.body(size: 13, weight: FontWeight.w600,
                      color: C.slate400)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.indigo50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: C.indigo100),
                ),
                child: Text('已开具 Stripe 凭据',
                    style: TS.body(size: 11, weight: FontWeight.w600,
                        color: C.indigo600)),
              ),
            ],
          ),
          const SizedBox(height: kCardGap),
          Column(
            children: [
              // 支付卡
              _VoucherRow(
                label: '支付扣款方式',
                value: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: C.red50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: C.red100),
                      ),
                      child: Text('CMB',
                          style: TS.body(size: 10, weight: FontWeight.w700,
                              color: C.red600, height: 1.2)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('招商双币虚拟外币卡 (•••• 4288)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.mono(size: 12, weight: FontWeight.w500,
                              color: C.slate800)),
                    ),
                  ],
                ),
              ),
              // 交易流水号
              _VoucherRow(
                label: '交易流水单号',
                value: GestureDetector(
                  onTap: () => _copy('TXN_0AI_202505159821034', '交易流水单号已复制'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: C.slate50,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: C.slate200.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text('TXN_0AI_202505159821034',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.mono(size: 12, weight: FontWeight.w500,
                                  color: C.slate700)),
                        ),
                        const SizedBox(width: 4),
                        const MIcon(MSym.content_copy,
                            size: 13, color: C.slate400),
                      ],
                    ),
                  ),
                ),
              ),
              // 会计归属
              _VoucherRow(
                label: '核算科目归属',
                value: Row(
                  children: [
                    Flexible(
                      child: Text('AI 生产力工具 / 算力充值',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.body(size: 12, weight: FontWeight.w500,
                              color: C.slate800)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: C.slate100,
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: C.slate200.withValues(alpha: 0.6)),
                      ),
                      child: Text('固定成本',
                          style: TS.body(size: 10, weight: FontWeight.w500,
                              color: C.slate600)),
                    ),
                  ],
                ),
              ),
              // 独立核算备注
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: C.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.slate100),
                ),
                child: Row(
                  children: [
                    const MIcon(MSym.account_balance_wallet,
                        size: 15, color: C.slate400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('自动归入「AI 专属财务账单 · 独立核算项目」',
                          style: TS.body(size: 11, color: C.slate500)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 凭证操作按钮
          Row(
            children: [
              Expanded(
                child: _GhostButton(
                  icon: MSym.description,
                  label: '下载 PDF 发票',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GhostButton(
                  icon: MSym.open_in_new,
                  label: '查看 Stripe 凭据',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 4. 扣费周期与近期流水 =====================
  Widget _flowCard() {
    return _BigCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('周期扣费与近期流水',
                  style: TS.body(size: 13, weight: FontWeight.w600,
                      color: C.slate400)),
              Text.rich(
                TextSpan(
                  style: TS.body(size: 11, color: C.slate500),
                  children: [
                    const TextSpan(text: '下次账单日: '),
                    TextSpan(
                        text: '06-01 (剩 17 天)',
                        style: TS.mono(size: 11, weight: FontWeight.w600,
                            color: C.slate800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kCardGap),
          Column(
            children: [
              _FlowItem(
                icon: MSym.add_card,
                iconBg: C.emerald100,
                iconColor: C.emerald600,
                title: '手动额度充值',
                time: '2025-05-15 14:32:08',
                amount: '+\$50.00',
                amountColor: C.emerald600,
                note: '已入账',
              ),
              const SizedBox(height: kCardGap),
              _FlowItem(
                icon: MSym.autorenew,
                iconBg: C.violet100,
                iconColor: C.violet600,
                title: 'ChatGPT Plus 订阅扣费',
                time: '2025-05-01 08:00:00',
                amount: '-\$20.00',
                amountColor: C.slate800,
                note: '常规月结扣款',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 5. 自动化触发规则与记账备忘 =====================
  Widget _rulesCard() {
    return _BigCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('告警机制与记账备忘',
              style: TS.body(size: 13, weight: FontWeight.w600,
                  color: C.slate400)),
          const SizedBox(height: 16),
          Column(
            children: [
              // 规则 1
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('低额度极速推送',
                            style: TS.body(size: 13, weight: FontWeight.w500,
                                color: C.slate800)),
                        const SizedBox(height: 2),
                        Text('低于 \$10.00 时推送企业微信通知与短信预警',
                            style: TS.body(size: 11, color: C.slate400)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Toggle(
                    on: _pushAlert,
                    onChanged: (v) => setState(() => _pushAlert = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: C.slate100),
              const SizedBox(height: 12),
              // 规则 2
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('计入企业月度损益报表',
                            style: TS.body(size: 13, weight: FontWeight.w500,
                                color: C.slate800)),
                        const SizedBox(height: 2),
                        Text('月底自动汇总至成本中心研发算力开支',
                            style: TS.body(size: 11, color: C.slate400)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Toggle(
                    on: _profitReport,
                    onChanged: (v) => setState(() => _profitReport = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: C.slate100),
              const SizedBox(height: 12),
              // 记账备忘录
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('记账备忘录 (Memo)',
                          style: TS.body(size: 12, weight: FontWeight.w600,
                              color: C.slate700)),
                      Text('已自动保存',
                          style: TS.body(size: 10, weight: FontWeight.w500,
                              color: C.emerald600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.slate50,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: C.slate200.withValues(alpha: 0.8)),
                    ),
                    child: Text(
                      '用于 Q2 向量检索与 GPT-4o 批量知识库索引实验批次充值。归集负责人：@TechLead。',
                      style: TS.body(size: 12, color: C.slate700, height: 1.6),
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

  // ===================== 底部吸底操作栏 =====================
  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCanvas,
        border: Border(
          top: BorderSide(color: C.slate200.withValues(alpha: 0.8)),
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPageInset),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('待付总额 (Est. Net)',
                          style: TS.mono(size: 11, weight: FontWeight.w500,
                              color: C.slate400)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('\$',
                              style: TS.mono(size: 14, weight: FontWeight.w700,
                                  color: C.emerald600)),
                          const SizedBox(width: 2),
                          Text('149.00',
                              style: TS.mono(size: 22, weight: FontWeight.w700,
                                  color: C.slate900)),
                          const SizedBox(width: 2),
                          Text('/ 月',
                              style: TS.body(size: 11,
                                  weight: FontWeight.w500,
                                  color: C.slate400)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 立即续订与充值
                GestureDetector(
                  onTap: _confirmRecharge,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: C.emerald500,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: C.emerald500.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const MIcon(MSym.bolt,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('立即续订与充值',
                            style: TS.body(size: 15,
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
      ),
    );
  }
}

// =====================================================================
// 私有组件
// =====================================================================

/// 白色大圆角卡片（rounded-3xl border-slate-200/60 shadow-sm）。
class _BigCard extends StatelessWidget {
  const _BigCard({required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.slate200.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: child,
    );
  }
}

/// 凭证明细行（py-1 border-b border-slate-50）。
class _VoucherRow extends StatelessWidget {
  const _VoucherRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: C.slate50)),
      ),
      child: Row(
        children: [
          Text(label, style: TS.body(size: 13, color: C.slate500)),
          const SizedBox(width: 12),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: value),
          ),
        ],
      ),
    );
  }
}

/// 流水条目（p-3 rounded-2xl bg-slate-50 border-slate-100）。
class _FlowItem extends StatelessWidget {
  const _FlowItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.amount,
    required this.amountColor,
    required this.note,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String time;
  final String amount;
  final Color amountColor;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: MIcon(icon, size: 18, color: iconColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(size: 13, weight: FontWeight.w600,
                        color: C.slate800)),
                const SizedBox(height: 2),
                Text(time, style: TS.mono(size: 11, color: C.slate400)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TS.mono(size: 14, weight: FontWeight.w700,
                      color: amountColor)),
              const SizedBox(height: 2),
              Text(note, style: TS.body(size: 10, color: C.slate400)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 通用标签徽章容器。
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.child,
    required this.background,
    required this.border,
    required this.padding,
    required this.radius,
  });

  final Widget child;
  final Color background;
  final Color border;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

/// 灰底操作小按钮（h-10 rounded-xl bg-slate-100）。
class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: C.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.slate200.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MIcon(icon, size: 16, color: C.slate500),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TS.body(size: 12, weight: FontWeight.w500,
                    color: C.slate700)),
          ),
        ],
      ),
    );
  }
}

/// iOS 风格精致 Toggle（w-11 h-6，emerald-500 激活）。
class _Toggle extends StatelessWidget {
  const _Toggle({required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const h = 24.0;
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: h,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? C.emerald500 : C.slate300,
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
              boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 2)],
            ),
          ),
        ),
      ),
    );
  }
}

/// 7 天算力水位平滑曲线图（还原设计稿 SVG：面积渐变 + 平滑曲线 + 数据点）。
class _WaterChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const vw = 320.0, vh = 90.0;
    final sx = size.width / vw;
    final sy = size.height / vh;

    // 辅助参考线（#e2e8f0 虚线）
    final gridPaint = Paint()
      ..color = C.slate200
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (final y in const [20.0, 55.0]) {
      final py = y * sy;
      for (var x = 0.0; x < size.width; x += 6) {
        canvas.drawLine(Offset(x, py),
            Offset((x + 3).clamp(0.0, size.width), py), gridPaint);
      }
    }

    // 平滑曲线路径（M 0 68 Q 50 62, 100 45 T 200 48 T 270 32 T 320 22）
    Offset p0, c1, p1, c2, p2, c3, p3, c4, p4;
    p0 = Offset(0 * sx, 68 * sy);
    c1 = Offset(50 * sx, 62 * sy);
    p1 = Offset(100 * sx, 45 * sy);
    // T 命令：控制点为上一控制点关于上一终点的镜像
    c2 = Offset(2 * p1.dx - c1.dx, 2 * p1.dy - c1.dy);
    p2 = Offset(200 * sx, 48 * sy);
    c3 = Offset(2 * p2.dx - c2.dx, 2 * p2.dy - c2.dy);
    p3 = Offset(270 * sx, 32 * sy);
    c4 = Offset(2 * p3.dx - c3.dx, 2 * p3.dy - c3.dy);
    p4 = Offset(320 * sx, 22 * sy);

    final curve = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(c1.dx, c1.dy, p1.dx, p1.dy)
      ..quadraticBezierTo(c2.dx, c2.dy, p2.dx, p2.dy)
      ..quadraticBezierTo(c3.dx, c3.dy, p3.dx, p3.dy)
      ..quadraticBezierTo(c4.dx, c4.dy, p4.dx, p4.dy);

    // 面积渐变
    final area = Path.from(curve)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.25),
            const Color(0xFF10B981).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // 曲线描边
    canvas.drawPath(
      curve,
      Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    void dot(Offset o, double r, Color fill, Color stroke, double sw) {
      canvas.drawCircle(o, r, Paint()..color = fill);
      canvas.drawCircle(
        o,
        r,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw,
      );
    }

    // 数据打点
    dot(p1, 3.5 * ((sx + sy) / 2), Colors.white, const Color(0xFF10B981), 2);
    dot(p2, 3.5 * ((sx + sy) / 2), Colors.white, const Color(0xFF10B981), 2);
    dot(p4, 4.5 * ((sx + sy) / 2), const Color(0xFF10B981), Colors.white, 2.5);
  }

  @override
  bool shouldRepaint(covariant _WaterChartPainter oldDelegate) => false;
}
