import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 设计稿 ai_5 使用但 Tailwind 调色板常量缺失的原值（1:1 还原）：
/// rose-800 与 OpenAI 品牌绿。
const Color _kRose800 = Color(0xFF9F1239);
const Color _kRed700 = Color(0xFFB91C1C);
const Color _kOpenAiGreen = Color(0xFF10A37F);

/// AI 算力月度预算超支预警（设计稿 ai_5）— rose/amber 警示横幅、
/// 三色渐变消耗进度条、模型归因榜单与智能降级防护策略开关。
class AiAlertScreen extends StatefulWidget {
  const AiAlertScreen({super.key});

  @override
  State<AiAlertScreen> createState() => _AiAlertScreenState();
}

class _AiAlertScreenState extends State<AiAlertScreen> {
  bool _hardFuse = true; // 硬顶熔断
  bool _downgrade = true; // 建议降级模型
  bool _pushAlert = true; // 多端推送预警

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（返回 + 标题 + 预警历史）----
          GlassHeader.back(
            title: 'AI月度预算预警',
            actions: const [
              HeaderIconButton(icon: MSym.history),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _alertBanner(),
                  const SizedBox(height: 14),
                  _spendCard(),
                  const SizedBox(height: 14),
                  _attributionSection(),
                  const SizedBox(height: 14),
                  _strategySection(),
                ],
              ),
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  // ===================== 警示横幅 =====================
  Widget _alertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [C.rose50, C.orange50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.rose200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: C.rose500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: MIcon(MSym.warning,
                  size: 20, color: C.rose500, fill: true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: TS.body(size: 12, weight: FontWeight.w700,
                        color: _kRose800, height: 1.3),
                    children: const [
                      TextSpan(text: 'AI算力与订阅月度预算已消耗 '),
                      TextSpan(
                          text: '94.6%',
                          style: TextStyle(
                              fontFamily: F.mono,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: C.rose600)),
                      TextSpan(text: '（接近预设警戒线）'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: TS.body(size: 11, color: C.rose700, height: 1.6),
                    children: const [
                      TextSpan(text: '距离本月结算周期仅剩 '),
                      TextSpan(
                          text: '12 天',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: '，按当前 Token 消耗速率，预计将在 '),
                      TextSpan(
                          text: '3 天后',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: '耗尽本月配额。'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 超支高风险徽标
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: C.rose500,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('超支高风险',
                style: TS.mono(size: 10, weight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===================== 本月支出卡片 =====================
  Widget _spendCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 单行不折行（与设计稿一致）
                        const Text('本月已支出金额',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: C.slate500,
                                leadingDistribution:
                                    TextLeadingDistribution.even)),
                        const SizedBox(width: 6),
                        // 按日均开支预计超额 38%
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.red50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('按日均开支预计超额 38%',
                              style: TS.body(size: 10,
                                  weight: FontWeight.w700,
                                  color: C.rose600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 窄屏（<400px）等比缩放，避免溢出
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('\u0024189.20',
                              style: TS.mono(size: 30, weight: FontWeight.w700,
                                  color: C.slate900)),
                          const SizedBox(width: 8),
                          Text('(折合 ¥1,372.65 CNY)',
                              style: TS.mono(size: 12, weight: FontWeight.w500,
                                  color: C.slate500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 预算上限
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('预算上限',
                      style: TS.body(size: 11, weight: FontWeight.w500,
                          color: C.slate500)),
                  const SizedBox(height: 2),
                  Text('\u0024200.00 USD',
                      style: TS.mono(size: 14, weight: FontWeight.w700,
                          color: C.slate700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 三色渐变进度条（94.6%）
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 14,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: C.slate100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.946,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [C.emerald500, C.amber500, C.rose500]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: C.emerald500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('剩余可用: \u002410.80 USD',
                          style: TS.mono(size: 12, weight: FontWeight.w600,
                              color: C.emerald600)),
                    ],
                  ),
                  Text('94.6% 已占用',
                      style: TS.mono(size: 12, weight: FontWeight.w700,
                          color: C.rose600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 近期算力激增模型归因 =====================
  Widget _attributionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('近期算力激增模型归因 (近7天)',
                    style: TS.body(size: 12, weight: FontWeight.w700,
                        color: C.slate600, height: 1.2)),
              ),
              const SizedBox(width: 8),
              Text('按消耗降序',
                  style: TS.body(size: 11, color: C.slate500)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.slate100),
          ),
          child: Column(
            children: [
              _modelRow(
                icon: MSym.smart_toy,
                accent: _kOpenAiGreen,
                name: 'OpenAI API (GPT-4o)',
                tag: 'API 批量推理调用激增',
                tagBg: C.red100,
                tagColor: _kRed700,
                sub: '调用频次环比 +42% · 自动化分析脚本',
                amount: '\u002486.50',
                share: '占比 45.7%',
              ),
              _divider(),
              _modelRow(
                icon: MSym.psychology,
                accent: C.amber600,
                name: 'Claude 3.7 Sonnet (Anthropic)',
                tag: 'Cursor Agent 高频补全',
                tagBg: C.amber100,
                tagColor: C.amber700,
                sub: '长代码上下文索引缓存命中低',
                amount: '\u002462.00',
                share: '占比 32.8%',
              ),
              _divider(),
              _modelRow(
                icon: MSym.palette,
                accent: C.indigo500,
                name: 'Midjourney v6 订阅',
                tag: '固定月租',
                tagBg: C.slate100,
                tagColor: C.slate600,
                sub: '标准按月订阅扣费',
                amount: '\u002430.00',
                share: '占比 15.9%',
              ),
              _divider(),
              _modelRow(
                icon: MSym.terminal,
                accent: C.sky600,
                name: 'DeepSeek V3 / R1',
                tag: '本地客户端并发',
                tagBg: C.emerald50,
                tagColor: C.emerald700,
                sub: '高性价比批处理任务',
                amount: '\u002410.70',
                share: '占比 5.6%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(height: 1, color: C.slate100);

  Widget _modelRow({
    required IconData icon,
    required Color accent,
    required String name,
    required String tag,
    required Color tagBg,
    required Color tagColor,
    required String sub,
    required String amount,
    required String share,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: MIcon(icon, size: 19, color: accent)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                  children: [
                    Text(name,
                        maxLines: 1,
                        style: TS.body(size: 12, weight: FontWeight.w700,
                            color: C.slate900)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tag,
                          style: TS.body(size: 10, weight: FontWeight.w600,
                              color: tagColor)),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 2),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.mono(size: 11, weight: FontWeight.w500,
                        color: C.slate500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TS.mono(size: 12, weight: FontWeight.w700,
                      color: C.slate900)),
              const SizedBox(height: 2),
              Text(share,
                  style: TS.mono(size: 10, weight: FontWeight.w500,
                      color: C.slate500)),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 智能降级与防护策略控制 =====================
  Widget _strategySection() {
    Widget strategy({
      required IconData icon,
      required String title,
      required String sub,
      required bool on,
      required ValueChanged<bool> onChanged,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: C.emerald50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: MIcon(icon, size: 19, color: C.emerald500)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TS.body(size: 12, weight: FontWeight.w600,
                          color: C.slate900, height: 1.4)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TS.body(size: 11, color: C.slate500)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _AlertToggle(on: on, onChanged: onChanged),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('智能降级与防护策略控制',
              style: TS.body(size: 12, weight: FontWeight.w700,
                  color: C.slate600, height: 1.2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.slate100),
          ),
          child: Column(
            children: [
              strategy(
                icon: MSym.shield,
                title: '达到 100% 时自动暂停非必要 API 请求 (硬顶熔断)',
                sub: '防范天价账单，优先保障核心业务不中断',
                on: _hardFuse,
                onChanged: (v) => setState(() => _hardFuse = v),
              ),
              _divider(),
              strategy(
                icon: MSym.swap_calls,
                title: '建议降级模型（优先使用 DeepSeek / GPT-4o-mini）',
                sub: '低复杂度需求自动切换轻量模型节约 85% 成本',
                on: _downgrade,
                onChanged: (v) => setState(() => _downgrade = v),
              ),
              _divider(),
              strategy(
                icon: MSym.notifications_active,
                title: '邮件与微信服务号同步推送预警',
                sub: '消耗越过 90% 及 98% 节点即时多端推送',
                on: _pushAlert,
                onChanged: (v) => setState(() => _pushAlert = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== 底部吸底操作条 =====================
  Widget _footer() {
    return Container(
      decoration: BoxDecoration(
        color: kCanvas,
        border: Border(
          top: BorderSide(color: C.slate200.withValues(alpha: 0.8)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 调整本月预算上限（保持静态）
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: C.emerald500,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: C.emerald500.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MIcon(MSym.tune, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text('调整本月预算上限',
                          style: TextStyle(
                              fontFamily: F.sans,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 保持当前额度，开启智能限流（保持静态）
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: C.slate100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('保持当前额度，开启智能限流',
                      style: TS.body(size: 12, weight: FontWeight.w500,
                          color: C.slate600)),
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

/// 策略开关（w-11 h-6，slate-300 ↔ emerald-500）。
class _AlertToggle extends StatelessWidget {
  const _AlertToggle({required this.on, required this.onChanged});

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: C.slate300, width: on ? 0 : 1),
            ),
          ),
        ),
      ),
    );
  }
}
