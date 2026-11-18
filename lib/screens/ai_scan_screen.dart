import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

// 设计稿 ai_4 的 Material-3 语义色（tailwind config 原值，Tailwind 调色板
// 无等值 → 以私有常量 1:1 还原）。
const Color _kSurfaceContainerLow = Color(0xFFF2F3FF);
const Color _kSurfaceContainerHigh = Color(0xFFE5E7F6);
const Color _kSurfaceContainerHighest = Color(0xFFDFE2F1);
const Color _kOnSurface = Color(0xFF171B26);
const Color _kOnSurfaceVariant = Color(0xFF3C4A42);
const Color _kPrimary = Color(0xFF006C49);
const Color _kPrimaryContainer = Color(0xFF10B981);
const Color _kSecondary = Color(0xFF6B38D4);
const Color _kSecondaryContainer = Color(0xFF8455EF);
const Color _kOnSecondaryContainer = Color(0xFFFFFBFF);
const Color _kTertiary = Color(0xFF00687A);
const Color _kOutlineVariant30 = Color(0x4DBBCABF); // outline-variant/30

/// 智能票据识别（设计稿 ai_4）— 视觉多模态 OCR 取景框、扫描光束动效
/// （AnimationController 驱动）、结构化字段预览与确认回填操作区。
class AiScanScreen extends StatefulWidget {
  const AiScanScreen({super.key});

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen>
    with SingleTickerProviderStateMixin {
  /// 扫描光束 / 识别进度（对应 animate-[pulse_2.2s] 与识别流程）。
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  bool _done = false;
  int _uploadTab = 0; // 0 相册凭证 / 1 即时拍照 / 2 PDF 电子票
  final _memoCtrl =
      TextEditingController(text: '用于知识库向量检索与智能体微调调用');

  @override
  void initState() {
    super.initState();
    _scan.addStatusListener(_onScanStatus);
    _scan.forward();
  }

  void _onScanStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _done = true);
    }
  }

  /// 重拍 / 换图 / 重扫 → 重置动画状态并重新识别。
  void _restart() {
    if (!mounted) return;
    setState(() => _done = false);
    _scan.forward(from: 0);
  }

  @override
  void dispose() {
    _scan.removeStatusListener(_onScanStatus);
    _scan.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  String get _pct => (_scan.value * 100).toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（返回 + 标题 + 帮助/头像）----
          GlassHeader.back(
            title: '智能票据识别',
            actions: const [
              HeaderIconButton(icon: MSym.help_outline),
              SizedBox(width: 8),
              HeaderIconButton(icon: MSym.person),
            ],
          ),
          Expanded(
            // 顶栏（GlassHeader）内部已含顶部 SafeArea，这里只保留底部安全区
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const PageContentInsets(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _statusPill(),
                    const SizedBox(height: kCardGap),
                    _uploadTabs(),
                    const SizedBox(height: kCardGap),
                    _viewfinderCard(),
                    const SizedBox(height: kCardGap),
                    _conclusionCard(),
                    const SizedBox(height: kCardGap),
                    _fieldsCard(),
                    const SizedBox(height: kCardGap),
                    _confirmBlock(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 顶部状态胶囊 =====================
  Widget _statusPill() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant30),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _kSecondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: MIcon(MSym.auto_awesome,
                  size: 18, color: _kSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('视觉多模态大模型已就绪',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(size: 12, color: _kOnSurface)),
                Text('支持纸质发票、电子小票及 API 账单凭证',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(size: 11, color: _kOnSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // v4.2 极速版徽标（label-caps）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _kPrimaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulsingDot(color: _kPrimary, size: 6),
                const SizedBox(width: 4),
                Text('v4.2 极速版',
                    style: TS.mono(size: 10, weight: FontWeight.w600,
                        color: _kPrimary, letterSpacing: 0.8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 上传模式切换 Tab =====================
  Widget _uploadTabs() {
    Widget tab(int i, IconData icon, String label) {
      final active = _uploadTab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _uploadTab = i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: active
                  ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 2)]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MIcon(icon,
                    size: 16,
                    color: active ? _kPrimary : _kOnSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(
                          size: 12,
                          color:
                              active ? _kOnSurface : _kOnSurfaceVariant)),
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
        color: _kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          tab(0, MSym.photo_library, '相册凭证'),
          tab(1, MSym.photo_camera, '即时拍照'),
          tab(2, MSym.description, 'PDF / 电子票'),
        ],
      ),
    );
  }

  // ===================== 取景与识别卡片 =====================
  Widget _viewfinderCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant30),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 票据图像预览容器（h-56）
          SizedBox(
            height: 224,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _receiptMock(),
                // 扫描光束动效层（AnimationController 驱动上下扫掠）
                AnimatedBuilder(
                  animation: _scan,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_scan.value);
                    const band = 72.0;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        if (!_done)
                          Positioned(
                            top: t * (224 - band),
                            left: 0,
                            right: 0,
                            height: band,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _kPrimary.withValues(alpha: 0.0),
                                    _kPrimary.withValues(alpha: 0.15),
                                    _kPrimary.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (!_done)
                          Positioned(
                            top: t * (224 - band) + band - 2,
                            left: 0,
                            right: 0,
                            height: 2,
                            child:
                                ColoredBox(
                                    color: _kPrimaryContainer
                                        .withValues(alpha: 0.55)),
                          ),
                        if (!_done)
                          // 识别进度条
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _scan.value,
                                child: const ColoredBox(
                                    color: _kPrimaryContainer),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // OCR 瞄准对焦框（inset-x-7 inset-y-6）
                Positioned.fill(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Stack(
                      children: [
                        // 识别框四角
                        _corner(Alignment.topLeft, topLeft: 2),
                        _corner(Alignment.topRight, topRight: 2),
                        _corner(Alignment.bottomLeft, bottomLeft: 2),
                        _corner(Alignment.bottomRight, bottomRight: 2),
                        // 金额区域识别框高亮
                        Positioned(
                          top: 40,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kSecondaryContainer.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const MIcon(MSym.crop_free,
                                    size: 12, color: _kSecondary),
                                const SizedBox(width: 4),
                                Text('\u002450.00 USD',
                                    style: TS.mono(size: 11,
                                        weight: FontWeight.w600,
                                        color: _kOnSecondaryContainer)),
                              ],
                            ),
                          ),
                        ),
                        // 商户识别高亮
                        Positioned(
                          bottom: 32,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _kSurfaceContainerHighest.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const MIcon(MSym.verified,
                                    size: 12, color: _kPrimary),
                                const SizedBox(width: 4),
                                Text('OpenAI, L.L.C.',
                                    style: TS.mono(size: 10,
                                        weight: FontWeight.w500,
                                        color: _kOnSurface)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 状态悬浮浮签
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kSurfaceContainerHighest.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_done)
                          PulsingDot(ring: true, color: _kPrimary, size: 8)
                        else
                          const PulsingDot(color: _kPrimary, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          _done ? 'OCR 解析中枢在线' : 'OCR 解析中 $_pct%',
                          style: TS.mono(size: 10, weight: FontWeight.w600,
                              color: _kOnSurface, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 图片微调与操作条
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _kSurfaceContainerLow,
            child: Row(
              children: [
                const MIcon(MSym.image, size: 16, color: _kSecondary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('IMG_20250518_OpenAI.png',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.mono(size: 12, weight: FontWeight.w500,
                          color: _kOnSurfaceVariant)),
                ),
                const Spacer(),
                _miniAction(MSym.flip_camera_ios, '重拍', _restart),
                const SizedBox(width: 8),
                _miniAction(MSym.sync_alt, '换图', _restart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(Alignment alignment,
      {double topLeft = 0,
      double topRight = 0,
      double bottomLeft = 0,
      double bottomRight = 0}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: _kPrimary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            topRight: Radius.circular(topRight),
            bottomLeft: Radius.circular(bottomLeft),
            bottomRight: Radius.circular(bottomRight),
          ),
        ),
      ),
    );
  }

  Widget _miniAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _kSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MIcon(icon, size: 14, color: _kOnSurface),
            const SizedBox(width: 4),
            Text(label, style: TS.body(size: 12, color: _kOnSurface)),
          ],
        ),
      ),
    );
  }

  /// 票据图像预览（设计稿为远程票据照片 → 本地绘制示意票据，离线可用）。
  Widget _receiptMock() {
    Widget bar(double w, {double h = 8, Color c = _kSurfaceContainerHighest}) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEDE9FE),
            Color(0xFFF8F9FF),
            Color(0xFFD1FAE5),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 216,
          height: 172,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kOutlineVariant30),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: _kSecondaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  bar(88, h: 10, c: _kSurfaceContainerHigh),
                ],
              ),
              const SizedBox(height: kCardGap),
              bar(150),
              const SizedBox(height: 8),
              bar(120),
              const SizedBox(height: 8),
              bar(164),
              const SizedBox(height: 8),
              bar(96),
              const Spacer(),
              Container(height: 1, color: _kSurfaceContainerHigh),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bar(40, h: 8, c: _kSurfaceContainerHigh),
                  Text('\u002450.00',
                      style: TS.headline(size: 15, weight: FontWeight.w700,
                          color: _kOnSurface)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== 模型解析结论胶囊卡 =====================
  Widget _conclusionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant30),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (_done)
                const MIcon(MSym.check_circle,
                    size: 20, color: _kPrimary, fill: true)
              else
                // 识别中：旋转加载图标
                AnimatedBuilder(
                  animation: _scan,
                  builder: (context, child) => Transform.rotate(
                    angle: _scan.value * 2 * math.pi,
                    child: child,
                  ),
                  child: const MIcon(MSym.progress_activity,
                      size: 20, color: _kPrimary),
                ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _done ? 'AI 票据结构化解析成功' : 'AI 票据结构化解析中...',
                  style: TS.body(size: 14, color: _kOnSurface),
                ),
              ),
              // 置信度徽标
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _done ? _kSecondaryContainer : _kSurfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _done ? '置信度 99.2%' : '识别中 $_pct%',
                  style: TS.mono(size: 10, weight: FontWeight.w600,
                      color: _done ? _kSecondary : _kOnSurfaceVariant,
                      letterSpacing: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              _done
                  ? '耗时 0.78s · 已自动归类至「AI算力订阅」并折算最新汇率'
                  : '正在提取金额、商户与账期字段 · 请保持票据完整',
              style: TS.body(size: 12, color: _kOnSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 提取字段列表预览 =====================
  Widget _fieldsCard() {
    Widget iconBox(IconData icon, Color bg, Color fg,
        {Color? border, double radius = 6}) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: border != null ? Border.all(color: border) : null,
        ),
        child: Center(child: MIcon(icon, size: 14, color: fg)),
      );
    }

    Widget fieldShell({required Widget child, VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _kSurfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      );
    }

    Widget editTail() => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MIcon(MSym.edit, size: 16, color: _kOnSurfaceVariant),
          ],
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant30),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 头部
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('结构化字段预览',
                  style: TS.body(size: 14, color: _kOnSurface)),
              Text('点击单行可手动纠错',
                  style: TS.body(size: 12, color: _kOnSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          // 字段 1: 账单类别
          fieldShell(
            onTap: () => _nudge('账单类型'),
            child: Row(
              children: [
                iconBox(MSym.psychology, _kSecondaryContainer, _kSecondary),
                const SizedBox(width: 8),
                Text('账单类型',
                    style: TS.body(size: 12, color: _kOnSurfaceVariant)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kSecondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('AI 算力与模型订阅',
                      style: TS.mono(size: 11, weight: FontWeight.w500,
                          color: _kOnSecondaryContainer)),
                ),
                const SizedBox(width: 6),
                editTail(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 字段 2: 消费项目
          fieldShell(
            onTap: () => _nudge('项目 / 商户'),
            child: Row(
              children: [
                iconBox(MSym.storefront, _kSurfaceContainerHigh, _kOnSurface),
                const SizedBox(width: 8),
                Text('项目 / 商户',
                    style: TS.body(size: 12, color: _kOnSurfaceVariant)),
                const Spacer(),
                Flexible(
                  // FittedBox 保证完整显示（与设计稿一致）
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('OpenAI API Tier-4 充值',
                        maxLines: 1,
                        style: TS.body(size: 12, color: _kOnSurface)),
                  ),
                ),
                const SizedBox(width: 6),
                editTail(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 字段 3: 交易金额
          fieldShell(
            onTap: () => _nudge('扣费原币 / 折算'),
            child: Row(
              children: [
                iconBox(MSym.payments,
                    _kPrimaryContainer.withValues(alpha: 0.2), _kPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('扣费原币 / 折算',
                      style: TS.body(size: 12, color: _kOnSurfaceVariant)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('\u002450.00',
                            style: TextStyle(
                                fontFamily: F.display,
                                fontSize: 22,
                                height: 28 / 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.22,
                                color: _kPrimary,
                                leadingDistribution:
                                    TextLeadingDistribution.even)),
                        const SizedBox(width: 4),
                        Text('USD',
                            style: TS.mono(size: 11, weight: FontWeight.w600,
                                color: _kOnSurfaceVariant,
                                letterSpacing: 0.8)),
                      ],
                    ),
                    Text('折合 ≈ ¥362.50 CNY (汇率 7.25)',
                        style: TS.mono(size: 11, weight: FontWeight.w500,
                            color: _kOnSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 字段 4: 交易时间与单号
          Row(
            children: [
              Expanded(
                child: _kvBox('交易时间', '2025-05-18 14:32'),
              ),
              const SizedBox(width: 8),
              Expanded(child: _kvBox('系统凭单号', 'INV-20250518-8921')),
            ],
          ),
          const SizedBox(height: 12),
          // 字段 5: 支付账户
          fieldShell(
            onTap: () => _nudge('支付账户'),
            child: Row(
              children: [
                iconBox(MSym.credit_card, _kSurfaceContainerHigh, _kTertiary),
                const SizedBox(width: 8),
                Text('支付账户',
                    style: TS.body(size: 12, color: _kOnSurfaceVariant)),
                const Spacer(),
                Flexible(
                  child: Text('招商外币卡 (•••• 4288)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.mono(size: 12, weight: FontWeight.w500,
                          color: _kOnSurface)),
                ),
                const SizedBox(width: 4),
                const MIcon(MSym.chevron_right,
                    size: 16, color: _kOnSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 字段 6: 记账备忘
          fieldShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('智能识别备忘录',
                        style: TS.body(size: 11, color: _kOnSurfaceVariant)),
                    const MIcon(MSym.auto_fix_high,
                        size: 14, color: _kOnSurfaceVariant),
                  ],
                ),
                TextField(
                  controller: _memoCtrl,
                  cursorColor: _kPrimary,
                  style: TS.body(size: 12, color: _kOnSurface),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TS.body(size: 11, color: _kOnSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TS.mono(size: 12, weight: FontWeight.w500,
                  color: _kOnSurface)),
        ],
      ),
    );
  }

  void _nudge(String field) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _kOnSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text('已进入「$field」手动纠错模式',
            style: TS.body(size: 12, color: Colors.white)),
      ));
  }

  // ===================== 底部操作区 =====================
  Widget _confirmBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('确认提交后将自动回填至记账草稿表单，支持随时重设',
            textAlign: TextAlign.center,
            style: TS.body(size: 11, color: _kOnSurfaceVariant)),
        const SizedBox(height: 10),
        Row(
          children: [
            // 重扫
            GestureDetector(
              onTap: _restart,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _kSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MIcon(MSym.cached, size: 18, color: _kOnSurface),
                    SizedBox(width: 4),
                    Text('重扫',
                        style: TextStyle(
                            fontFamily: F.sans,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _kOnSurface)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            // 确认并回填记账单
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 6,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MIcon(MSym.task_alt,
                          size: 20, color: Colors.white, fill: true),
                      const SizedBox(width: 8),
                      Text('确认并回填记账单',
                          style: TS.headline(size: 16,
                              weight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
