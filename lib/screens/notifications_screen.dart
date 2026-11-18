import 'dart:async';

import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

// ---- 设计稿 _5 的 Material 语义色令牌（palette.dart 中无对应 Tailwind 值）----
const _kOnSurface = Color(0xFF191C20); // on-surface
const _kOnSurfaceVariant = Color(0xFF3C4A42); // on-surface-variant
const _kOutline = Color(0xFF6C7A71); // outline
const _kSurfaceLow = Color(0xFFF2F3F9); // surface-container-low
const _kSurfaceContainer = Color(0xFFECEEF3); // surface-container
const _kSurfaceHigh = Color(0xFFE7E8EE); // surface-container-high
const _kSurfaceHighest = Color(0xFFE1E2E8); // surface-container-highest
const _kPrimary = Color(0xFF006C49); // primary
const _kPrimaryFixed = Color(0xFF6FFBBE); // primary-fixed
const _kOnPrimaryFixed = Color(0xFF002113); // on-primary-fixed
const _kPrimaryFixedDim = Color(0xFF4EDEA3); // primary-fixed-dim
const _kSecondary = Color(0xFF6B38D4); // secondary
const _kSecondaryFixed = Color(0xFFE9DDFF); // secondary-fixed
const _kOnSecondaryFixed = Color(0xFF23005C); // on-secondary-fixed
const _kErrorContainer = Color(0xFFFFDAD6); // error-container
const _kOnErrorContainer = Color(0xFF93000A); // on-error-container
const _kInverseSurface = Color(0xFF2E3135); // inverse-surface
const _kInverseOnSurface = Color(0xFFEFF0F6); // inverse-on-surface

