import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import 'm_icon.dart';
import 'app_tab_navigation.dart';

/// 设计稿通用组件库：卡片、徽章、状态点、渐变按钮、输入框等。

/// 页面画布背景色（绝大多数屏幕为冰晶白 #F8F9FF）。
const kCanvas = Color(0xFFF8F9FF);

/// 通用白色卡片（rounded-2xl + 细描边 + 微阴影）。
class CardX extends StatelessWidget {
  const CardX({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.color = Colors.white,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// 标准卡片描边：`border border-slate-200/80` ≈ slate-200 @ 12% 透明度。
Border cardBorder({Color? color, double width = 1}) =>
    Border.all(color: color ?? const Color(0x1FE2E8F0), width: width);

/// 呼吸状态点（animate-pulse）。
class PulsingDot extends StatefulWidget {
  const PulsingDot({
    super.key,
    this.color = C.emerald500,
    this.size = 6,
    this.ring = false,
  });

  final Color color;
  final double size;
  final bool ring;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 纯装饰动画不参与无障碍节点的几何更新。
    return ExcludeSemantics(child: _buildDot());
  }

  Widget _buildDot() {
    if (widget.ring) {
      // animate-ping 外环 + 实心圆（如在线徽标）
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: Tween(begin: 0.75, end: 0.0).animate(_c),
              child: ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.8).animate(_c),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  width: widget.size * 0.18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.35).animate(_c),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

/// 返回按钮（arrow_back_ios_new + 文案）。
class BackLink extends StatelessWidget {
  const BackLink({super.key, this.label, this.onTap, this.color});

  final String? label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MIcon(
              MSym.arrow_back_ios_new,
              size: 20,
              color: color ?? C.slate600,
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: TS.body(
                  size: 14,
                  weight: FontWeight.w500,
                  color: color ?? C.slate600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 主 CTA 渐变按钮（emerald→teal，含图标与按压缩放反馈）。
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.height = 54,
    this.radius = 16,
    this.begin = C.emerald500,
    this.end = C.teal500,
    this.fontSize = 16,
    this.boxShadow,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  final double radius;
  final Color begin;
  final Color end;
  final double fontSize;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [begin, end]),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TS.headline(
                    size: fontSize,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  MIcon(icon!, size: 20, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 表单输入（bg-slate-50 rounded-xl focus 描边发光）。
class FieldX extends StatefulWidget {
  const FieldX({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.trailing,
    this.obscure = false,
    this.keyboardType,
    this.maxLength,
    this.mono = false,
    this.focusBorderColor = C.emerald500,
    this.onChanged,
    this.initialText,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final Widget? trailing;
  final bool obscure;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool mono;
  final Color focusBorderColor;
  final ValueChanged<String>? onChanged;
  final String? initialText;
  final bool enabled;

  @override
  State<FieldX> createState() => _FieldXState();
}

class _FieldXState extends State<FieldX> {
  final FocusNode _focus = FocusNode();
  TextEditingController? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null && widget.initialText != null) {
      _internalController = TextEditingController(text: widget.initialText);
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused
              ? widget.focusBorderColor.withValues(alpha: 0.55)
              : C.slate200,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: widget.focusBorderColor.withValues(alpha: 0.18),
                  blurRadius: 0,
                  spreadRadius: 2.5,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller ?? _internalController,
        focusNode: _focus,
        onChanged: widget.onChanged,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        cursorColor: C.emerald500,
        style: widget.mono
            ? TS.mono(size: 12, weight: FontWeight.w400, color: C.slate900)
            : TS.body(size: 12, color: C.slate900),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          filled: true,
          fillColor: focused ? Colors.white : C.slate50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: widget.icon != null
              ? MIcon(widget.icon!, size: 18, color: C.slate400)
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 0,
          ),
          suffixIcon: widget.trailing,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 0,
          ),
          hintText: widget.hint,
          hintStyle: widget.mono
              ? TS.mono(size: 12, weight: FontWeight.w400, color: C.slate400)
              : TS.body(size: 12, color: C.slate400),
        ),
      ),
    );
  }
}

/// 大号分段切换器（bg-slate-100 容器 + 白色活动段）。
class SegTabs extends StatelessWidget {
  const SegTabs({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.height = 36,
    this.iconSize = 15,
    this.fontSize = 12,
  });

  final List<(IconData?, String)> items;
  final int index;
  final ValueChanged<int> onChanged;
  final double height;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: C.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: height - 8,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: i == index
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (items[i].$1 != null) ...[
                        MIcon(
                          items[i].$1!,
                          size: iconSize,
                          color: i == index ? C.emerald700 : C.slate500,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        items[i].$2,
                        style: TS.body(
                          size: fontSize,
                          weight: i == index
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: i == index ? C.emerald700 : C.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 屏幕脚手架：冰晶画布 + 安全区 + 可选悬浮底部导航间距。
class ScreenBody extends StatelessWidget {
  const ScreenBody({
    super.key,
    required this.child,
    this.background = kCanvas,
    this.reserveNav = false,
  });

  final Widget child;
  final Color background;
  final bool reserveNav;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: reserveNav ? 116 : 0),
          child: child,
        ),
      ),
    );
  }
}

/// 导航栏顶栏标题。
class AppBarTitle extends StatelessWidget {
  const AppBarTitle(this.text, {super.key, this.size = 17});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TS.body(size: size, weight: FontWeight.w600, color: C.slate900),
    );
  }
}

