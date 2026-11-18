import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 偏好设置（设计稿 _7）— 系统健康度总览、外观与交互、多币种与汇率、
/// AI 分流规则、隐私安全、数据同步与存储管理的分组设置页。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.backupOnly = false});

  final bool backupOnly;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ---- 外观与交互 ----
  int _appearance = 0; // 0=浅色明晰 1=深色质感 2=跟随系统
  bool _denseNumeric = true; // 极客高密度数字排版
  bool _bigAmount = false; // 醒目金额大号字号
  // ---- 多币种与汇率 ----
  bool _autoFx = true; // 每日自动校准牌价
  // ---- AI 分流 ----
  bool _aiRouting = true; // AI 算力与订阅智能识别
  // ---- 隐私与安全 ----
  bool _bioUnlock = true; // Face ID / 触控 ID
  bool _privacyMask = false; // 公共场合金额脱敏
  // ---- 数据同步 ----
  int _syncState = 0; // 0=待同步 1=同步中 2=已完成
  // ---- 存储缓存 ----
  int _cacheState = 0; // 0=待清理 1=清理中 2=已清理
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _chainTimer(Duration d, VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(d, () {
      if (mounted) action();
    });
  }

  void _triggerSync() {
    if (_syncState != 0) return;
    setState(() => _syncState = 1);
    _chainTimer(const Duration(milliseconds: 1200), () {
      setState(() => _syncState = 2);
      _chainTimer(const Duration(milliseconds: 1500), () {
        setState(() => _syncState = 0);
      });
    });
  }

  void _clearCache() {
    if (_cacheState != 0) return;
    setState(() => _cacheState = 1);
    _chainTimer(const Duration(milliseconds: 700), () {
      setState(() => _cacheState = 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏 ----
          GlassHeader.back(
            title: widget.backupOnly ? '数据备份' : '偏好设置',
            actions: [const HeaderIconButton(icon: MSym.person)],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const PageContentInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.backupOnly) ...[
                    _healthCard(),
                    const SizedBox(height: kCardGap),
                    _appearanceSection(),
                    const SizedBox(height: kCardGap),
                    _currencySection(),
                    const SizedBox(height: kCardGap),
                    _aiRoutingSection(),
                    const SizedBox(height: kCardGap),
                    _securitySection(),
                    const SizedBox(height: kCardGap),
                  ],
                  _dataSyncSection(),
                  const SizedBox(height: kCardGap),
                  _storageSection(),
                  const SizedBox(height: kCardGap),
                  if (!widget.backupOnly) ...[
                    _switchAccountButton(),
                    const SizedBox(height: kCardGap),
                  ],
                  _brandFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 系统健康度总览 =====================
  Widget _healthCard() {
    Widget miniTile(IconData icon, String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.emerald100),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: C.emerald100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: MIcon(icon, size: 18, color: C.emerald600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TS.mono(
                        size: 10,
                        weight: FontWeight.w500,
                        color: C.slate400,
                      ),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TS.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: C.slate800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.emerald50.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.emerald200.withValues(alpha: 0.7)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 3)],
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
                    const PulsingDot(color: C.emerald500, size: 8),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'SYSTEM CONFIG · ACTIVE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TS.mono(
                          size: 11,
                          weight: FontWeight.w600,
                          color: C.emerald700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.emerald100.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'v2.4.0 (108)',
                  style: TS.mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: C.emerald700.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '智流引擎已就绪',
                style: TS.headline(
                  size: 20,
                  weight: FontWeight.w700,
                  color: C.emerald950,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.emerald100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '云端双向同步中',
                  style: TS.body(
                    size: 12,
                    weight: FontWeight.w600,
                    color: C.emerald700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '极简浅色高刷模式已激活，默认本位币为 CNY (实时参考 7.2345)，端侧硬件安全 Enclave 加密运行中。',
            style: TS.body(
              size: 13,
              color: C.emerald800.withValues(alpha: 0.8),
              height: 1.625,
            ),
          ),
          const SizedBox(height: kCardGap),
          Row(
            children: [
              miniTile(MSym.verified_user, '硬件安全', 'FaceID 加密锁定'),
              const SizedBox(width: kCardGap),
              miniTile(MSym.sync, '云同步协议', 'WebDAV / 实时'),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 分组头 =====================
  Widget _sectionHeader(
    String title,
    String trailing,
    Color trailingColor, {
    FontWeight trailingWeight = FontWeight.w600,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TS.mono(
                size: 11,
                weight: FontWeight.w600,
                color: C.slate400,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trailing,
            style: TS.mono(
              size: 11,
              weight: trailingWeight,
              color: trailingColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 白底分组卡片（divide-y 分隔行）。
  Widget _groupCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: cardBorder(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Container(height: 1, color: C.slate100),
            rows[i],
          ],
        ],
      ),
    );
  }

  /// 32x32 圆角图标容器。
  Widget _iconBox(
    IconData icon, {
    Color bg = C.slate100,
    Color fg = C.slate600,
    Color? border,
    double iconSize = 18,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Center(
        child: MIcon(icon, size: iconSize, color: fg),
      ),
    );
  }

  /// 带开关的设置行。
  Widget _switchRow({
    required IconData icon,
    required String title,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color bg = C.slate100,
    Color fg = C.slate600,
    Color? border,
    double iconSize = 18,
    bool titleSemibold = false,
    Widget? titlePrefix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _iconBox(icon, bg: bg, fg: fg, border: border, iconSize: iconSize),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (titlePrefix != null) ...[
                      titlePrefix,
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        style: TS.body(
                          size: 14,
                          weight: titleSemibold
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: C.slate900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(sub, style: TS.body(size: 12, color: C.slate400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  /// 带右箭头的导航行（HTML 中为 button，保持静态）。
  Widget _navRow({
    required IconData icon,
    required String title,
    required String sub,
    Widget? trailing,
    Color bg = C.slate100,
    Color fg = C.slate600,
    Color? border,
    double iconSize = 18,
    Color titleColor = C.slate900,
    Color chevronColor = C.slate400,
  }) {
    return _navRowRaw(
      leading: _iconBox(
        icon,
        bg: bg,
        fg: fg,
        border: border,
        iconSize: iconSize,
      ),
      title: title,
      sub: sub,
      trailing: trailing,
      titleColor: titleColor,
      chevronColor: chevronColor,
    );
  }

  /// 导航行（自定义 leading）。
  Widget _navRowRaw({
    required Widget leading,
    required String title,
    required String sub,
    Widget? trailing,
    Color titleColor = C.slate900,
    Color chevronColor = C.slate400,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TS.body(
                    size: 14,
                    weight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(sub, style: TS.body(size: 12, color: C.slate400)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
          const SizedBox(width: 4),
          MIcon(MSym.chevron_right, size: 18, color: chevronColor),
        ],
      ),
    );
  }

  /// 右侧等宽字体信息（如 CNY · 人民币）。
  Widget _navValue(
    String text, {
    Color color = C.slate700,
    FontWeight weight = FontWeight.w500,
  }) {
    return Text(
      text,
      style: TS.mono(size: 13, weight: weight, color: color),
    );
  }

  /// 灰底等宽小徽章（如 2 个币种锁定）。
  Widget _monoChip(String text, {Color fg = C.slate500, double size = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: C.slate100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TS.mono(size: size, weight: FontWeight.w500, color: fg),
      ),
    );
  }

  // ===================== 分组一：外观与交互 =====================
  Widget _appearanceSection() {
    Widget segItem(
      int i,
      IconData icon,
      String label, {
      bool fillIcon = false,
    }) {
      final active = _appearance == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _appearance = i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: active
                  ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)]
                  : null,
            ),
            child: Column(
              children: [
                MIcon(
                  icon,
                  size: 18,
                  color: active ? C.emerald600 : C.slate500,
                  fill: active && fillIcon,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TS.mono(
                    size: 12,
                    weight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? C.emerald600 : C.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 强调色圆点（HTML 为静态按钮）
    Widget accentDot(Color color, {bool selected = false, double opacity = 1}) {
      if (selected) {
        // ring-2 ring-emerald-200 ring-offset-2 + 中心白点
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: C.emerald200,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: ColoredBox(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      }
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader('外观与交互 (APPEARANCE)', 'LIGHT DEFAULT', C.emerald600),
        const SizedBox(height: 8),
        _groupCard([
          // 显示模式：分段选择器
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '显示模式',
                      style: TS.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: C.slate900,
                      ),
                    ),
                    Text(
                      '针对高分视网膜屏调校',
                      style: TS.body(size: 12, color: C.slate400),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: C.slate100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      segItem(0, MSym.light_mode, '浅色明晰', fillIcon: true),
                      const SizedBox(width: 4),
                      segItem(1, MSym.dark_mode, '深色质感'),
                      const SizedBox(width: 4),
                      segItem(2, MSym.brightness_auto, '跟随系统'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 主强调主题色
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _iconBox(MSym.palette),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '主强调主题色',
                        style: TS.body(
                          size: 14,
                          weight: FontWeight.w500,
                          color: C.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '账单盈亏与关键操作高亮',
                        style: TS.body(size: 12, color: C.slate400),
                      ),
                    ],
                  ),
                ),
                accentDot(C.emerald500, selected: true),
                const SizedBox(width: 8),
                accentDot(C.purple500, opacity: 0.8),
                const SizedBox(width: 8),
                accentDot(C.sky500, opacity: 0.8),
                const SizedBox(width: 8),
                accentDot(C.rose500, opacity: 0.8),
              ],
            ),
          ),
          _switchRow(
            icon: MSym.density_medium,
            title: '极客高密度数字排版',
            sub: '每屏容纳更多流水并等宽对齐',
            value: _denseNumeric,
            onChanged: (v) => setState(() => _denseNumeric = v),
          ),
          _switchRow(
            icon: MSym.format_size,
            title: '醒目金额大号字号',
            sub: '突出主账户总余额呈现',
            value: _bigAmount,
            onChanged: (v) => setState(() => _bigAmount = v),
          ),
        ]),
      ],
    );
  }

  // ===================== 分组二：多币种与汇率 =====================
  Widget _currencySection() {
    // 币种符号方块（¥ / $）
    Widget symbolBox(
      String symbol, {
      required Color bg,
      required Color fg,
      required Color border,
    }) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TS.mono(size: 14, weight: FontWeight.w700, color: fg),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          '多币种与汇率核心 (CURRENCY)',
          'ECB & BOC LIVE',
          C.sky600,
          trailingWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        _groupCard([
          // 主记账币种
          _navRowRaw(
            leading: symbolBox(
              '¥',
              bg: C.emerald50,
              fg: C.emerald700,
              border: C.emerald100,
            ),
            title: '主记账币种 (Base Currency)',
            sub: '结算所有财务报表与流水',
            trailing: _navValue(
              'CNY · 人民币',
              color: C.emerald600,
              weight: FontWeight.w600,
            ),
          ),
          // 海外折算辅币
          _navRowRaw(
            leading: symbolBox(
              r'$',
              bg: C.blue50,
              fg: C.blue600,
              border: C.blue100,
            ),
            title: '海外折算辅币',
            sub: '海外 SaaS / Token 支出参考',
            trailing: _navValue('USD · 美元'),
          ),
          // 每日自动校准牌价
          _switchRow(
            icon: MSym.currency_exchange,
            title: '每日自动校准牌价',
            sub: '每日 08:00 拉取基准 (1 USD = 7.2345 CNY)',
            value: _autoFx,
            onChanged: (v) => setState(() => _autoFx = v),
            titlePrefix: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: C.emerald500,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 离线固定汇率
          _navRow(
            icon: MSym.pin,
            title: '离线固定汇率与锁定表',
            sub: '针对跨境稳定结算固定基准',
            trailing: _monoChip('2 个币种锁定'),
          ),
        ]),
      ],
    );
  }

  // ===================== 分组三：智能分流引擎 =====================
  Widget _aiRoutingSection() {
    Widget ruleTag(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: C.slate100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              label,
              style: TS.mono(
                size: 11,
                weight: FontWeight.w500,
                color: C.slate600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          '智能分流引擎 (AI AUTO-ROUTING)',
          '12 ACTIVE RULES',
          C.purple600,
        ),
        const SizedBox(height: 8),
        _groupCard([
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconBox(
                      MSym.neurology,
                      bg: C.purple50,
                      fg: C.purple600,
                      border: C.purple100,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 算力与订阅智能识别',
                            style: TS.body(
                              size: 14,
                              weight: FontWeight.w600,
                              color: C.slate900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '识别账单商户自动打标归入「研发-模型费用」',
                            style: TS.body(size: 12, color: C.slate400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _Switch(
                        value: _aiRouting,
                        onChanged: (v) => setState(() => _aiRouting = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ruleTag('OpenAI'),
                    ruleTag('Anthropic'),
                    ruleTag('Cursor AI'),
                    ruleTag('Midjourney'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: C.slate100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+8 规则',
                        style: TS.mono(
                          size: 11,
                          weight: FontWeight.w500,
                          color: C.slate500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _navRow(
            icon: MSym.rule,
            title: '配置商户过滤与正则分流规则',
            sub: '自定义匹配关键词与自动科目绑定',
          ),
        ]),
      ],
    );
  }

  // ===================== 分组四：隐私与安全 =====================
  Widget _securitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader('隐私与安全验证 (SECURITY)', 'ENCRYPTED', C.emerald600),
        const SizedBox(height: 8),
        _groupCard([
          _switchRow(
            icon: MSym.fingerprint,
            iconSize: 20,
            title: 'Face ID / 触控 ID 解锁进入',
            sub: '冷启动或多任务切换时强制验证',
            bg: C.emerald50,
            fg: C.emerald600,
            border: C.emerald100,
            value: _bioUnlock,
            onChanged: (v) => setState(() => _bioUnlock = v),
          ),
          _navRow(
            icon: MSym.lock_clock,
            title: '自动锁屏时限',
            sub: '离开 App 到需要重新认证的时间',
            trailing: _navValue('立即锁定'),
          ),
          _switchRow(
            icon: MSym.visibility_off,
            title: '公共场合金额脱敏保护',
            sub: '默认以 **** 遮挡主资产及明细余额',
            value: _privacyMask,
            onChanged: (v) => setState(() => _privacyMask = v),
          ),
        ]),
      ],
    );
  }

  // ===================== 分组五：数据同步与备份 =====================
  Widget _dataSyncSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          '数据备份 (DATA BACKUP)',
          '14:32 SYNCED',
          C.slate400,
          trailingWeight: FontWeight.w400,
        ),
        const SizedBox(height: 8),
        _groupCard([
          // 云端双写备份 + 手动同步按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _iconBox(
                  MSym.cloud_done,
                  bg: C.emerald50,
                  fg: C.emerald600,
                  border: C.emerald100,
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
                              '云端端侧双写备份',
                              style: TS.body(
                                size: 14,
                                weight: FontWeight.w500,
                                color: C.slate900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: C.emerald50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: C.emerald100),
                            ),
                            child: Text(
                              'WEBDAV',
                              style: TS.mono(
                                size: 10,
                                weight: FontWeight.w600,
                                color: C.emerald700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '上一次备份：今天 14:32:08 (增量 42 KB)',
                        style: TS.body(size: 12, color: C.slate400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 手动同步按钮（同步中图标旋转 → 已完成 → 复位）
                GestureDetector(
                  onTap: _triggerSync,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: C.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_syncState == 1)
                          const _SpinningIcon(
                            MSym.sync,
                            size: 16,
                            color: C.emerald700,
                          )
                        else
                          MIcon(
                            MSym.sync,
                            size: 16,
                            color: _syncState == 2 ? C.sky600 : C.emerald700,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          _syncState == 0
                              ? '同步'
                              : _syncState == 1
                              ? '同步中...'
                              : '已完成',
                          style: TS.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: _syncState == 2 ? C.sky600 : C.emerald700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _navRow(
            icon: MSym.ios_share,
            title: '导出账单与报销凭据',
            sub: '支持 CSV、标准 Excel 及 PDF 发票归档包',
            trailing: _monoChip('.CSV / .PDF'),
          ),
          _navRow(
            icon: MSym.download,
            title: '导入其他记账应用数据',
            sub: '支持随手记、钱迹、Toshl 及 微信/支付宝',
          ),
        ]),
      ],
    );
  }

  // ===================== 分组六：存储与缓存 =====================
  Widget _storageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          '存储与沙盒空间 (STORAGE)',
          'CACHE OCCUPIED',
          C.slate400,
          trailingWeight: FontWeight.w400,
        ),
        const SizedBox(height: 8),
        _groupCard([
          // OCR 缓存清理
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _iconBox(MSym.cleaning_services),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '发票 OCR 识别缓存与离线模型',
                        style: TS.body(
                          size: 14,
                          weight: FontWeight.w500,
                          color: C.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _cacheState == 2
                            ? '已释放 28.4 MB 临时文件 · 空间最优化'
                            : '已占用 28.4 MB (不影响账本元数据)',
                        style: TS.body(size: 12, color: C.slate400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearCache,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _cacheState == 2 ? C.slate100 : C.rose50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _cacheState == 0
                          ? '清理缓存'
                          : _cacheState == 1
                          ? '清理中...'
                          : '0.0 MB',
                      style: TS.mono(
                        size: 12,
                        weight: FontWeight.w600,
                        color: _cacheState == 2 ? C.slate400 : C.rose600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 重置出厂设置
          _navRow(
            icon: MSym.restart_alt,
            title: '擦除本地数据并重置系统',
            sub: '需要输入主密码，擦除设备端密钥与沙盒',
            bg: C.rose50,
            fg: C.rose600,
            titleColor: C.rose600,
            chevronColor: C.rose400,
          ),
        ]),
      ],
    );
  }

  // ===================== 切换账号 =====================
  Widget _switchAccountButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: cardBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MIcon(MSym.swap_horiz, size: 18, color: C.slate500),
          const SizedBox(width: 8),
          Text(
            '切换账号 / 退出登录',
            style: TS.body(
              size: 14,
              weight: FontWeight.w500,
              color: C.slate700,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 底部品牌背书 =====================
  Widget _brandFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MIcon(MSym.lock, size: 15, color: C.slate400),
              const SizedBox(width: 6),
              Text(
                'FLOWAI SECURE COMPUTE ENGINE',
                style: TS.mono(
                  size: 11,
                  weight: FontWeight.w600,
                  color: C.slate400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '基于 iOS Secure Enclave 硬件隔离 · 本地端到端加密 · 智流记账不对外传输原始私钥',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: F.sans,
              fontSize: 11,
              height: 1.5,
              color: C.slate400,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ],
      ),
    );
  }
}

/// toggle switch（HTML `w-12 h-6 rounded-full` 轨道 + w-5 h-5 白色滑块）。
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
        width: 48,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? C.emerald500 : C.slate200,
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

/// 同步按钮的旋转图标（animate-spin）。
class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon(this.icon, {required this.size, required this.color});

  final IconData icon;
  final double size;
  final Color color;

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: MIcon(widget.icon, size: widget.size, color: widget.color),
    );
  }
}
