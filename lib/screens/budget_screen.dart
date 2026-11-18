import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

// Material 设计系统色（HTML tailwind 自定义色板）
const _kOnSurface = Color(0xFF171B26); // on-surface
const _kOnSurfaceVariant = Color(0xFF3C4A42); // on-surface-variant
const _kPrimary = Color(0xFF006C49); // primary
const _kAuroraGreen = C.emerald500; // aurora-green #10b981
const _kCyberViolet = C.violet500; // cyber-violet #8b5cf6
const _kCriticalRose = C.rose500; // critical-rose #f43f5e
const _kSecondary = Color(0xFF6B38D4); // secondary
const _kError = Color(0xFFBA1A1A); // error
const _kSurfaceContainer = Color(0xFFECEEF3); // surface-container
const _kSurfaceContainerHigh = Color(0xFFE7E8EE); // surface-container-high
const _kSurfaceContainerLow = Color(0xFFF2F3F9); // surface-container-low

/// 预算控制中心（设计稿 _10）— 生活日常消费 / AI 算力与模型订阅双轨预算，
/// 快速设定月预算、分类细分、模型配额池与熔断风控规则。
/// 独立预算设置页面，由个人中心的「预算控制」入口打开。
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _track = 0; // 0=生活日常消费 1=AI算力与模型订阅
  int _preset = 1; // 快速设定月预算选中项（默认 ¥12,000）
  bool _alert80 = true; // 80% 超支预警
  bool _circuitBreaker = true; // 单日超 $20 自动熔断

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（Tab 页：返回键保留视觉 + 预算分析入口）----
          GlassHeader.back(
            title: '预算控制中心',
            actions: [const HeaderIconButton(icon: MSym.bar_chart)],
          ),
          Expanded(
            child: Stack(
              children: [
                // ---- 内容延伸到悬浮导航后方，滚动末尾留出保存条和导航空间 ----
                Positioned.fill(
                  child: ScreenBody(
                    child: SingleChildScrollView(
                      padding: PageContentInsets(
                        bottom: MediaQuery.paddingOf(context).bottom + 84,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _trackTabs(),
                          const SizedBox(height: kCardGap),
                          if (_track == 0) ..._lifestyleTrack(),
                          if (_track == 1) ..._computeTrack(),
                        ],
                      ),
                    ),
                  ),
                ),
                // ---- 底部固定保存条 ----
                Positioned(
                  bottom: MediaQuery.paddingOf(context).bottom,
                  left: 0,
                  right: 0,
                  child: _saveBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 双轨分段 Tab =====================
  Widget _trackTabs() {
    Widget tab(int i, IconData icon, Color iconColor, String label) {
      final active = _track == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _track = i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: active
                  ? const [BoxShadow(color: Color(0x14000000), blurRadius: 3)]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MIcon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(
                      size: 13,
                      weight: FontWeight.w500,
                      color: active ? _kOnSurface : _kOnSurfaceVariant,
                    ),
                  ),
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
        color: _kSurfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          tab(0, MSym.shopping_bag, _kAuroraGreen, '生活日常消费'),
          tab(1, MSym.memory, _kCyberViolet, 'AI算力与模型订阅'),
        ],
      ),
    );
  }

  // ===================== 轨道总览卡 =====================
  Widget _overviewCard({
    required Color dotColor,
    required String periodLabel,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required String unit,
    required String usedTitle,
    required String usedNumber,
    required String usedSuffix,
    required String totalTitle,
    required String totalValue,
    required double progress,
    required Color progressColor,
    required String remainLabel,
    required String remainValue,
    required Color remainValueColor,
    required String percentLabel,
    required String percentValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x08000000)),
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
                    PulsingDot(color: dotColor, size: 8),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        periodLabel,
                        style: TS.body(
                          size: 12,
                          weight: FontWeight.w500,
                          color: _kOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TS.mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 已消耗 / 总预算
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usedTitle,
                    style: TS.body(size: 12, color: _kOnSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        unit,
                        style: TS.mono(
                          size: 12,
                          weight: FontWeight.w500,
                          color: _kOnSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        usedNumber,
                        style: TS.headline(
                          size: 30,
                          weight: FontWeight.w700,
                          color: _kOnSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        usedSuffix,
                        style: TS.mono(size: 14, color: _kOnSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalTitle,
                    style: TS.body(size: 12, color: _kOnSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalValue,
                    style: TS.mono(
                      size: 14,
                      weight: FontWeight.w600,
                      color: _kOnSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 总进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(color: _kSurfaceContainer),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: progressColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 剩余 / 进度
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kSurfaceContainer)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: _kSurfaceContainer),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          remainLabel,
                          style: TS.body(size: 12, color: _kOnSurfaceVariant),
                        ),
                        Text(
                          remainValue,
                          style: TS.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: remainValueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          percentLabel,
                          style: TS.body(size: 12, color: _kOnSurfaceVariant),
                        ),
                        Text(
                          percentValue,
                          style: TS.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: _kOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 生活日常消费轨道 =====================
  List<Widget> _lifestyleTrack() {
    return [
      _overviewCard(
        dotColor: _kAuroraGreen,
        periodLabel: '3月生活消费周期',
        badge: '健康节奏良好',
        badgeColor: _kPrimary,
        badgeBg: _kPrimary.withValues(alpha: 0.10),
        unit: '¥',
        usedTitle: '本月已消耗额度',
        usedNumber: '8,450',
        usedSuffix: '.00',
        totalTitle: '月度总预算',
        totalValue: '¥12,000.00',
        progress: 0.704,
        progressColor: _kAuroraGreen,
        remainLabel: '剩余可用额度',
        remainValue: '¥3,550.00',
        remainValueColor: _kAuroraGreen,
        percentLabel: '总消耗进度',
        percentValue: '70.4%',
      ),
      const SizedBox(height: kCardGap),
      _quickBudgetCard(),
      const SizedBox(height: kCardGap),
      _categoryBreakdownCard(),
    ];
  }

  // 快速设定月预算
  Widget _quickBudgetCard() {
    const presets = ['¥8,000', '¥12,000', '¥15,000', '¥20,000'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x08000000)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '快速设定月预算',
                style: TS.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
              Row(
                children: [
                  const MIcon(MSym.edit, size: 14, color: _kPrimary),
                  const SizedBox(width: 2),
                  Text(
                    '自定义',
                    style: TS.body(
                      size: 12,
                      weight: FontWeight.w500,
                      color: _kPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < presets.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _preset = i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: i == _preset
                            ? _kAuroraGreen.withValues(alpha: 0.10)
                            : _kSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: i == _preset
                              ? _kAuroraGreen
                              : _kSurfaceContainer,
                          width: i == _preset ? 2 : 1,
                        ),
                        boxShadow: i == _preset
                            ? const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 3,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        presets[i],
                        textAlign: TextAlign.center,
                        style: TS.mono(
                          size: 12,
                          weight: i == _preset
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: i == _preset ? _kPrimary : _kOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 分类预算细分
  Widget _categoryBreakdownCard() {
    Widget row({
      required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String label,
      (String, Color, Color)? extraBadge, // 满额提示 (文本, bg, fg)
      required String used,
      Color usedColor = _kOnSurface,
      required String total,
      required double progress,
      required Color progressColor,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: MIcon(icon, size: 16, color: iconColor)),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TS.body(
                  size: 12,
                  weight: FontWeight.w500,
                  color: _kOnSurface,
                ),
              ),
              if (extraBadge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: extraBadge.$2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    extraBadge.$1,
                    style: TS.mono(size: 10, color: extraBadge.$3),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                used,
                style: TS.mono(
                  size: 12,
                  weight: FontWeight.w600,
                  color: usedColor,
                ),
              ),
              Text(
                ' / $total',
                style: TS.mono(size: 12, color: _kOnSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: _kSurfaceContainer),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: progressColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x08000000)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '分类预算细分',
                style: TS.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
              Text('共3项', style: TS.body(size: 11, color: _kOnSurfaceVariant)),
            ],
          ),
          const SizedBox(height: kCardGap),
          row(
            icon: MSym.restaurant,
            iconColor: C.orange600,
            iconBg: C.orange500.withValues(alpha: 0.10),
            label: '餐饮美食',
            used: '¥3,240',
            total: '¥4,500',
            progress: 0.72,
            progressColor: C.orange500,
          ),
          const SizedBox(height: kCardGap),
          row(
            icon: MSym.home,
            iconColor: C.blue600,
            iconBg: C.blue500.withValues(alpha: 0.10),
            label: '居住房租',
            extraBadge: ('满额 100%', _kError.withValues(alpha: 0.10), _kError),
            used: '¥3,500',
            usedColor: _kCriticalRose,
            total: '¥3,500',
            progress: 1.0,
            progressColor: _kCriticalRose,
          ),
          const SizedBox(height: kCardGap),
          row(
            icon: MSym.directions_subway,
            iconColor: C.emerald600,
            iconBg: C.emerald500.withValues(alpha: 0.10),
            label: '日用通勤',
            used: '¥1,710',
            total: '¥2,500',
            progress: 0.684,
            progressColor: _kAuroraGreen,
          ),
        ],
      ),
    );
  }

  // ===================== AI 算力与模型订阅轨道 =====================
  List<Widget> _computeTrack() {
    return [
      _overviewCard(
        dotColor: _kCyberViolet,
        periodLabel: '算力与模型用量周期',
        badge: '折合 ¥1,450.00',
        badgeColor: _kCyberViolet,
        badgeBg: _kCyberViolet.withValues(alpha: 0.10),
        unit: r'$',
        usedTitle: '本月已消耗算力',
        usedNumber: '148.50',
        usedSuffix: 'USD',
        totalTitle: '月度算力封顶',
        totalValue: r'$200.00 USD',
        progress: 0.742,
        progressColor: _kCyberViolet,
        remainLabel: '剩余额度池',
        remainValue: r'$51.50 USD',
        remainValueColor: _kCyberViolet,
        percentLabel: '消耗占比',
        percentValue: '74.2%',
      ),
      const SizedBox(height: kCardGap),
      _modelQuotaCard(),
      const SizedBox(height: kCardGap),
      _riskControlCard(),
    ];
  }

  // 模型额度配额拆分
  Widget _modelQuotaCard() {
    Widget pool({
      required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String name,
      required String spec,
      required String used,
      Color usedColor = _kOnSurface,
      required String total,
      required double progress,
      required Color progressColor,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: MIcon(icon, size: 16, color: iconColor)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TS.body(
                        size: 12,
                        weight: FontWeight.w500,
                        color: _kOnSurface,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      spec,
                      style: TS.mono(size: 10, color: _kOnSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  style: TS.mono(size: 12, color: _kOnSurfaceVariant),
                  children: [
                    TextSpan(
                      text: used,
                      style: TS.mono(
                        size: 12,
                        weight: FontWeight.w600,
                        color: usedColor,
                      ),
                    ),
                    TextSpan(text: ' / $total'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: _kSurfaceContainer),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: progressColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x08000000)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '模型额度配额拆分',
                style: TS.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
              Text('共3个池', style: TS.body(size: 11, color: _kOnSurfaceVariant)),
            ],
          ),
          const SizedBox(height: kCardGap),
          pool(
            icon: MSym.api,
            iconColor: C.emerald600,
            iconBg: C.emerald500.withValues(alpha: 0.10),
            name: 'OpenAI API 消耗池',
            spec: 'GPT-4o / O3-mini',
            used: r'$38.20',
            total: r'$50.00',
            progress: 0.764,
            progressColor: _kAuroraGreen,
          ),
          const SizedBox(height: kCardGap),
          pool(
            icon: MSym.psychology,
            iconColor: _kCyberViolet,
            iconBg: C.purple500.withValues(alpha: 0.10),
            name: 'Claude 模型额度',
            spec: 'Claude 3.7 Sonnet API',
            used: r'$42.30',
            usedColor: _kCyberViolet,
            total: r'$50.00',
            progress: 0.846,
            progressColor: _kCyberViolet,
          ),
          const SizedBox(height: kCardGap),
          pool(
            icon: MSym.draw,
            iconColor: _kSecondary,
            iconBg: C.indigo500.withValues(alpha: 0.10),
            name: '固定工具订阅池',
            spec: 'Midjourney + Cursor Pro',
            used: r'$68.00',
            total: r'$100.00',
            progress: 0.68,
            progressColor: _kSecondary,
          ),
        ],
      ),
    );
  }

  // 智能风控与熔断规则
  Widget _riskControlCard() {
    Widget rule({
      required String title,
      required String desc,
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
                  child: Text(
                    title,
                    style: TS.body(
                      size: 12,
                      weight: FontWeight.w500,
                      color: _kOnSurface,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc, style: TS.body(size: 11, color: _kOnSurfaceVariant)),
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
        border: Border.all(color: const Color(0x08000000)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '智能风控与熔断规则',
                style: TS.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '防御中',
                  style: TS.mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: _kPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          rule(
            title: '80% 超支预警提醒',
            desc: '当任一模型池消耗超 80% 时立即发送即时推送与短信通知',
            value: _alert80,
            onChanged: (v) => setState(() => _alert80 = v),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _kSurfaceContainer),
          const SizedBox(height: 12),
          rule(
            title: '单日消耗超 \$20 自动熔断限流',
            desc: '触发后自动暂停高单价模型接口，降级至低成本模型保障可用性',
            value: _circuitBreaker,
            onChanged: (v) => setState(() => _circuitBreaker = v),
          ),
        ],
      ),
    );
  }

  // ===================== 底部固定保存条 =====================
  Widget _saveBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCanvas.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: _kSurfaceContainer.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const PageContentInsets(),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _kAuroraGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D10B981),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MIcon(MSym.check_circle, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '保存预算设定与风控规则',
                  style: TS.body(
                    size: 15,
                    weight: FontWeight.w500,
                    color: Colors.white,
                    height: 1,
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

/// toggle switch（HTML `w-11 h-6` 轨道 + w-5 h-5 滑块，开=aurora-green 关=surface-container-high）。
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
          color: value ? _kAuroraGreen : _kSurfaceContainerHigh,
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
