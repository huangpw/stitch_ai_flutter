import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

// Material 设计系统色（glacial_cyber_finance，HTML tailwind 自定义色板）
const _kOnSurface = Color(0xFF171B26); // on-surface
const _kOnSurfaceVariant = Color(0xFF3C4A42); // on-surface-variant
const _kPrimary = Color(0xFF006C49); // primary
const _kSecondary = Color(0xFF6B38D4); // secondary
const _kTertiary = Color(0xFF00687A); // tertiary
const _kTertiaryContainer = Color(0xFF00B2D0); // tertiary-container
const _kSurfaceContainer = Color(0xFFECEEF3); // surface-container
const _kSurfaceContainerLow = Color(0xFFF2F3F9); // surface-container-low
const _kSurfaceContainerHighest = Color(0xFFDFE2F1); // surface-container-highest

/// 账户资产管理（设计稿 _9）— 净资产总览、四类账户渠道手风琴、
/// 流水智能映射对账开关与底部固定「绑定新卡」操作条。
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  bool _hidden = false; // 隐私护眼：金额模糊
  bool _debitOpen = true;
  bool _walletOpen = true;
  bool _overseasOpen = true;
  bool _investOpen = true;
  bool _autoReconcile = true; // 微信/支付宝流水自动核销
  bool _aiMapCard = true; // AI 算力支出自动映射外币卡

  /// 金额文本（隐私模式下 blur 6px，等价 .masked-asset）。
  Widget _av(String text, TextStyle style) {
    return ImageFiltered(
      enabled: _hidden,
      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Text(text, style: style),
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
            title: '账户资产管理',
            actions: [
              const HeaderIconButton(icon: MSym.more_horiz),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                // ---- 主滚动内容 ----
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const PageContentInsets(bottom: 128),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _netAssetCard(),
                        const SizedBox(height: kCardGap),
                        _debitSection(),
                        const SizedBox(height: kCardGap),
                        _walletSection(),
                        const SizedBox(height: kCardGap),
                        _overseasSection(),
                        const SizedBox(height: kCardGap),
                        _investSection(),
                        const SizedBox(height: kCardGap),
                        _syncMappingCard(),
                      ],
                    ),
                  ),
                ),
                // ---- 底部固定操作条 ----
                Positioned(bottom: 0, left: 0, right: 0, child: _bottomBar()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 1. 净资产总览 =====================
  Widget _netAssetCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kSurfaceContainer.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F171B26),
              blurRadius: 24,
              offset: Offset(0, 4),
              spreadRadius: -4),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 光晕环境背景（blur-3xl 渐变圆，以低透明度圆近似）
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.emerald500.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            left: -48,
            bottom: -48,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.violet500.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题行 + 隐私切换
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const PulsingDot(color: C.emerald500, size: 8),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('总资产估算 (CNY)',
                              style: TS.body(
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: _kOnSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _hidden = !_hidden),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MIcon(
                            _hidden ? MSym.visibility_off : MSym.visibility,
                            size: 16,
                            color: _kOnSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(_hidden ? '金额已隐藏' : '明细可见',
                              style: TS.body(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: _kOnSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 总资产（display-lg 34 w800）
              _av(
                '¥168,900.00',
                TextStyle(
                  fontFamily: F.display,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.2,
                  color: _kOnSurface,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
              const SizedBox(height: 6),
              // 外币折算与环比
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _av('折算 \$23,458.33 USD',
                      TS.mono(size: 13, color: _kOnSurfaceVariant)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: C.emerald500.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MIcon(MSym.trending_up,
                              size: 13, color: _kPrimary),
                          const SizedBox(width: 2),
                          _av('+¥16,050.00',
                              TS.mono(size: 11, weight: FontWeight.w600, color: _kPrimary)),
                          Flexible(
                            child: Text(' 环比增长',
                                style: TS.mono(
                                    size: 11,
                                    weight: FontWeight.w600,
                                    color: _kPrimary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 资金配置构成
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('资金配置构成',
                            style: TS.body(
                                size: 12,
                                weight: FontWeight.w500,
                                color: _kOnSurfaceVariant)),
                        Text('健康稳健',
                            style: TS.mono(
                                size: 11,
                                weight: FontWeight.w600,
                                color: _kPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 44% / 27% / 29% 配置条
                    Container(
                      height: 8,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _kSurfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: C.emerald500,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 27,
                            child: Container(
                              decoration: BoxDecoration(
                                color: C.violet500,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 29,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _kTertiaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _legendDot(C.emerald500, '储蓄 ¥73,650'),
                        _legendDot(C.violet500, '支付 ¥45,250'),
                        _legendDot(_kTertiaryContainer, '理财 ¥50,000'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TS.body(size: 11, color: _kOnSurfaceVariant)),
      ],
    );
  }

  // ===================== 手风琴分组 =====================
  Widget _accSection({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    (String, Color, Color)? badge, // (文本, bg, fg)
    required String sub,
    required String amount,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kSurfaceContainer.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A171B26), blurRadius: 14, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 分组头（点击展开/收起）
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: MIcon(icon, size: 18, color: iconColor)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(title,
                                style: TS.body(
                                    size: 15,
                                    weight: FontWeight.w700,
                                    color: _kOnSurface)),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: badge.$2,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(badge.$1,
                                  style: TS.body(
                                      size: 10,
                                      weight: FontWeight.w600,
                                      color: badge.$3)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(sub,
                          style: TS.body(size: 11, color: _kOnSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _av(amount,
                    TS.mono(size: 13, weight: FontWeight.w700, color: _kOnSurface)),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: expanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const MIcon(MSym.expand_less,
                      size: 20, color: _kOnSurfaceVariant),
                ),
              ],
            ),
          ),
          // 分组内容（手风琴）
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeOutCubic,
            crossFadeState:
                expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: kCardGap),
                Container(height: 1, color: _kSurfaceContainer.withValues(alpha: 0.6)),
                const SizedBox(height: kCardGap),
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: kCardGap),
                  children[i],
                ],
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 账户条目（可含底部附加说明行）。
  Widget _accountTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String name,
    String? tail,
    required (String, Color, Color) tag,
    required String tagSub,
    required String amount,
    required String note,
    Color noteColor = _kOnSurfaceVariant,
    Widget? footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(color: iconBg, shape: BoxShape.circle),
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
                          child: Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.body(
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: _kOnSurface)),
                        ),
                        if (tail != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: _kSurfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(tail,
                                style: TS.mono(
                                    size: 11, color: _kOnSurfaceVariant)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: tag.$2,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(tag.$1,
                              style: TS.body(
                                  size: 10,
                                  weight: FontWeight.w500,
                                  color: tag.$3)),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(tagSub,
                              style: TS.body(
                                  size: 11, color: _kOnSurfaceVariant)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _av(amount,
                      TS.mono(size: 15, weight: FontWeight.w700, color: _kOnSurface)),
                  const SizedBox(height: 2),
                  Text(note,
                      style: TS.body(size: 10, color: noteColor)),
                ],
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 8),
            Container(height: 1, color: _kSurfaceContainer.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            footer,
          ],
        ],
      ),
    );
  }

  // ===================== 分类一：储蓄与银行卡 =====================
  Widget _debitSection() {
    return _accSection(
      icon: MSym.account_balance,
      iconColor: C.emerald500,
      iconBg: C.emerald500.withValues(alpha: 0.10),
      title: '储蓄与银行卡账户',
      sub: '共 2 张常用借记卡',
      amount: '¥73,650.00',
      expanded: _debitOpen,
      onToggle: () => setState(() => _debitOpen = !_debitOpen),
      children: [
        _accountTile(
          icon: MSym.credit_card,
          iconColor: C.rose500,
          iconBg: C.rose500.withValues(alpha: 0.10),
          name: '招商银行工资卡',
          tail: '6821',
          tag: ('默认工资代发', _kPrimary.withValues(alpha: 0.10), _kPrimary),
          tagSub: '活期账户',
          amount: '¥45,200.00',
          note: '可用余额',
        ),
        _accountTile(
          icon: MSym.savings,
          iconColor: C.rose500,
          iconBg: C.rose500.withValues(alpha: 0.10),
          name: '工商银行储蓄卡',
          tail: '8820',
          tag: ('灵通卡', _kSurfaceContainer, _kOnSurfaceVariant),
          tagSub: '备付流动资金',
          amount: '¥28,450.00',
          note: '可用余额',
        ),
      ],
    );
  }

  // ===================== 分类二：移动支付与数字钱包 =====================
  Widget _walletSection() {
    return _accSection(
      icon: MSym.account_balance_wallet,
      iconColor: _kSecondary,
      iconBg: C.violet500.withValues(alpha: 0.10),
      title: '移动支付与数字钱包',
      sub: '微信支付 & 支付宝已连通',
      amount: '¥45,250.00',
      expanded: _walletOpen,
      onToggle: () => setState(() => _walletOpen = !_walletOpen),
      children: [
        _accountTile(
          icon: MSym.chat_bubble,
          iconColor: C.emerald500,
          iconBg: C.emerald500.withValues(alpha: 0.10),
          name: '微信支付零钱通',
          tag: ('随时消费理财', C.emerald500.withValues(alpha: 0.10), _kPrimary),
          tagSub: '年化 1.85%',
          amount: '¥12,850.00',
          note: '零钱已计息',
        ),
        _accountTile(
          icon: MSym.payments,
          iconColor: _kTertiary,
          iconBg: _kTertiaryContainer.withValues(alpha: 0.15),
          name: '支付宝余额宝',
          tag: ('余利宝互转', _kTertiaryContainer.withValues(alpha: 0.20), _kTertiary),
          tagSub: '天弘余额宝',
          amount: '¥32,400.00',
          note: '七日年化 2.02%',
        ),
      ],
    );
  }

  // ===================== 分类三：外币与跨境专卡 =====================
  Widget _overseasSection() {
    return _accSection(
      icon: MSym.public,
      iconColor: _kTertiary,
      iconBg: _kTertiaryContainer.withValues(alpha: 0.20),
      title: '外币与跨境扣费专卡',
      badge: ('AI算力专道', _kSecondary.withValues(alpha: 0.10), _kSecondary),
      sub: '海外 SaaS / AI 订阅优先扣费',
      amount: r'$5,000.00',
      expanded: _overseasOpen,
      onToggle: () => setState(() => _overseasOpen = !_overseasOpen),
      children: [
        _accountTile(
          icon: MSym.smart_toy,
          iconColor: _kSecondary,
          iconBg: _kSecondary.withValues(alpha: 0.10),
          name: '招行双币信用卡 (Visa)',
          tail: '4288',
          tag: ('自动结算', _kSecondary.withValues(alpha: 0.10), _kSecondary),
          tagSub: 'OpenAI / Anthropic Claude API',
          amount: r'$5,000.00',
          note: '可用额度',
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: C.emerald500, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('美元直接记账 · 免外币兑换手续费',
                          style: TS.body(size: 11, color: _kPrimary)),
                    ),
                  ],
                ),
              ),
              Text('账单日 15号',
                  style: TS.mono(size: 11, color: _kOnSurfaceVariant)),
            ],
          ),
        ),
        _accountTile(
          icon: MSym.terminal,
          iconColor: _kTertiary,
          iconBg: _kTertiary.withValues(alpha: 0.10),
          name: '虚拟万事达卡 (Mastercard)',
          tail: '8912',
          tag: ('AI工具订阅', _kTertiaryContainer.withValues(alpha: 0.20), _kTertiary),
          tagSub: 'Midjourney / Cursor / GitHub',
          amount: r'$1,280.00',
          note: '预付预存余额',
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('单笔交易上限 \$500 · 动态CVV守护',
                    style: TS.body(size: 11, color: _kOnSurfaceVariant)),
              ),
              Text('正常代扣中',
                  style: TS.body(size: 11, weight: FontWeight.w500, color: _kPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== 分类四：投资与理财 =====================
  Widget _investSection() {
    return _accSection(
      icon: MSym.trending_up,
      iconColor: C.amber500,
      iconBg: C.amber500.withValues(alpha: 0.10),
      title: '投资与理财账户',
      sub: '稳健型低波理财配置',
      amount: '¥50,000.00',
      expanded: _investOpen,
      onToggle: () => setState(() => _investOpen = !_investOpen),
      children: [
        _accountTile(
          icon: MSym.shield,
          iconColor: _kPrimary,
          iconBg: C.emerald500.withValues(alpha: 0.15),
          name: '中银稳健添利定期理财',
          tag: ('R2 中低风险', C.emerald500.withValues(alpha: 0.10), _kPrimary),
          tagSub: '90天周期 · 预期年化 3.15%',
          amount: '¥50,000.00',
          note: '已累计收益 +¥382.4',
          noteColor: _kPrimary,
        ),
      ],
    );
  }

  // ===================== 流水智能映射与自动对账 =====================
  Widget _syncMappingCard() {
    Widget toggleRow({
      required String title,
      required String sub,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(title,
                      style: TS.body(
                          size: 14, weight: FontWeight.w500, color: _kOnSurface)),
                ),
                const SizedBox(height: 2),
                Text(sub,
                    style: TS.body(
                        size: 12,
                        color: _kOnSurfaceVariant,
                        height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Switch(value: value, onChanged: onChanged),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kSurfaceContainer.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A171B26), blurRadius: 14, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const MIcon(MSym.sync_saved_locally, size: 20, color: _kPrimary),
              const SizedBox(width: 8),
              Text('流水智能映射与自动对账',
                  style:
                      TS.body(size: 15, weight: FontWeight.w700, color: _kOnSurface)),
            ],
          ),
          const SizedBox(height: kCardGap),
          toggleRow(
            title: '微信 / 支付宝流水自动核销',
            sub: '开启后每晚自动同步移动端交易单并归集到对应账目',
            value: _autoReconcile,
            onChanged: (v) => setState(() => _autoReconcile = v),
          ),
          const SizedBox(height: kCardGap),
          Container(height: 1, color: _kSurfaceContainer),
          const SizedBox(height: kCardGap),
          toggleRow(
            title: 'AI 算力支出自动映射外币卡',
            sub: '识别 OpenAI、Claude、Cursor 等账单并自动挂载至外币专卡',
            value: _aiMapCard,
            onChanged: (v) => setState(() => _aiMapCard = v),
          ),
        ],
      ),
    );
  }

  // ===================== 底部固定操作条 =====================
  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: _kSurfaceContainer.withValues(alpha: 0.7)),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const PageContentInsets(),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.emerald500, C.emerald600]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x6610B981),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                    spreadRadius: -4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MIcon(MSym.add_card, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text('+ 绑定新银行卡或支付渠道',
                    style: TS.body(
                        size: 15,
                        weight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// toggle switch（HTML peer 样式：w-11 h-6 轨道 + w-5 h-5 白色滑块）。
class _Switch extends StatelessWidget {
  const _Switch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? C.emerald500 : _kSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 2)],
            ),
          ),
        ),
      ),
    );
  }
}
