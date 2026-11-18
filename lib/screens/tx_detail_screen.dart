import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

// Material 设计系统色（glacial_cyber_finance，HTML tailwind 自定义色板）
const _kOnSurface = Color(0xFF171B26); // on-surface
const _kOnSurfaceVariant = Color(0xFF3C4A42); // on-surface-variant
const _kPrimaryContainer = C.emerald500; // primary-container #10b981
const _kSurfaceContainer = Color(0xFFECEEF3); // surface-container
const _kSurfaceContainerLow = Color(0xFFF2F3F9); // surface-container-low
const _kSurfaceDim = Color(0xFFD7D9E8); // surface-dim
const _kOutlineVariant = Color(0xFFBBCABF); // outline-variant
const _kAmber800 = C.amber700; // amber-800 → 调色板最接近 amber-700
const _kSky800 = C.sky700; // sky-800 → 调色板最接近 sky-700
const _kIndigo800 = C.indigo700; // indigo-800 → 调色板最接近 indigo-700

/// 单笔消费详情（设计稿 _8）— 金额主卡、双轨记账与 AI 审计、
/// 交易流水信息、电子凭据存根、AA 分摊与底部操作。
class TxDetailScreen extends StatefulWidget {
  const TxDetailScreen({super.key});

  @override
  State<TxDetailScreen> createState() => _TxDetailScreenState();
}

class _TxDetailScreenState extends State<TxDetailScreen> {
  static const _serial = '202505182000400111009842103';
  bool _copied = false;
  Timer? _copyTimer;

  /// 支出特征标签（bg, fg, label）
  final List<(Color, Color, String)> _tags = const [
    (C.amber50, _kAmber800, '#工作日提神'),
    (C.sky50, _kSky800, '#线下扫码'),
    (C.indigo50, _kIndigo800, '#个人餐饮'),
  ];

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _copySerial() {
    Clipboard.setData(const ClipboardData(text: _serial));
    setState(() => _copied = true);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _addTag() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('添加特征标签',
            style: TS.body(size: 16, weight: FontWeight.w600, color: _kOnSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          cursorColor: _kPrimaryContainer,
          decoration: const InputDecoration(
            hintText: '输入新标签 (如 #朋友小聚)',
          ),
          style: TS.body(size: 14, color: _kOnSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('取消', style: TS.body(size: 14, color: _kOnSurfaceVariant)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: Text('添加',
                style: TS.body(size: 14, weight: FontWeight.w600, color: C.emerald700)),
          ),
        ],
      ),
    );
    if (value != null && value.isNotEmpty && mounted) {
      setState(() {
        _tags.add((
          C.emerald50,
          C.emerald700,
          value.startsWith('#') ? value : '#$value',
        ));
      });
    }
  }

