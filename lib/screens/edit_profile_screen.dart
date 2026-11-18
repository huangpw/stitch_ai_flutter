import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

// ---- 设计稿 _3 的 Material 语义色令牌（palette.dart 中无对应 Tailwind 值）----
const _kOnSurface = Color(0xFF191C20); // on-surface
const _kOnSurfaceVariant = Color(0xFF3C4A42); // on-surface-variant
const _kOutline = Color(0xFF6C7A71); // outline
const _kSurfaceLow = Color(0xFFF2F3F9); // surface-container-low
const _kSurfaceContainer = Color(0xFFECEEF3); // surface-container
const _kSurfaceHigh = Color(0xFFE7E8EE); // surface-container-high
const _kPrimary = Color(0xFF006C49); // primary
const _kSecondary = Color(0xFF6B38D4); // secondary
const _kTertiary = Color(0xFF00687A); // tertiary
const _kWechat = Color(0xFF07C160); // 微信品牌绿

/// 编辑个人资料（设计稿 _3）— 头像与身份卡片、基础资料表单、
/// 账号安全与绑定、底部固定保存操作与顶部吐司。
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nickCtrl = TextEditingController(text: '陈晨 (Alex Chen)');
  final _nickFocus = FocusNode();
  final _bioCtrl = TextEditingController(text: '认真记录每一笔生活开销，量入为出，追求极简与财务自由');
  final _bioFocus = FocusNode();
  List<_ProfileTag> _tags = const [
    _ProfileTag('极客开发者', _kSecondary),
    _ProfileTag('AI大模型重度用户', _kPrimary),
    _ProfileTag('双轨记账达人', _kTertiary),
  ];
  bool _copied = false;
  bool _showToast = false;
  String _toastMsg = '个人资料已成功更新保存';
  Timer? _toastTimer;

  static const _uid = 'flow_8829103';
  static const _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCLdKAZjIDODht4_yWt2ed9t8lFsX0cTzZgWTulW4c7yJNheFpG5m5YGXjvgyNZ3j3bNMs3Q7sVoA4EwNW6maiRsRByq-Kch3S-Z1NbwgdOYFxyvro86e70OrMXUXhXICC_kc6Q5Dqz72a31Wp4zOF4ZBvSzDM0WWDwqO62tvlFh8d79-eZXc0BcZ13wJqoj0XRVccKmHZayZ20KjNfSDulJDE5A5ieNumlUUXG3j3y';

  @override
  void initState() {
    super.initState();
    _bioFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nickCtrl.dispose();
    _nickFocus.dispose();
    _bioCtrl.dispose();
    _bioFocus.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  // ---- 顶部吐司（设计稿 #save-toast）----
  void _toast(String msg) {
    _toastTimer?.cancel();
    setState(() {
      _toastMsg = msg;
      _showToast = true;
    });
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  // ---- 复制用户 ID ----
  void _copyUid() {
    Clipboard.setData(const ClipboardData(text: _uid));
    _toast('已复制用户 ID: $_uid');
    setState(() => _copied = true);
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  // ---- 保存：吐司提示后返回 ----
  void _save() {
    _toast('个人资料已成功保存并同步');
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  // ---- 添加身份标签对话框 ----
  Future<void> _addTag() async {
    final ctrl = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '添加身份标签',
          style: TS.body(size: 16, weight: FontWeight.w600, color: _kOnSurface),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          cursorColor: C.emerald500,
          style: TS.body(size: 14, color: _kOnSurface),
          decoration: InputDecoration(
            hintText: '输入新的身份标签或专长',
            hintStyle: TS.body(size: 14, color: _kOutline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TS.body(size: 14, color: _kOutline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(
              '添加',
              style: TS.body(
                size: 14,
                weight: FontWeight.w600,
                color: C.emerald600,
              ),
            ),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (label != null && label.isNotEmpty) {
      setState(() => _tags = [..._tags, _ProfileTag(label, _kSecondary)]);
    }
  }

  // ---- 更换头像底部弹层 ----
  void _showAvatarSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '更换个人头像照片',
                    style: TS.body(
                      size: 16,
                      weight: FontWeight.w600,
                      color: _kOnSurface,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _kSurfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: MIcon(MSym.close, size: 16, color: _kOutline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _avatarOption(
                    MSym.photo_library,
                    '从手机相册选取',
                    _kPrimary,
                    () {
                      Navigator.pop(ctx);
                      _toast('已从相册读取最新头像照片');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _avatarOption(
                    MSym.photo_camera,
                    '相机拍照识别',
                    C.violet500,
                    () {
                      Navigator.pop(ctx);
                      _toast('相机拍照识别启动中...');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    '取消',
                    style: TS.body(
                      size: 12,
                      weight: FontWeight.w500,
                      color: _kOutline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（返回 + 标题 + 保存）----
          GlassHeader.back(
            title: '编辑个人资料',
            actions: [HeaderIconButton(icon: MSym.check, onTap: _save)],
          ),
          Expanded(
            child: Stack(
              children: [
                // ---- 主体滚动内容 ----
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: PageContentInsets(bottom: 140 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _avatarCard(),
                        const SizedBox(height: kCardGap),
                        _profileFormCard(),
                        const SizedBox(height: kCardGap),
                        _securityCard(),
                      ],
                    ),
                  ),
                ),
                // ---- 底部固定操作区 ----
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _footer(bottomInset),
                ),
                // ---- 顶部吐司 ----
                Positioned(
                  top: 16,
                  left: kPageInset,
                  right: kPageInset,
                  child: IgnorePointer(
                    ignoring: !_showToast,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showToast ? 1 : 0,
                      child: Center(child: _toastWidget()),
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

  // ---- 底部固定操作区 ----
  Widget _footer(double bottomInset) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _kSurfaceHigh)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A191C20),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: PageContentInsets(bottom: kPageInset + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 主操作：极光翡翠绿
          GestureDetector(
            onTap: _save,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: C.emerald500,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x0D000000), blurRadius: 3),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MIcon(MSym.done_all, size: 19, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '保存修改并更新',
                    style: TS.body(
                      size: 15,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 辅助操作：取消
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Text('取消', style: TS.body(size: 14, color: _kOutline)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toastWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kSurfaceHigh),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MIcon(MSym.check_circle, size: 18, color: C.emerald500),
          const SizedBox(width: 8),
          Text(
            _toastMsg,
            style: TS.body(
              size: 12,
              weight: FontWeight.w500,
              color: _kOnSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kSurfaceHigh.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08191C20),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _hairline({double alpha = 0.4}) {
    return Container(height: 1, color: _kSurfaceHigh.withValues(alpha: alpha));
  }

  // ===================== 卡片 1：头像与身份状态 =====================
  Widget _avatarCard() {
    return _card(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showAvatarSheet,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 头像光晕
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        C.emerald500.withValues(alpha: 0.2),
                        C.violet500.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
                // 当前头像
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _kSurfaceHigh,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0D000000), blurRadius: 3),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    _avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: MIcon(MSym.person, size: 32, color: _kOutline),
                    ),
                  ),
                ),
                // 极光绿在线状态微标
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: C.emerald500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 轻触操作提示
          GestureDetector(
            onTap: _showAvatarSheet,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MIcon(MSym.photo_camera, size: 15, color: C.violet500),
                const SizedBox(width: 4),
                Text(
                  '轻触更换头像照片 / 拍照识别',
                  style: TS.body(
                    size: 13,
                    weight: FontWeight.w500,
                    color: C.violet500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 身份会员标识
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _kSurfaceLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PulsingDot(color: C.emerald500, size: 6),
                const SizedBox(width: 6),
                Text(
                  '资深独立开发者 · FlowAI Pro 极客会员',
                  style: TS.body(
                    size: 12,
                    weight: FontWeight.w500,
                    color: _kOnSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 卡片 2：基础资料 =====================
  Widget _profileFormCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片头
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '基础资料',
                  style: TS.px(
                    '12',
                    family: F.mono,
                    weight: FontWeight.w600,
                    color: _kOutline,
                    letterSpacing: 0.5,
                  ),
                ),
                Text('个人及名片展示', style: TS.body(size: 12, color: _kOutline)),
              ],
            ),
          ),
          _hairline(alpha: 0.5),
          // 昵称
          _formRow(
            bottomBorder: true,
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    '昵称',
                    style: TS.body(
                      size: 14,
                      weight: FontWeight.w500,
                      color: _kOnSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nickCtrl,
                          focusNode: _nickFocus,
                          textAlign: TextAlign.right,
                          cursorColor: C.emerald500,
                          style: TS.body(
                            size: 14,
                            weight: FontWeight.w500,
                            color: _kOnSurface,
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: '输入昵称',
                            hintStyle: TS.body(
                              size: 14,
                              weight: FontWeight.w500,
                              color: _kOutline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          _nickCtrl.clear();
                          _nickFocus.requestFocus();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: MIcon(MSym.cancel, size: 17, color: _kOutline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 智流用户唯一 ID
          _formRow(
            bottomBorder: true,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '智流用户 ID',
                        style: TS.body(
                          size: 14,
                          weight: FontWeight.w500,
                          color: _kOnSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '系统唯一标识，不可更改',
                        style: TS.body(size: 11, color: _kOutline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _kSurfaceLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _uid,
                    style: TS.mono(
                      size: 13,
                      weight: FontWeight.w600,
                      color: _kOnSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _copyUid,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _kSurfaceLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: MIcon(
                        _copied ? MSym.done : MSym.content_copy,
                        size: 15,
                        color: _kOutline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 身份标签与专长
          _formRow(
            bottomBorder: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '身份标签与专长',
                      style: TS.body(
                        size: 14,
                        weight: FontWeight.w500,
                        color: _kOnSurface,
                      ),
                    ),
                    Text('公开主页展示', style: TS.body(size: 11, color: _kOutline)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in _tags) _tagChip(tag),
                    _addTagChip(),
                  ],
                ),
              ],
            ),
          ),
          // 个人财务签名
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '个人财务签名',
                      style: TS.body(
                        size: 14,
                        weight: FontWeight.w500,
                        color: _kOnSurface,
                      ),
                    ),
                    Text(
                      '${_bioCtrl.text.length}/60',
                      style: TS.mono(size: 11, color: _kOutline),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _bioCtrl,
                  focusNode: _bioFocus,
                  maxLength: 60,
                  maxLines: 2,
                  cursorColor: C.emerald500,
                  style: TS.body(size: 14, color: _kOnSurface, height: 1.5),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: _bioFocus.hasFocus
                        ? Colors.white
                        : _kSurfaceLow.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _kSurfaceHigh.withValues(alpha: 0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: C.emerald500,
                        width: 1.5,
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

  Widget _formRow({required Widget child, bool bottomBorder = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: child,
        ),
        if (bottomBorder) _hairline(),
      ],
    );
  }

  Widget _tagChip(_ProfileTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag.label,
            style: TS.body(size: 12, weight: FontWeight.w500, color: tag.color),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() {
              _tags = _tags.where((t) => t != tag).toList();
            }),
            child: MIcon(
              MSym.close,
              size: 13,
              color: tag.color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addTagChip() {
    return GestureDetector(
      onTap: _addTag,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _kSurfaceLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MIcon(MSym.add, size: 13, color: _kOnSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '添加标签',
              style: TS.body(
                size: 12,
                weight: FontWeight.w500,
                color: _kOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== 卡片 3：账号安全与绑定 =====================
  Widget _securityCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '账号安全与绑定',
                  style: TS.px(
                    '12',
                    family: F.mono,
                    weight: FontWeight.w600,
                    color: _kOutline,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '安全防护等级：高',
                  style: TS.body(
                    size: 12,
                    weight: FontWeight.w500,
                    color: C.emerald500,
                  ),
                ),
              ],
            ),
          ),
          _hairline(alpha: 0.5),
          _securityRow(
            bottomBorder: true,
            leading: const MIcon(MSym.phone_iphone, size: 18, color: _kOutline),
            title: '绑定手机号',
            trailing: Row(
              children: [
                Text(
                  '138 **** 9201',
                  style: TS.mono(
                    size: 12,
                    weight: FontWeight.w500,
                    color: _kOnSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                _verifyBadge(MSym.check_circle, '已验证'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _toast('请通过短信验证码修改手机号'),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    '更换',
                    style: TS.body(
                      size: 12,
                      weight: FontWeight.w500,
                      color: C.violet500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _securityRow(
            bottomBorder: true,
            leading: const MIcon(MSym.mail, size: 18, color: _kOutline),
            title: '绑定邮箱',
            trailing: Row(
              children: [
                Text(
                  'neo.hacker@neuralflow.ai',
                  style: TS.mono(
                    size: 12,
                    weight: FontWeight.w500,
                    color: _kOnSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                _verifyBadge(MSym.verified, '已认证'),
              ],
            ),
          ),
          _securityRow(
            bottomBorder: true,
            leading: const MIcon(MSym.chat, size: 18, color: _kWechat),
            title: '微信快捷登录',
            trailing: Row(
              children: [
                Text(
                  '已绑定（Alex_Chen_Tech）',
                  style: TS.body(
                    size: 12,
                    weight: FontWeight.w500,
                    color: _kOnSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                const MIcon(MSym.chevron_right, size: 16, color: _kOutline),
              ],
            ),
          ),
          // _securityRow(
          //   bottomBorder: false,
          //   leading:
          //       const MIcon(MSym.fingerprint, size: 18, color: _kOnSurface),
          //   title: 'Apple ID 登录',
          //   subtitle: 'Touch ID / Face ID 快速授权',
          //   trailing: Row(
          //     children: [
          //       Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //         decoration: BoxDecoration(
          //           color: _kSurfaceContainer,
          //           borderRadius: BorderRadius.circular(6),
          //         ),
          //         child: Text('已关联',
          //             style: TS.body(
          //                 size: 11,
          //                 weight: FontWeight.w500,
          //                 color: _kOnSurface)),
          //       ),
          //       const SizedBox(width: 4),
          //       const MIcon(MSym.chevron_right, size: 16, color: _kOutline),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _securityRow({
    required Widget leading,
    required String title,
    String? subtitle,
    required Widget trailing,
    required bool bottomBorder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 8),
              if (subtitle == null)
                Text(
                  title,
                  style: TS.body(
                    size: 14,
                    weight: FontWeight.w500,
                    color: _kOnSurface,
                  ),
                )
              else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TS.body(
                          size: 14,
                          weight: FontWeight.w500,
                          color: _kOnSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TS.body(size: 11, color: _kOutline),
                      ),
                    ],
                  ),
                ),
              if (subtitle == null) const Spacer(),
              trailing,
            ],
          ),
        ),
        if (bottomBorder) _hairline(),
      ],
    );
  }

  Widget _verifyBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _kPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MIcon(icon, size: 12, color: _kPrimary),
          const SizedBox(width: 2),
          Text(
            label,
            style: TS.body(size: 11, weight: FontWeight.w500, color: _kPrimary),
          ),
        ],
      ),
    );
  }

  Widget _avatarOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kSurfaceLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            MIcon(icon, size: 26, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TS.body(
                size: 12,
                weight: FontWeight.w600,
                color: _kOnSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 身份标签数据。
class _ProfileTag {
  const _ProfileTag(this.label, this.color);

  final String label;
  final Color color;
}
