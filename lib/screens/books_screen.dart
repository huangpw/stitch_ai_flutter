import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 账本管理（设计稿 _12）— 多账本空间、协同成员权限、二级消费
/// 分类体系（日常 + AI 双轨）、云端同步导出，底部「新建协同 / 专项账本」。
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // 二级分类启用状态（与 HTML checkbox 默认全选一致）
  final Map<String, bool> _dailyOn = {
    '餐饮美食': true,
    '交通出行': true,
    '日用百货': true,
    '住房租金': true,
    '数码娱乐': true,
    '医疗健康': true,
  };
  final Map<String, bool> _aiOn = {
    '大模型API': true,
    'SaaS周期订阅': true,
    'GPU算力租用': true,
    '开发工具套件': true,
  };
  final List<String> _roles = ['记账员', '只读成员']; // 成员 2 / 3 的权限

  // 顶部 Toast（复刻 #toast 药丸提示）
  bool _toastVisible = false;
  String _toastText = '操作成功';
  IconData _toastIcon = MSym.check_circle;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showToast(String text, {IconData icon = MSym.check_circle}) {
    _toastTimer?.cancel();
    setState(() {
      _toastText = text;
      _toastIcon = icon;
      _toastVisible = true;
    });
    _toastTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _toastVisible = false);
    });
  }

  // ---- 新建账本（弹层）----
  Future<void> _openAddLedgerSheet() async {
    final name = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AddLedgerSheet(),
    );
    if (!mounted) return;
    if (name != null && name.isNotEmpty) {
      _showToast('已创建账本「$name」', icon: MSym.add_circle);
    }
  }

  // ---- 添加自定义子分类（对话框）----
  Future<void> _openAddCategoryDialog() async {
    final name = await showDialog<String>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => const _AddCategoryDialog(),
    );
    if (!mounted) return;
    if (name != null && name.isNotEmpty) {
      _showToast('已添加自定义子分类「$name」', icon: MSym.category);
    }
  }

  void _copyInviteLink() {
    Clipboard.setData(
      const ClipboardData(text: 'https://flowai.ledger.app/invite/GB3K92'),
    );
    _showToast('邀请链接已复制，可分享好友加入', icon: MSym.content_copy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Stack(
        children: [
          Column(
            children: [
              // ---- 统一毛玻璃顶栏（标准返回键 + 标题 + 新增）----
              GlassHeader.back(
                title: '账本管理',
                actions: [
                  HeaderIconButton(icon: MSym.add, onTap: _openAddLedgerSheet),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ledgerSectionHeader(),
                      const SizedBox(height: 8),
                      _ledgerCardMain(),
                      const SizedBox(height: 14),
                      _ledgerCardAi(),
                      const SizedBox(height: 14),
                      _ledgerCardFamily(),
                      const SizedBox(height: 14),
                      _memberCard(),
                      const SizedBox(height: 14),
                      _categoryCard(),
                      const SizedBox(height: 14),
                      _cloudCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 顶部 Toast 药丸（fixed top-16 居中；悬浮层用 SafeArea 补偿顶栏内已消耗的顶部安全区）
          Positioned(
            top: 64,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _toastVisible ? 1 : 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: C.inverseSurface,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 16,
                              offset: Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MIcon(_toastIcon, size: 18, color: C.emerald500),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _toastText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TS.body(size: 13, color: C.indigo50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _footerBar(),
    );
  }

  // ===================== 1. 账本空间 =====================
  Widget _ledgerSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          const MIcon(MSym.account_balance_wallet, size: 18, color: C.emerald700),
          const SizedBox(width: 6),
          Text('账本空间 (3)',
              style: TS.body(size: 15, weight: FontWeight.w700, color: C.slate900)),
          const Spacer(),
          Text('物理隔离与多端记账', style: TS.body(size: 12, color: C.slate500)),
        ],
      ),
    );
  }

  /// 账本卡片外壳。
  Widget _ledgerShell({
    required Widget child,
    Border border = const Border(),
    bool glow = false,
    bool clip = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: border == const Border()
            ? Border.all(color: C.indigo50)
            : border,
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: Stack(
        children: [
          if (glow)
            Positioned(
              right: -32,
              top: -32,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.emerald500.withValues(alpha: 0.1),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }

  Widget _ledgerTopRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String name,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required String desc,
    required Widget trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: MIcon(icon, size: 22, color: iconColor)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TS.body(
                            size: 15, weight: FontWeight.w700, color: C.slate900)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(badge,
                        style: TS.mono(
                            size: 11, weight: FontWeight.w500, color: badgeColor)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TS.body(size: 12, color: C.slate500)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }

  /// 「使用中」徽标（呼吸点）。
  Widget _activeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: C.emerald700.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(color: C.emerald500, size: 6),
          const SizedBox(width: 4),
          Text('使用中',
              style: TS.body(size: 12, weight: FontWeight.w600, color: C.emerald700)),
        ],
      ),
    );
  }

  /// 「切换进入」按钮。
  Widget _switchBtn(String name, Color color) {
    return GestureDetector(
      onTap: () => _showToast('已切换至「$name」空间',
          // HTML 中 toast 图标为 switch_access_shortcut，msym 未收录，用最接近的 swap_horiz
          icon: MSym.swap_horiz),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('切换进入',
            style: TS.body(size: 12, weight: FontWeight.w500, color: color)),
      ),
    );
  }

  /// 三列核心开支指标（bg-[#f2f3ff]）。
  Widget _statsGrid(List<(String, String, Color)> stats) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: C.indigo50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stats[i].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 11, color: C.slate500)),
                  const SizedBox(height: 2),
                  Text(stats[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.mono(
                          size: 15, weight: FontWeight.w700, color: stats[i].$3)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 底部协同成员与操作行。
  Widget _ledgerMetaRow({
    required List<String> avatarLabels,
    required List<Color> avatarColors,
    required String note,
    required String? defaultLabel,
    required VoidCallback? onDefault,
    required Color configColor,
    required String ledgerName,
  }) {
    Widget defaultBtn() => GestureDetector(
          onTap: onDefault,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: C.indigo50.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(defaultLabel!,
                style: TS.body(
                    size: 12,
                    weight: defaultLabel == '默认'
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: C.slate500)),
          ),
        );

    Widget configBtn() => GestureDetector(
          onTap: () => _showToast('配置「$ledgerName」参数与权限', icon: MSym.tune),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text('配置',
                  style: TS.body(size: 12, weight: FontWeight.w600, color: configColor)),
              const SizedBox(width: 2),
              MIcon(MSym.tune, size: 14, color: configColor),
            ],
          ),
        );

    return Row(
      children: [
        _AvatarStack(avatarLabels, avatarColors),
        const SizedBox(width: 6),
        Expanded(
          child: Text(note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TS.body(size: 12, color: C.slate500)),
        ),
        const SizedBox(width: 8),
        if (defaultLabel != null) ...[
          defaultBtn(),
          const SizedBox(width: 8),
        ],
        configBtn(),
      ],
    );
  }

  /// 账本 1：个人日常账本（主账本 / 使用中）。
  Widget _ledgerCardMain() {
    return _ledgerShell(
      // border-2 border-primary/20
      border: Border.all(
          color: C.emerald700.withValues(alpha: 0.2), width: 2),
      glow: true,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ledgerTopRow(
            icon: MSym.wallet,
            iconBg: C.emerald700.withValues(alpha: 0.1),
            iconColor: C.emerald700,
            name: '个人日常账本',
            badge: '主账本',
            badgeBg: C.emerald700.withValues(alpha: 0.1),
            badgeColor: C.emerald700,
            desc: '默认汇集微信/支付宝常规日常开销',
            trailing: _activeBadge(),
          ),
          const SizedBox(height: 12),
          _statsGrid(const [
            ('当月总支出', '¥8,450.00', C.slate900),
            ('记录笔数', '42 笔', C.slate900),
            ('预算占用', '56.3%', C.emerald700),
          ]),
          const SizedBox(height: 10),
          _ledgerMetaRow(
            avatarLabels: const ['我'],
            avatarColors: const [C.emerald700],
            note: '个人专属 (无需协作)',
            defaultLabel: '默认',
            onDefault: () => _showToast('当前已为默认主账本'),
            configColor: C.emerald700,
            ledgerName: '个人日常账本',
          ),
        ],
      ),
    );
  }

  /// 账本 2：AI研发与算力独立账本。
  Widget _ledgerCardAi() {
    return _ledgerShell(
      border: Border.all(color: C.violet600.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ledgerTopRow(
            icon: MSym.memory,
            iconBg: C.violet600.withValues(alpha: 0.1),
            iconColor: C.violet600,
            name: 'AI研发与算力独立账本',
            badge: '双轨隔离',
            badgeBg: C.violet100,
            badgeColor: C.indigo950,
            desc: 'GPU算力、LLM Token与开发者订阅',
            trailing: _switchBtn('AI研发与算力独立账本', C.violet600),
          ),
          const SizedBox(height: 12),
          _statsGrid(const [
            ('本月算力消耗', '¥1,248.50', C.violet600),
            ('外币折算', '\$172.20', C.slate900),
            ('API通道', '6 个服务', C.slate500),
          ]),
          const SizedBox(height: 10),
          _ledgerMetaRow(
            avatarLabels: const ['我', '合'],
            avatarColors: const [C.emerald700, C.violet600],
            note: '2人共享权限 (管理员)',
            defaultLabel: '设为主账',
            onDefault: () => _showToast('已设「AI研发与算力独立账本」为默认主账本',
                icon: MSym.verified),
            configColor: C.violet600,
            ledgerName: 'AI研发与算力独立账本',
          ),
        ],
      ),
    );
  }

  /// 账本 3：合租家庭协同账本。
  Widget _ledgerCardFamily() {
    return _ledgerShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ledgerTopRow(
            icon: MSym.group_work,
            iconBg: C.teal700.withValues(alpha: 0.1),
            iconColor: C.teal700,
            name: '合租家庭协同账本',
            badge: '多方AA',
            badgeBg: C.cyan100,
            badgeColor: C.teal700,
            desc: '房租水电网费、公共物资与买菜结算',
            trailing: _switchBtn('合租家庭协同账本', C.teal700),
          ),
          const SizedBox(height: 12),
          _statsGrid(const [
            ('本月公共开销', '¥4,320.00', C.slate900),
            ('待分摊结算', '¥1,440.00', C.amber500),
            ('分摊规则', '均摊 3人', C.slate500),
          ]),
          const SizedBox(height: 10),
          _ledgerMetaRow(
            avatarLabels: const ['我', '李', '陈'],
            avatarColors: const [C.emerald700, C.teal700, C.fuchsia500],
            note: '3人协同 (记账员)',
            defaultLabel: '设为主账',
            onDefault: () => _showToast('已设「合租家庭协同账本」为默认主账本',
                icon: MSym.verified),
            configColor: C.teal700,
            ledgerName: '合租家庭协同账本',
          ),
        ],
      ),
    );
  }

  // ===================== 2. 协同成员权限与分摊 =====================
  Widget _memberCard() {
    Widget member({
      required String avatar,
      required Color avatarColor,
      required String name,
      required String chip,
      required Color chipBg,
      required Color chipColor,
      required String sub,
      required Widget trailing,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(avatar,
                    style: TS.body(
                        size: 12, weight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
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
                                size: 13,
                                weight: FontWeight.w600,
                                color: C.slate900)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(chip,
                            style: TS.body(
                                size: 10, weight: FontWeight.w500, color: chipColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 11, color: C.slate500)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
          ),
        );
      }

    Widget roleSelect(int index) {
      return PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        initialValue: _roles[index],
        onSelected: (v) {
          setState(() => _roles[index] = v);
          _showToast('已更新成员权限为 $v');
        },
        itemBuilder: (_) => const ['记账员', '管理员', '只读成员']
            .map((v) => PopupMenuItem<String>(
                  value: v,
                  height: 34,
                  child: Text(v,
                      style: TS.body(
                          size: 12, weight: FontWeight.w500, color: C.slate800)),
                ))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: C.indigo50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_roles[index],
                  style:
                      TS.body(size: 12, weight: FontWeight.w500, color: C.slate900)),
              const SizedBox(width: 2),
              const MIcon(MSym.arrow_drop_down, size: 14, color: C.slate500),
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
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const MIcon(MSym.badge, size: 20, color: C.violet500),
              const SizedBox(width: 6),
              Text('协同成员权限与分摊',
                  style:
                      TS.body(size: 15, weight: FontWeight.w700, color: C.slate900)),
              const Spacer(),
              Text('已选账本: 合租家庭', style: TS.body(size: 11, color: C.slate500)),
            ],
          ),
          const SizedBox(height: 4),
          member(
            avatar: '我',
            avatarColor: C.emerald700,
            name: '你 (Alex)',
            chip: '创建者',
            chipBg: C.emerald700.withValues(alpha: 0.1),
            chipColor: C.emerald700,
            sub: '拥有全部管理与导出权限',
            trailing: Text('管理员',
                style: TS.body(size: 12, weight: FontWeight.w600, color: C.emerald700)),
          ),
          Divider(
              color: C.indigo100.withValues(alpha: 0.6),
              thickness: 1,
              height: 1),
          member(
            avatar: '李',
            avatarColor: C.teal700,
            name: '李文 (合租室友)',
            chip: 'AA均摊 33%',
            chipBg: C.indigo50,
            chipColor: C.slate600,
            sub: '支持自由记账与票据上传',
            trailing: roleSelect(0),
          ),
          Divider(
              color: C.indigo100.withValues(alpha: 0.6),
              thickness: 1,
              height: 1),
          member(
            avatar: '陈',
            avatarColor: C.fuchsia500,
            name: '陈小凡 (财务监督)',
            chip: 'AA均摊 33%',
            chipBg: C.indigo50,
            chipColor: C.slate600,
            sub: '仅查阅明细与报销审批',
            trailing: roleSelect(1),
          ),
          const SizedBox(height: 4),
          // 邀请操作入口
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x99E0E7FF)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showToast('已生成微信邀请卡片，可直接发送好友',
                        // HTML toast 图标为 share，msym 未收录，用最接近的 ios_share
                        icon: MSym.ios_share),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: C.indigo50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MIcon(MSym.wechat, size: 16, color: C.emerald500),
                          const SizedBox(width: 6),
                          Text('微信邀请新成员',
                              style: TS.body(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: C.slate900)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _copyInviteLink,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: C.indigo50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MIcon(MSym.link, size: 16, color: C.emerald700),
                          const SizedBox(width: 6),
                          Text('复制专属加入链接',
                              style: TS.body(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: C.slate900)),
                        ],
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

  // ===================== 3. 二级消费分类体系 =====================
  Widget _categoryCard() {
    // 日常分类磁贴
    Widget dailyTile(String name, IconData icon, Color iconBg, Color iconColor,
        String desc) {
      final on = _dailyOn[name] ?? true;
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.indigo50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: MIcon(icon, size: 18, color: iconColor)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(
                          size: 13, weight: FontWeight.w600, color: C.slate900)),
                  Text(desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 10, color: C.slate500)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            _MiniSwitch(
              value: on,
              onChanged: (v) {
                setState(() => _dailyOn[name] = v);
                _showToast(v
                    ? '「$name」已启用并显示在记账首选'
                    : '「$name」已在记账选择中隐藏',
                    icon: v ? MSym.check_circle : MSym.visibility_off);
              },
            ),
          ],
        ),
      );
    }

    // AI 分类磁贴
    Widget aiTile(String name, IconData icon, Color iconBg, String desc) {
      final on = _aiOn[name] ?? true;
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.violet600.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.violet600.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: MIcon(icon, size: 18, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(
                          size: 13, weight: FontWeight.w600, color: C.slate900)),
                  Text(desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TS.body(size: 10, color: C.slate500)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            _MiniSwitch(
              value: on,
              activeColor: C.violet600,
              onChanged: (v) {
                setState(() => _aiOn[name] = v);
                _showToast(v
                    ? '「$name」已启用并显示在记账首选'
                    : '「$name」已在记账选择中隐藏',
                    icon: v ? MSym.check_circle : MSym.visibility_off);
              },
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const MIcon(MSym.category, size: 20, color: C.emerald700),
              const SizedBox(width: 6),
              Text('二级消费分类体系',
                  style:
                      TS.body(size: 15, weight: FontWeight.w700, color: C.slate900)),
              const Spacer(),
              GestureDetector(
                onTap: _openAddCategoryDialog,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const MIcon(MSym.add_circle, size: 15, color: C.emerald700),
                    const SizedBox(width: 2),
                    Text('添加子类',
                        style: TS.body(
                            size: 12,
                            weight: FontWeight.w600,
                            color: C.emerald700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3.1 日常生活消费类别
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: C.emerald700, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text('日常生活消费类别 (6大类)',
                  style: TS.body(size: 12, weight: FontWeight.w700, color: C.slate500)),
              const Spacer(),
              Text('支持按需拖拽与隐藏', style: TS.body(size: 11, color: C.slate500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: dailyTile('餐饮美食', MSym.restaurant,
                      C.amber500.withValues(alpha: 0.15), C.amber500,
                      '早午晚/外卖/咖啡饮品')),
              const SizedBox(width: 8),
              Expanded(
                  child: dailyTile('交通出行', MSym.directions_subway,
                      C.emerald700.withValues(alpha: 0.15), C.emerald700,
                      '打车/地铁/加油保养')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: dailyTile('日用百货', MSym.shopping_bag,
                      C.cyan500.withValues(alpha: 0.15), C.cyan500,
                      '商超生活/居家杂货')),
              const SizedBox(width: 8),
              Expanded(
                  child: dailyTile('住房租金', MSym.home,
                      C.blue500.withValues(alpha: 0.15), C.blue500,
                      '房租/物业/水电宽带')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: dailyTile('数码娱乐', MSym.sports_esports,
                      C.violet600.withValues(alpha: 0.15), C.violet600,
                      '游戏影音/电子数码')),
              const SizedBox(width: 8),
              Expanded(
                  child: dailyTile('医疗健康', MSym.favorite,
                      C.rose500.withValues(alpha: 0.15), C.rose500,
                      '体检/购药门诊/健身')),
            ],
          ),
          const SizedBox(height: 16),
          // 3.2 AI算力与周期订阅专属
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x99E0E7FF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: C.violet600, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('AI算力与周期订阅专属 (4大类)',
                        style: TS.body(
                            size: 12, weight: FontWeight.w700, color: C.violet600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: C.violet600.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('智能分流已绑定',
                          style: TS.body(
                              size: 11,
                              weight: FontWeight.w500,
                              color: C.violet600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: aiTile('大模型API', MSym.psychology, C.violet600,
                            'OpenAI/Claude/DeepSeek')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: aiTile('SaaS周期订阅', MSym.autorenew, C.violet500,
                            'GitHub/Figma/Notion')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: aiTile('GPU算力租用', MSym.developer_board,
                            C.violet600, 'AWS/RunPod/AutoDL')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: aiTile('开发工具套件', MSym.code, C.violet500,
                            'JetBrains/Cursor/Vercel')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 4. 云端同步与导出 =====================
  Widget _cloudCard() {
    Widget exportBtn(IconData icon, Color iconColor, String label,
        String fileType) {
      return Expanded(
        child: GestureDetector(
          onTap: () => _showToast('正在生成 $fileType 格式账单报销文件...',
              icon: MSym.download),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: C.indigo50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.indigo100.withValues(alpha: 0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MIcon(icon, size: 17, color: iconColor),
                const SizedBox(width: 6),
                Text(label,
                    style: TS.body(
                        size: 12, weight: FontWeight.w600, color: C.slate900)),
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
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const MIcon(MSym.cloud_done, size: 20, color: C.emerald700),
              const SizedBox(width: 6),
              Text('云端同步与独立报销归档',
                  style:
                      TS.body(size: 15, weight: FontWeight.w700, color: C.slate900)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.emerald700.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: C.emerald500, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('实时双向同步',
                        style: TS.body(
                            size: 11,
                            weight: FontWeight.w500,
                            color: C.emerald700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '各账本数据在本地安全加密并多端实时备份。支持将指定账本月度流水一键导出为标准的报销单据表格。',
            style: TS.body(size: 12, color: C.slate500, height: 1.625),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              exportBtn(MSym.table_view, C.green600, '导出 Excel 报销单', 'Excel'),
              const SizedBox(width: 8),
              exportBtn(MSym.description, C.emerald700, '导出标准 CSV 数据', 'CSV'),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 底部固定主操作栏 =====================
  Widget _footerBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCanvas.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: C.indigo50.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: GestureDetector(
            onTap: _openAddLedgerSheet,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [C.emerald500, C.emerald700]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: C.emerald500.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MIcon(MSym.add_circle, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('新建协同 / 专项账本',
                      style: TS.headline(
                          size: 15, weight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 头像叠放组（-space-x-1.5 白描边圆形头像）。
class _AvatarStack extends StatelessWidget {
  const _AvatarStack(this.labels, this.colors);

  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    const size = 24.0;
    const step = 18.0;
    return SizedBox(
      width: size + step * (labels.length - 1),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < labels.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(labels[i],
                      style: TS.body(
                          size: 10, weight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 小号 toggle 开关（w-7 h-4，分类磁贴用）。
class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({
    required this.value,
    required this.onChanged,
    this.activeColor = C.emerald700,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 28,
        height: 16,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: value ? activeColor : C.indigo100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// 新建账本底部弹层。
class _AddLedgerSheet extends StatefulWidget {
  const _AddLedgerSheet();

  @override
  State<_AddLedgerSheet> createState() => _AddLedgerSheetState();
}

class _AddLedgerSheetState extends State<_AddLedgerSheet> {
  final _nameCtrl = TextEditingController();
  int _type = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _create() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('请先输入账本名称'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: C.inverseSurface,
        ),
      );
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x14000000), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('新建账本',
                      style: TS.headline(size: 17, color: C.slate900)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const MIcon(MSym.close, size: 20, color: C.slate400),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('物理隔离双轨账目，可邀请成员协同分摊',
                  style: TS.body(size: 12, color: C.slate500)),
              const SizedBox(height: 16),
              FieldX(
                controller: _nameCtrl,
                hint: '例如：旅行专项账本',
                icon: MSym.wallet,
              ),
              const SizedBox(height: 12),
              SegTabs(
                items: const [
                  (MSym.account_balance_wallet, '日常账本'),
                  (MSym.memory, 'AI算力账本'),
                  (MSym.groups, '协同账本'),
                ],
                index: _type,
                onChanged: (i) => setState(() => _type = i),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: '创建账本',
                icon: MSym.add_circle,
                onTap: _create,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 添加自定义子分类对话框。
class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('添加自定义子分类',
                style: TS.headline(size: 16, color: C.slate900)),
            const SizedBox(height: 4),
            Text('挂载在当前账本的二级消费分类下',
                style: TS.body(size: 12, color: C.slate500)),
            const SizedBox(height: 16),
            FieldX(
              controller: _nameCtrl,
              hint: '例如：宠物用品',
              icon: MSym.tag,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: C.slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('取消',
                            style: TS.body(
                                size: 14,
                                weight: FontWeight.w500,
                                color: C.slate600)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pop(_nameCtrl.text.trim()),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [C.emerald500, C.teal500]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('添加',
                            style: TS.body(
                                size: 14,
                                weight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
