import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 个人中心（设计稿 _2）— 底部导航「我的」Tab 页（无返回箭头）。
/// 个人资料卡、消息预警条、账户总资产、系统偏好入口与安全声明。
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hideAssets = false; // 资产金额可见性开关

  static const _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCtpruhdMRCYgE78meCkKsl3faHV0sQpr-8FYcbGIpTiQcax-xT4HM-8jwdRoSUejWDIuT_ZFOMombpSX0J27rIXYmlBjg1IcsCZ0KKZT5-nTww6WeR05TFi5wcgK7-ddjOH1gcE8jpPy-s0ndJVFceQD1Zu_wJDh_hfd-FYZMnJJZ_VQfnaQU-Cb_WpTuKltMkimV_3_vjwWB-mywnUZipCVCI4yr4TWngi0aIWO4n';

  void _copyId() {
    Clipboard.setData(const ClipboardData(text: 'flow_8829103'));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('账号编码已复制'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: C.inverseSurface,
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（头像 + 标题 + 通知/设置）----
          GlassHeader.tab(
            title: '个人中心',
            actions: [
              // 消息通知（带角标）→ /notifications
              HeaderIconButton(
                icon: MSym.notifications,
                badgeColor: C.emerald500,
                onTap: () => Navigator.of(context).pushNamed('/notifications'),
              ),
              const SizedBox(width: 8),
              // 设置 → /settings
              HeaderIconButton(
                icon: MSym.settings,
                onTap: () => Navigator.of(context).pushNamed('/settings'),
              ),
            ],
          ),
          Expanded(
            // Tab 页：底部留白（116）给悬浮胶囊导航
            child: SingleChildScrollView(
              padding: const PageContentInsets(bottom: 116),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileCard(),
                  const SizedBox(height: kCardGap),
                  _notificationStrip(),
                  const SizedBox(height: kCardGap),
                  _assetsCard(),
                  const SizedBox(height: kCardGap),
                  _menuGroup(),
                  const SizedBox(height: kCardGap),
                  _securityFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 头像（网络图，失败时回落为渐变占位）。
  Widget _avatar({required double size, required double radius}) {
    return Image.network(
      _avatarUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [C.emerald100, C.teal100],
          ),
        ),
        child: const Center(
            child: MIcon(MSym.person, size: 18, color: C.emerald600)),
      ),
    );
  }

  // ===================== 个人信息资料卡片 =====================
  Widget _profileCard() {
    Widget tag(String label, {bool emerald = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: emerald ? C.emerald50 : C.slate100,
          borderRadius: BorderRadius.circular(6),
          border: emerald
              ? Border.all(color: C.emerald100)
              : null,
        ),
        child: Text(label,
            style: TS.mono(
                size: 10,
                weight: FontWeight.w500,
                color: emerald ? C.emerald600 : C.slate600)),
      );
    }

    Widget stat(String value, String unit, String label) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // font-display-lg（Space Grotesk 数字）
                  Text(value,
                      style: TS.headline(
                          size: 16, weight: FontWeight.w700, color: C.slate900)),
                  const SizedBox(width: 2),
                  Text(unit, style: TS.body(size: 10, color: C.slate500)),
                ],
              ),
              const SizedBox(height: 2),
              Text(label, style: TS.body(size: 10, color: C.slate400)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate100),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像 + 在线状态点
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: C.slate200.withValues(alpha: 0.8)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 2),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _avatar(size: 56, radius: 16),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: C.emerald500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 昵称 + 会员徽标
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('陈晨 (Alex Chen)',
                            style: TS.body(
                                size: 17,
                                weight: FontWeight.w700,
                                color: C.slate900)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.purple50,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: C.purple100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const MIcon(MSym.bolt,
                                  size: 13, color: C.purple600),
                              const SizedBox(width: 4),
                              Text('专业极客会员 · 终身订阅',
                                  style: TS.mono(
                                      size: 10,
                                      weight: FontWeight.w600,
                                      color: C.purple600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // ID + 复制
                    Row(
                      children: [
                        Text('ID: flow_8829103',
                            style: TS.mono(size: 11, color: C.slate400)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _copyId,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: MIcon(MSym.content_copy,
                                size: 13, color: C.slate400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 个性标签
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        tag('资深独立开发者'),
                        tag('人工智能模型重度用户'),
                        tag('8 组活跃接口密钥', emerald: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // 右侧：二维码名片 + 编辑资料（同行，与设计稿一致）
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: C.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child:
                            MIcon(MSym.qr_code_2, size: 18, color: C.slate600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/edit-profile'),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: C.slate100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MIcon(MSym.edit, size: 14, color: C.slate700),
                          const SizedBox(width: 4),
                          Text('编辑',
                              style: TS.body(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: C.slate700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: kCardGap),
          // 个性签名条
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: C.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.slate100),
            ),
            child: Row(
              children: [
                const MIcon(MSym.format_quote, size: 16, color: C.slate400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '认真记录每一笔生活开销，量入为出，追求极简与财务自律的生活方式。',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(size: 12, color: C.slate600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kCardGap),
          // 四格记账统计
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: C.slate100)),
            ),
            child: Row(
              children: [
                stat('862', '天', '连续记账'),
                stat('3,428', '笔', '记录笔数'),
                stat('24', '个', '记账分类'),
                stat('7', '个', '资产账户'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 消息 / 预警通知条 =====================
  Widget _notificationStrip() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/notifications'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.slate100),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 3),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: C.sky50,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child:
                        MIcon(MSym.notifications, size: 17, color: C.sky600),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: PulsingDot(color: C.rose500, size: 8),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OpenAI API 余额不足 \$15 预警通知',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(
                          size: 13, weight: FontWeight.w500, color: C.slate800)),
                  const SizedBox(height: 2),
                  Text('10分钟前 · 渠道预警',
                      style: TS.mono(size: 11, color: C.slate400)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: C.sky50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: C.sky100),
                  ),
                  child: Text('3条未读',
                      style: TS.mono(
                          size: 11,
                          weight: FontWeight.w500,
                          color: C.sky600)),
                ),
                const SizedBox(width: 4),
                const MIcon(MSym.chevron_right, size: 16, color: C.slate400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== 账户总资产卡片 =====================
  Widget _assetsCard() {
    Widget entry({
      required IconData icon,
      required Color tint,
      required Color iconColor,
      required String label,
      required String sub,
      Color? subColor,
      VoidCallback? onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                      child: MIcon(icon, size: 18, color: iconColor)),
                ),
                const SizedBox(height: 5),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.body(
                        size: 12, weight: FontWeight.w600, color: C.slate800)),
                const SizedBox(height: 1),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.mono(
                        size: 10,
                        weight: subColor == null ? FontWeight.w400 : FontWeight.w500,
                        color: subColor ?? C.slate400)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 右上角柔光饰斑（blur-2xl）
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.emerald100.withValues(alpha: 0.45),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const MIcon(MSym.account_balance, size: 17, color: C.emerald600),
                  const SizedBox(width: 6),
                  Text('账户总资产 (净值估算)',
                      style:
                          TS.body(size: 13, weight: FontWeight.w500, color: C.slate500)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _hideAssets = !_hideAssets),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: MIcon(
                          _hideAssets ? MSym.visibility_off : MSym.visibility,
                          size: 18,
                          color: C.slate400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // font-display-lg 大金额
                    Text(
                      _hideAssets ? '¥ ********' : '¥168,900.00',
                      style: TS.headline(
                          size: 32,
                          weight: FontWeight.w700,
                          color: C.slate900,
                          letterSpacing: -0.02),
                    ),
                    const SizedBox(width: 6),
                    Text('人民币 (CNY)',
                        style:
                            TS.mono(size: 12, weight: FontWeight.w500, color: C.slate400)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: C.slate100)),
                ),
                child: Row(
                  children: [
                    entry(
                      icon: MSym.credit_card,
                      tint: C.emerald50,
                      iconColor: C.emerald600,
                      label: '账户资产',
                      sub: '7个账户',
                      onTap: () => Navigator.of(context).pushNamed('/assets'),
                    ),
                    entry(
                      icon: MSym.receipt_long,
                      tint: C.purple50,
                      iconColor: C.purple600,
                      label: '账本管理',
                      sub: '3个账本',
                      subColor: C.purple600,
                      onTap: () => Navigator.of(context).pushNamed('/books'),
                    ),
                    entry(
                      icon: MSym.crisis_alert,
                      tint: C.amber50,
                      iconColor: C.amber600,
                      label: '扣费预警',
                      sub: '3项异常',
                      subColor: C.amber600,
                      onTap: () => Navigator.of(context).pushNamed('/ai-alert'),
                    ),
                    entry(
                      icon: MSym.pie_chart,
                      tint: C.amber50,
                      iconColor: C.amber600,
                      label: '预算控制',
                      sub: '已用64%',
                      subColor: C.amber600,
                      onTap: () => Navigator.of(context).pushNamed('/budget'),
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

  // ===================== 系统偏好与规则 =====================
  Widget _menuGroup() {
    Widget row({
      required IconData icon,
      double iconSize = 20,
      Color iconColor = C.slate700,
      required String title,
      bool mediumTitle = false,
      String? badge,
      required String sub,
      Widget? trailing,
      VoidCallback? onTap,
    }) {
      final content = Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: C.slate100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: MIcon(icon, size: iconSize, color: iconColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TS.body(
                                size: 15,
                                weight: mediumTitle
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: C.slate900)),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.emerald50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.emerald100),
                          ),
                          child: Text(badge,
                              style: TS.mono(
                                  size: 10,
                                  weight: FontWeight.w500,
                                  color: C.emerald600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 12, color: C.slate500)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const MIcon(MSym.chevron_right, size: 18, color: C.slate400),
          ],
        ),
      );
      if (onTap == null) return content;
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('系统偏好与规则',
              style: TS.body(size: 11, weight: FontWeight.w600, color: C.slate400)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 3),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 偏好设置 → /settings
              row(
                icon: MSym.tune,
                title: '偏好设置',
                badge: '6项配置',
                sub: '外观模式、数据同步、安全与规则',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('管理',
                        style: TS.body(size: 12, weight: FontWeight.w500, color: C.slate400)),
                    const SizedBox(width: 6),
                    const MIcon(MSym.chevron_right, size: 18, color: C.slate400),
                  ],
                ),
                onTap: () => Navigator.of(context).pushNamed('/settings'),
              ),
              const Divider(color: C.slate100, thickness: 1, height: 1),
              // 数据备份 → /backup
              row(
                icon: MSym.cloud_sync,
                title: '数据备份',
                sub: 'iCloud 云端同步 · 支持 CSV/JSON 导出',
                onTap: () => Navigator.of(context).pushNamed('/backup'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('已同步',
                        style: TS.mono(
                            size: 11, weight: FontWeight.w500, color: C.emerald600)),
                    const SizedBox(width: 6),
                    const MIcon(MSym.chevron_right, size: 18, color: C.slate400),
                  ],
                ),
              ),
              const Divider(color: C.slate100, thickness: 1, height: 1),
              // 关于我们 → /about
              row(
                icon: MSym.info,
                iconSize: 19,
                iconColor: C.slate600,
                title: '关于我们',
                mediumTitle: true,
                onTap: () => Navigator.of(context).pushNamed('/about'),
                sub: '使用文档、版本更新与用户社区',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('版本 2.4.0',
                        style: TS.mono(size: 11, color: C.slate400)),
                    const SizedBox(width: 6),
                    const MIcon(MSym.chevron_right, size: 18, color: C.slate400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== 底部安全声明 =====================
  Widget _securityFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MIcon(MSym.lock, size: 14, color: C.slate400),
          const SizedBox(width: 6),
          Text('智流安全计算引擎 · 端到端安全加密保护',
              style: TS.mono(size: 11, color: C.slate400)),
        ],
      ),
    );
  }
}