/// 用户头像（assets/images/avatar.jpg）+ 可选在线状态点。
class AvatarX extends StatelessWidget {
  const AvatarX({
    super.key,
    this.size = 32,
    this.showStatus = false,
    this.assetName = 'assets/images/avatar.jpg',
  });

  final double size;
  final bool showStatus;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 3)],
      ),
      child: ClipOval(
        child: Image.asset(
          assetName,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
    if (!showStatus) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: size * 0.31,
            height: size * 0.31,
            decoration: BoxDecoration(
              color: C.emerald500,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// 顶栏头像统一进入「我的」，使用 40px 点击区域。
class HeaderProfileButton extends StatelessWidget {
  const HeaderProfileButton({
    super.key,
    this.showStatus = false,
    this.assetName = 'assets/images/avatar.jpg',
  });

  final bool showStatus;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      label: '打开我的页面',
      onTap: () => AppTabNavigation.openProfile(context),
      child: Tooltip(
        message: '我的',
        excludeFromSemantics: true,
        child: GestureDetector(
          excludeFromSemantics: true,
          behavior: HitTestBehavior.opaque,
          onTap: () => AppTabNavigation.openProfile(context),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: AvatarX(showStatus: showStatus, assetName: assetName),
            ),
          ),
        ),
      ),
    );
  }
}

/// 统一顶部导航栏（所有页面共用）。
///
/// 规格（全 APP 一致）：
/// - 内容高度固定 56px（含 SafeArea 顶部留白）
/// - 毛玻璃底 rgba(248,249,255,0.85) + 20px 背景模糊 + 底部 0.5px 发丝线
/// - 标题居中、17px / w600 / slate-900，超长省略
/// - 左侧 leading、右侧 actions 完全不遮挡标题（标题绝对居中）
/// - 标准返回键 [NavBarBackButton]、标准动作按钮 [HeaderIconButton]
class GlassHeader extends StatelessWidget {
  const GlassHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
  });

  /// 居中标题。
  final String title;

  /// 左侧区域（返回键 / 头像等），由调用方按页面语义传入。
  final Widget? leading;

  /// 右侧动作按钮组（建议使用 [HeaderIconButton] 保持统一）。
  final List<Widget> actions;

  /// 主页面统一使用日常记账同款头像、标题与圆形动作按钮。
  factory GlassHeader.tab({
    required String title,
    bool showStatus = false,
    List<Widget> actions = const [],
  }) {
    return GlassHeader(
      title: title,
      leading: HeaderProfileButton(showStatus: showStatus),
      actions: actions,
    );
  }

  /// 推送页便捷构造：标准返回键 + 居中标题 + 右侧动作。
  factory GlassHeader.back({
    required String title,
    List<Widget> actions = const [],
  }) {
    return GlassHeader(
      title: title,
      leading: const NavBarBackButton(),
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        // 撑满父宽度：即使在默认居中对齐的 Column 中也保持通栏
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xD9F8F9FF), // rgba(248,249,255,0.85)
          border: Border(
            bottom: BorderSide(color: const Color(0x14000000), width: 0.5),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 标题绝对居中（不受两侧宽度影响）
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 72),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TS.body(
                        size: 17,
                        weight: FontWeight.w600,
                        color: C.slate900,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    child: SizedBox(
                      height: 56,
                      child: Row(children: [if (leading != null) leading!]),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    height: 56,
                    child: Row(
                      children: [...actions, const SizedBox(width: 8)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 统一返回键（40×40 命中区 + chevron_left 24px，点击返回上一页）。
class NavBarBackButton extends StatelessWidget {
  const NavBarBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: const MIcon(MSym.chevron_left, size: 24, color: C.slate800),
      ),
    );
  }
}

/// 顶栏统一圆形动作按钮（32×32 圆形、slate-100/80 底、细描边、18px 图标）。
/// [badgeColor] 非空时右上角显示状态小圆点（如消息未读）。
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.badgeColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: C.slate100.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: MIcon(icon, size: 18, color: C.slate700)),
            if (badgeColor != null)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