  void _showReceiptModal() {
    showDialog<void>(
      context: context,
      barrierColor: _kOnSurface.withValues(alpha: 0.6),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCanvas,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题行
              Row(
                children: [
                  const MIcon(MSym.receipt, size: 22, color: _kPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('原始凭证预览',
                        style: TS.body(
                            size: 16, weight: FontWeight.w600, color: _kOnSurface)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _kSurfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: MIcon(MSym.close, size: 18, color: _kOnSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 凭据大图占位
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: _kSurfaceDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: MIcon(MSym.receipt, size: 64, color: _kOnSurfaceVariant),
                ),
              ),
              const SizedBox(height: 8),
              // 底部信息与导出
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('OCR 识别置信度 99.4%',
                      style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kPrimaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MIcon(MSym.download,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('导出原件',
                              style: TS.body(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
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
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏 ----
          GlassHeader.back(
            title: '单笔消费详情',
            actions: [
              const HeaderIconButton(icon: MSym.ios_share),
              const SizedBox(width: 8),
              const HeaderIconButton(icon: MSym.more_horiz),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _amountHeroCard(),
                  const SizedBox(height: 16),
                  _dualTrackCard(),
                  const SizedBox(height: 16),
                  _metaCard(),
                  const SizedBox(height: 16),
                  _receiptCard(),
                  const SizedBox(height: 16),
                  _aaSplitCard(),
                  const SizedBox(height: 16),
                  _bottomActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 1. 金额主卡 =====================
  Widget _amountHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOutlineVariant.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 分类图标 + 已核验角标
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: C.emerald50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: MIcon(MSym.local_cafe, size: 32, color: _kPrimaryContainer),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kCanvas,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), blurRadius: 3),
                    ],
                  ),
                  child: const Center(
                    child: MIcon(MSym.verified,
                        size: 15, color: _kPrimaryContainer, fill: true),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 商户
          Text('星巴克臻选咖啡',
              style: TS.body(size: 12, weight: FontWeight.w500, color: _kOnSurfaceVariant)),
          const SizedBox(height: 4),
          // 主金额（headline-md 22 + display-lg-mobile 32）
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('-¥',
                  style: TS.headline(size: 22, weight: FontWeight.w600, color: _kOnSurface)),
              const SizedBox(width: 2),
              Text('38.00',
                  style: TS.headline(size: 28, weight: FontWeight.w700, color: _kOnSurface)),
            ],
          ),
          const SizedBox(height: 12),
          // 状态徽章
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _pill(
                bg: C.emerald50,
                fg: C.emerald700,
                icon: MSym.check_circle,
                iconFill: true,
                label: 'AI 已自动核对',
              ),
              _pill(
                bg: _kSurfaceContainer,
                fg: _kOnSurfaceVariant,
                icon: MSym.folder_special,
                label: '已归入 5月日常消费 (已剔除AI开支)',
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 时间戳
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MIcon(MSym.schedule, size: 14, color: _kOnSurfaceVariant),
              const SizedBox(width: 4),
              Text('2025年5月18日 星期日 09:42',
                  style: TS.body(size: 12, color: _kOnSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String label,
    bool iconFill = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MIcon(icon, size: 13, color: fg, fill: iconFill),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label,
                style: TS.mono(size: 13, weight: FontWeight.w500, color: fg)),
          ),
        ],
      ),
    );
  }

  // ===================== 2. 双轨记账与自动审计 =====================
  Widget _dualTrackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOutlineVariant.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 卡片标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: _kPrimaryContainer, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('双轨记账与自动审计',
                          style: TS.body(
                              size: 16, weight: FontWeight.w600, color: _kOnSurface)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.emerald50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('双轨智能隔离',
                    style:
                        TS.mono(size: 13, weight: FontWeight.w500, color: C.emerald700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // AI 审计结论横幅
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: C.emerald100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const MIcon(MSym.psychology,
                      size: 18, color: C.emerald800),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('生活日常消费',
                              style: TS.body(
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: _kOnSurface)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: C.emerald50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('隔离生效',
                                style: TS.mono(
                                    size: 13,
                                    weight: FontWeight.w500,
                                    color: _kPrimaryContainer)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '未触发模型训练与算力扣费规则，本笔不计入 GPU/Token 研发账本，完全独立归档。',
                        style: TS.body(size: 12, color: _kOnSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // 预算影响指标
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kSurfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const MIcon(MSym.account_balance_wallet,
                            size: 15, color: _kOnSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('5月生活预算限额扣减',
                            style:
                                TS.body(size: 12, color: _kOnSurfaceVariant)),
                      ],
                    ),
                    Text('-¥38.00',
                        style: TS.mono(
                            size: 13, weight: FontWeight.w600, color: _kOnSurface)),
                  ],
                ),
                const SizedBox(height: 6),
                // 预算进度 42%
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: _kSurfaceDim),
                        FractionallySizedBox(
                          widthFactor: 0.42,
                          child: Container(color: _kPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('当前剩余可支配',
                        style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
                    Text('¥3,512.00 / ¥6,000.00',
                        style: TS.mono(
                            size: 13, weight: FontWeight.w600, color: _kOnSurface)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // 智能标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('支出特征标签',
                  style: TS.body(size: 12, color: _kOnSurfaceVariant)),
              Text('3个已标注',
                  style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (bg, fg, label) in _tags)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(label,
                      style: TS.mono(size: 13, weight: FontWeight.w500, color: fg)),
                ),
              GestureDetector(
                onTap: _addTag,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kSurfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MIcon(MSym.add, size: 14, color: _kOnSurfaceVariant),
                      const SizedBox(width: 2),
                      Text('添加标签',
                          style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
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

  // ===================== 3. 交易流水信息 =====================
  Widget _metaCard() {
    Widget metaLabel(String text) =>
        Text(text, style: TS.body(size: 12, color: _kOnSurfaceVariant));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOutlineVariant.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('交易流水信息',
                  style:
                      TS.body(size: 16, weight: FontWeight.w600, color: _kOnSurface)),
              const MIcon(MSym.receipt_long, size: 18, color: _kOnSurfaceVariant),
            ],
          ),
          const SizedBox(height: 12),
          // 消费商户
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                metaLabel('消费商户'),
                Row(
                  children: [
                    Text('星巴克臻选',
                        style: TS.body(
                            size: 14, weight: FontWeight.w500, color: _kOnSurface)),
                    const SizedBox(width: 4),
                    Text('(科技园店)',
                        style: TS.body(size: 12, color: _kOnSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          // 记账分类
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                metaLabel('记账分类'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kSurfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: C.amber500, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text('餐饮美食',
                          style: TS.body(
                              size: 14, weight: FontWeight.w500, color: _kOnSurface)),
                      const SizedBox(width: 2),
                      Text('›', style: TS.body(size: 14, color: _kOnSurfaceVariant)),
                      const SizedBox(width: 2),
                      Text('咖啡茶饮',
                          style: TS.body(
                              size: 14, weight: FontWeight.w500, color: _kOnSurface)),
                      const SizedBox(width: 4),
                      const MIcon(MSym.expand_more,
                          size: 16, color: _kOnSurfaceVariant),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 支付方式
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                metaLabel('支付方式'),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: C.emerald500,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('微',
                            style: TS.body(
                                size: 10,
                                weight: FontWeight.w700,
                                color: Colors.white,
                                height: 1)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('微信支付',
                        style: TS.body(
                            size: 14, weight: FontWeight.w500, color: _kOnSurface)),
                    const SizedBox(width: 4),
                    Text('(招行储蓄卡 ···· 8820)',
                        style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          // 经办人 / 归属
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                metaLabel('经办人 / 归属'),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: C.indigo100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('晨',
                            style: TS.body(
                                size: 10,
                                weight: FontWeight.w700,
                                color: C.indigo700,
                                height: 1)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('陈晨 (Alex Chen)',
                        style: TS.body(
                            size: 14, weight: FontWeight.w500, color: _kOnSurface)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _kSurfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('个人私账',
                          style:
                              TS.mono(size: 13, color: _kOnSurfaceVariant)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 账单流水号（点击复制）
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                metaLabel('账单流水号'),
                Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(_serial,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _copySerial,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: MIcon(
                          _copied ? MSym.check : MSym.content_copy,
                          size: 16,
                          color: _copied ? _kPrimaryContainer : _kOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 4. 电子凭据与小票存根 =====================
  Widget _receiptCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOutlineVariant.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
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
                    const MIcon(MSym.document_scanner,
                        size: 20, color: _kPrimaryContainer),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('电子凭据与小票存根',
                          style: TS.body(
                              size: 16, weight: FontWeight.w600, color: _kOnSurface)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.emerald50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('已核验上链',
                    style:
                        TS.mono(size: 13, weight: FontWeight.w500, color: C.emerald800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 票据缩略图 + 发票信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // 缩略图（网络票据以占位呈现，右上角放大镜）
                GestureDetector(
                  onTap: _showReceiptModal,
                  child: Container(
                    width: 64,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _kSurfaceDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: MIcon(MSym.receipt, size: 28, color: _kOnSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const MIcon(MSym.check_circle,
                              size: 16, color: C.emerald600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('已开具电子普通发票',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TS.body(
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: _kOnSurface)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('发票代码: 044032400111',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
                      Text('发票号码: 98421034',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.mono(size: 13, color: _kOnSurfaceVariant)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: C.emerald50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('星巴克（中国）有限公司',
                            style: TS.mono(
                                size: 13,
                                weight: FontWeight.w500,
                                color: _kPrimaryContainer)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 次级操作
          Row(
            children: [
              Expanded(child: _receiptAction(MSym.visibility, '查看原票据',
                  onTap: _showReceiptModal)),
              const SizedBox(width: 8),
              Expanded(child: _receiptAction(MSym.photo_camera, '重新拍照识别')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiptAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _kSurfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            MIcon(icon, size: 17, color: _kOnSurface),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TS.body(size: 12, weight: FontWeight.w500, color: _kOnSurface)),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== 5. AA 分摊 =====================
  Widget _aaSplitCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOutlineVariant.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: C.emerald50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: MIcon(MSym.groups, size: 20, color: _kPrimaryContainer),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('发起 AA 分摊计算',
                    style: TS.body(
                        size: 14, weight: FontWeight.w600, color: _kOnSurface)),
                const SizedBox(height: 2),
                Text('生成付款码或向微信好友分摊此账单',
                    style: TS.body(size: 12, color: _kOnSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _kPrimaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('去分摊',
                style: TS.body(size: 12, weight: FontWeight.w500, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===================== 6. 底部操作 =====================
  Widget _bottomActions() {
    return Row(
      children: [
        // 编辑这笔明细
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: _kOutlineVariant.withValues(alpha: 0.4)),
              boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MIcon(MSym.edit_note, size: 18, color: _kOnSurfaceVariant),
                const SizedBox(width: 8),
                Text('编辑这笔明细',
                    style: TS.body(
                        size: 14, weight: FontWeight.w600, color: _kOnSurface)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 删除记账
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: C.rose50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.rose100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MIcon(MSym.delete, size: 18, color: C.rose600),
                const SizedBox(width: 8),
                Text('删除记账',
                    style: TS.body(
                        size: 14, weight: FontWeight.w600, color: C.rose600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