/// 消息通知（设计稿 _5）— 分类过滤 Tab、置顶算力余额预警卡、
/// 按日期分组的通知流、通知设置入口与底部吐司反馈。
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tab = 0; // 0=全部 1=AI算力预警 2=AA与转账 3=系统账单
  bool _badgesVisible = true; // 全部已读后徽标移除
  int _rechargeState = 0; // 0=待充值 1=调用支付中 2=已提交
  bool _showToast = false;
  String _toastMsg = '通知状态已更新';
  Timer? _toastTimer;

  static const _tabCategories = ['all', 'ai', 'transfer', 'system'];
  static const _tabs = <(String, Color?, Color, Color, String)>[
    // label, 前置圆点色, 徽标底色, 徽标前景色, 徽标文本
    ('全部通知', null, _kSurfaceHighest, _kOnSurfaceVariant, '3'),
    ('AI算力预警', C.violet500, _kSecondaryFixed, _kOnSecondaryFixed, '1'),
    ('AA与转账', C.emerald500, _kPrimaryFixed, _kOnPrimaryFixed, '1'),
    ('系统账单', C.amber500, _kSurfaceHigh, _kOnSurfaceVariant, '1'),
  ];

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  // ---- 底部吐司 ----
  void _toast(String msg) {
    _toastTimer?.cancel();
    setState(() {
      _toastMsg = msg;
      _showToast = true;
    });
    _toastTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  // ---- 全部已读 ----
  void _markAllRead() {
    setState(() => _badgesVisible = false);
    _toast('所有未读流水已标为已读');
  }

  // ---- 一键自动充值微交互 ----
  void _recharge() {
    if (_rechargeState != 0) return;
    setState(() => _rechargeState = 1);
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _rechargeState = 2);
      _toast('已向 OpenAI 机构账户成功注资 \$50.00 USD');
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = _tabCategories[_tab];
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（返回 + 标题）----
          GlassHeader.back(title: '消息通知'),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _filterSection(),
                        const SizedBox(height: 8),
                        _pinnedAlert(),
                        const SizedBox(height: 14),
                        _NotifGroup(
                          header: 'Today · 今天',
                          meta: '2 条新事件',
                          children: [
                            if (cat == 'all' || cat == 'transfer')
                              _itemTransfer(),
                            if (cat == 'all' || cat == 'ai') _itemAiRenewal(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _NotifGroup(
                          header: 'Yesterday · 昨天',
                          meta: '2 条归档',
                          children: [
                            if (cat == 'all' || cat == 'system') _itemBudget(),
                            if (cat == 'all' || cat == 'system') _itemSync(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _settingsEntry(),
                      ],
                    ),
                  ),
                ),
                // ---- 底部吐司 ----
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                    child: IgnorePointer(
                      ignoring: !_showToast,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: _showToast ? Offset.zero : const Offset(0, 1.5),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _showToast ? 1 : 0,
                          child: _toastWidget(),
                        ),
                      ),
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

  // ---- 过滤与全部已读 ----
  Widget _filterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PulsingDot(color: C.emerald500, size: 8),
            const SizedBox(width: 8),
            Text('消息通知',
                style:
                    TS.headline(size: 16, weight: FontWeight.w700, color: _kOnSurface)),
            const Spacer(),
            GestureDetector(
              onTap: _markAllRead,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _kSurfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MIcon(MSym.done_all, size: 16, color: _kPrimary),
                    const SizedBox(width: 6),
                    Text('全部已读',
                        style: TS.mono(size: 11, color: _kOnSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 分类过滤 Tab（横向滚动）
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _tabBtn(i),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBtn(int i) {
    final active = _tab == i;
    final (label, dot, badgeBg, badgeFg, badgeText) = _tabs[i];
    return GestureDetector(
      onTap: () => setState(() => _tab = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : _kSurfaceContainer,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 3)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TS.body(
                    size: 12,
                    weight: FontWeight.w500,
                    color: active ? _kOnSurface : _kOnSurfaceVariant)),
            if (_badgesVisible) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(badgeText,
                    style: TS.mono(size: 11, color: badgeFg)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- 置顶算力余额预警卡（顶部 2.5px 渐变描边条）----
  Widget _pinnedAlert() {
    return Stack(
      children: [
        _pinnedAlertBody(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 2.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFDA4AF), C.violet400]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pinnedAlertBody() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 卡片头
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kSecondaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: MIcon(MSym.memory,
                          size: 24, color: _kSecondary, fill: true),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: PulsingDot(color: C.rose500, size: 12, ring: true),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OpenAI API 余额不足预警',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TS.headline(
                            size: 15, weight: FontWeight.w600, color: _kOnSurface)),
                    const SizedBox(height: 2),
                    Text('10分钟前 · 智能流实时巡检',
                        style: TS.mono(size: 11, color: _kOutline)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kErrorContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MIcon(MSym.emergency,
                        size: 13, color: _kOnErrorContainer),
                    const SizedBox(width: 4),
                    Text('额度临界 · Tier-4',
                        style: TS.mono(size: 11, color: _kOnErrorContainer)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 描述正文
          Text.rich(
            TextSpan(
              style:
                  TS.body(size: 14, color: _kOnSurfaceVariant, height: 1.625),
              children: const [
                TextSpan(text: '当前绑定的 OpenAI Organization 预存额度仅剩 '),
                TextSpan(
                    text: '\$4.20 USD',
                    style: TextStyle(
                        fontFamily: F.mono,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: C.rose500)),
                TextSpan(text: '（已触及 '),
                TextSpan(
                    text: '\$15.00',
                    style: TextStyle(
                        fontFamily: F.mono,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kOnSurface)),
                TextSpan(text: ' 安全水位阈值），高频推理任务预计在 24 小时内中断。'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 迷你遥测水位计
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kSurfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('剩余可用配额水位 (28.0%)',
                        style: TS.mono(size: 11, color: _kOnSurfaceVariant)),
                    Text('\$4.20 / \$15.00 Threshold',
                        style: TS.mono(
                            size: 11, weight: FontWeight.w700, color: C.rose500)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      children: [
                        Container(color: _kSurfaceHighest),
                        FractionallySizedBox(
                          widthFactor: 0.28,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [C.violet500, C.rose500]),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 交互 CTA
          Row(
            children: [
              Expanded(child: _rechargeBtn()),
              const SizedBox(width: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kSurfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('查看消耗流',
                          style: TS.body(
                              size: 12, color: _kOnSurfaceVariant)),
                      const MIcon(MSym.chevron_right,
                          size: 16, color: _kOnSurfaceVariant),
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

  Widget _rechargeBtn() {
    final done = _rechargeState == 2;
    final loading = _rechargeState == 1;
    return GestureDetector(
      onTap: _recharge,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 44,
        decoration: BoxDecoration(
          color: done ? _kSurfaceHighest : C.emerald500,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 3),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: Colors.white),
              )
            else
              MIcon(done ? MSym.done : MSym.bolt,
                  size: 18, color: done ? _kOnSurface : Colors.white),
            const SizedBox(width: 8),
            Text(
              loading
                  ? '正在调用 Apple Pay...'
                  : (done ? '充值已提交 \$50.00' : '立即自动充值 (\$50)'),
              style: TS.headline(
                  size: 14,
                  weight: FontWeight.w600,
                  color: done ? _kOnSurface : Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ---- 通知项 1：AA 分摊还款 ----
  Widget _itemTransfer() {
    return _NotificationCard(
      category: 'transfer',
      icon: MSym.call_split,
      tileColor: _kPrimaryFixed,
      iconColor: _kPrimary,
      title: '周末朋友聚餐AA分摊 - 收到还款',
      time: '11:25',
      body: Text.rich(
        TextSpan(
          style: TS.body(size: 14, color: _kOnSurfaceVariant, height: 1.4),
          children: const [
            TextSpan(
                text: '李浩 (Leo)',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: _kOnSurface)),
            TextSpan(text: ' 已通过微信转账结清他的分摊份额 '),
            TextSpan(
                text: '¥48.33',
                style: TextStyle(
                    fontFamily: F.mono,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kPrimary)),
            TextSpan(text: ' 元，系统已完成流水对账并直接划入个人主资产池。'),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _pill(MSym.check_circle, '已自动核销入账', _kPrimaryFixed, _kOnPrimaryFixed),
          Text('流水单号 #8921',
              style: TS.mono(size: 11, color: _kOnSurfaceVariant)),
        ],
      ),
    );
  }

  // ---- 通知项 2：订阅扣费成功 ----
  Widget _itemAiRenewal() {
    return _NotificationCard(
      category: 'ai',
      icon: MSym.autorenew,
      tileColor: _kSecondaryFixed,
      iconColor: _kSecondary,
      title: 'Claude Pro 月度订阅扣费成功',
      time: '08:00',
      body: Text.rich(
        TextSpan(
          style: TS.body(size: 14, color: _kOnSurfaceVariant, height: 1.4),
          children: const [
            TextSpan(text: '已通过招商银行双币信用卡 (尾号 4390) 自动划扣 '),
            TextSpan(
                text: '\$20.00 USD',
                style: TextStyle(
                    fontFamily: F.mono,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurface)),
            TextSpan(text: '（折合 ¥144.00 CNY），已自动归档至「研发-模型费用」账本分类。'),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const MIcon(MSym.receipt_long, size: 16, color: _kSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('查看电子发票与计费账单',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 12, color: _kSecondary)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('汇率 7.2000', style: TS.mono(size: 11, color: _kOutline)),
        ],
      ),
    );
  }

  // ---- 通知项 3：预算使用 70% ----
  Widget _itemBudget() {
    return _NotificationCard(
      category: 'system',
      icon: MSym.security_update_warning,
      tileColor: _kSurfaceHigh,
      iconColor: C.amber500,
      fill: true,
      title: '5月日常消费预算使用达 70%',
      time: '昨天 18:30',
      body: Text.rich(
        TextSpan(
          style: TS.body(size: 14, color: _kOnSurfaceVariant, height: 1.4),
          children: const [
            TextSpan(text: '本月日常消费累计已达 '),
            TextSpan(
                text: '¥8,450.00',
                style: TextStyle(
                    fontFamily: F.mono,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurface)),
            TextSpan(
                text: '，剩余可用生活额度 ¥3,550.00。AI 研发算力支出已做物理隔离，当前日均开支节奏处于平稳健康区间。'),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      const BoxDecoration(color: C.amber500, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('健康预警 · 暂无需收紧',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.mono(size: 11, color: _kOnSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('距离结算还有 12 天', style: TS.mono(size: 11, color: _kOutline)),
        ],
      ),
    );
  }

  // ---- 通知项 4：云端备份完成 ----
  Widget _itemSync() {
    return _NotificationCard(
      category: 'system',
      icon: MSym.cloud_done,
      tileColor: _kSurfaceContainer,
      iconColor: _kPrimary,
      title: 'WebDAV 财务账本云端自动备份完成',
      time: '昨天 14:32',
      body: Text(
        '增量同步已就绪 (+42 KB)，Secure Enclave 硬件加密层已完成签名验证，数据指纹 SHA-256 校验比对一致。',
        style: TS.body(size: 14, color: _kOnSurfaceVariant, height: 1.4),
      ),
      footer: Row(
        children: [
          Expanded(
            child: Text('sha256: 9e3a7b...41cf89',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TS.mono(size: 11, color: _kOutline)),
          ),
          const SizedBox(width: 8),
          Text('端到端加密正常',
              style: TS.mono(size: 11, weight: FontWeight.w500, color: _kPrimary)),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MIcon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TS.mono(size: 11, color: fg)),
        ],
      ),
    );
  }

  // ---- 通知设置入口 ----
  Widget _settingsEntry() {
    return GestureDetector(
      onTap: () => _toast('已进入推送策略与阈值偏好面板'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kSurfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x0D000000), blurRadius: 3),
                ],
              ),
              child: const Center(
                  child: MIcon(MSym.tune, size: 20, color: _kOnSurface)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('自定义通知与推送规则',
                      style: TS.headline(
                          size: 15, weight: FontWeight.w600, color: _kOnSurface)),
                  const SizedBox(height: 2),
                  Text('免打扰时段 · 算力触发阈值 · 预算警报偏好',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 12, color: _kOnSurfaceVariant)),
                ],
              ),
            ),
            const MIcon(MSym.chevron_right, size: 20, color: _kOutline),
          ],
        ),
      ),
    );
  }

  Widget _toastWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kInverseSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MIcon(MSym.verified, size: 20, color: _kPrimaryFixedDim),
          const SizedBox(width: 12),
          Flexible(
            child: Text(_toastMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TS.body(size: 14, color: _kInverseOnSurface)),
          ),
        ],
      ),
    );
  }
}

/// 日期分组通知流。
class _NotifGroup extends StatelessWidget {
  const _NotifGroup({
    required this.header,
    required this.meta,
    required this.children,
  });

  final String header;
  final String meta;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final list = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(header.toUpperCase(),
                style: TS.mono(
                    size: 11, weight: FontWeight.w600, color: _kOutline, letterSpacing: 0.5)),
            Text(meta, style: TS.mono(size: 11, color: _kOutline)),
          ],
        ),
      ),
    ];
    if (children.isNotEmpty) {
      list.add(const SizedBox(height: 14));
      for (var i = 0; i < children.length; i++) {
        list.add(children[i]);
        if (i < children.length - 1) list.add(const SizedBox(height: 14));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: list,
    );
  }
}

/// 单条通知卡片。
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.category,
    required this.icon,
    required this.tileColor,
    required this.iconColor,
    this.fill = false,
    required this.title,
    required this.time,
    required this.body,
    required this.footer,
  });

  final String category;
  final IconData icon;
  final Color tileColor;
  final Color iconColor;
  final bool fill;
  final String title;
  final String time;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: MIcon(icon, size: 22, color: iconColor, fill: fill)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TS.headline(
                              size: 15, weight: FontWeight.w600, color: _kOnSurface)),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: TS.mono(size: 11, color: _kOutline)),
                  ],
                ),
                const SizedBox(height: 6),
                body,
                const SizedBox(height: 12),
                footer,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
