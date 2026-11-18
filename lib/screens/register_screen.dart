import 'dart:async';

import 'package:flutter/material.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 注册页（设计稿 _1）— 创建智流账户：账号信息、安全验证码、密码强度指示、
/// 邀请码折叠区、服务协议勾选与快捷授权通道。
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _pwdVisible = false;
  bool _referralOpen = false;
  bool _agreed = false;
  int _countdown = 0; // 0 = 空闲；>0 = 倒计时中
  bool _codeSentOnce = false; // 是否已发送过一次（影响按钮文案）
  Timer? _timer;
  final _pwdCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _pwdCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  // ---- 密码强度评分（与设计稿 <script> 逻辑一致）----
  int get _strengthScore {
    final val = _pwdCtrl.text;
    var score = 0;
    if (val.length >= 8) score++;
    if (RegExp('[A-Za-z]').hasMatch(val) && RegExp(r'\d').hasMatch(val)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(val) && val.length >= 10) score++;
    return score;
  }

  // ---- 验证码 60s 倒计时 ----
  void _sendCode() {
    if (_countdown > 0) return;
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        if (mounted) setState(() => _codeSentOnce = true);
      }
    });
  }

  void _register() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          // ---- 统一毛玻璃顶栏（返回 + 居中标题），与其他页面完全一致 ----
          GlassHeader.back(title: '注册账户'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _brandHeader(),
                  const SizedBox(height: 24),
                  _registerCard(),
                  const SizedBox(height: 16),
                  _termsRow(),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: '立即注册并开启体验',
                    icon: MSym.arrow_forward,
                    onTap: _register,
                    boxShadow: [
                      BoxShadow(
                        color: C.emerald500.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _loginRedirect(),
                  const SizedBox(height: 32),
                  _socialSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 头部品牌区 ----
  Widget _brandHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [C.emerald500, C.indigo600],
            ),
            boxShadow: [
              BoxShadow(
                color: C.emerald500.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: MIcon(
              MSym.account_balance_wallet,
              size: 28,
              color: Colors.white,
              fill: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('创建您的智流账户',
            style:
                TS.headline(size: 24, weight: FontWeight.w700, color: C.slate900)),
        const SizedBox(height: 4),
        Text('开启日常消费与 AI 算力开支的智能双轨把控',
            style: TS.body(size: 14, color: C.slate500)),
      ],
    );
  }

  TextStyle get _labelStyle => TS.px('11',
      family: F.mono, weight: FontWeight.w500, color: C.slate500, letterSpacing: 0.8);

  // ---- 注册表单卡片 ----
  Widget _registerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 账号信息
          Text('账号信息', style: _labelStyle),
          const SizedBox(height: 6),
          const FieldX(hint: '请输入手机号或邮箱', icon: MSym.alternate_email),
          const SizedBox(height: 16),
          // 安全验证
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('安全验证', style: _labelStyle),
              Text('支持短信与邮件同步',
                  style: TS.body(
                      size: 12, weight: FontWeight.w500, color: C.emerald600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: FieldX(
                  hint: '6位验证码',
                  icon: MSym.verified_user,
                  maxLength: 6,
                  mono: true,
                ),
              ),
              const SizedBox(width: 8),
              _sendCodeBtn(),
            ],
          ),
          const SizedBox(height: 16),
          // 设置密码
          Text('设置密码', style: _labelStyle),
          const SizedBox(height: 6),
          FieldX(
            controller: _pwdCtrl,
            hint: '设置 8-20 位登录密码',
            icon: MSym.lock,
            obscure: !_pwdVisible,
            onChanged: (_) => setState(() {}),
            trailing: GestureDetector(
              onTap: () => setState(() => _pwdVisible = !_pwdVisible),
              child: MIcon(
                _pwdVisible ? MSym.visibility : MSym.visibility_off,
                size: 20,
                color: C.slate400,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _strengthBlock(),
          const SizedBox(height: 16),
          // 确认密码
          Text('确认密码', style: _labelStyle),
          const SizedBox(height: 6),
          const FieldX(
            hint: '请再次输入登录密码',
            icon: MSym.check_circle,
            obscure: true,
          ),
          const SizedBox(height: 12),
          // 邀请码折叠区
          _referralSection(),
        ],
      ),
    );
  }

  Widget _sendCodeBtn() {
    final counting = _countdown > 0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: counting ? 0.6 : 1,
      child: GestureDetector(
        onTap: counting ? null : _sendCode,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: C.slate100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            counting
                ? '$_countdown s 重新发送'
                : (_codeSentOnce ? '重新获取' : '获取验证码'),
            maxLines: 1,
            style: TS.body(size: 12, weight: FontWeight.w600, color: C.slate700),
          ),
        ),
      ),
    );
  }

  // ---- 密码强度指示条 ----
  Widget _strengthBlock() {
    final val = _pwdCtrl.text;
    final empty = val.isEmpty;
    final score = _strengthScore;
    String label;
    Color color;
    FontWeight weight;
    if (empty) {
      label = '未输入';
      color = C.slate400;
      weight = FontWeight.w400;
    } else if (score == 1) {
      label = '弱强度';
      color = C.rose500;
      weight = FontWeight.w600;
    } else if (score == 2) {
      label = '中等强度';
      color = C.amber500;
      weight = FontWeight.w600;
    } else {
      label = '极佳强度';
      color = C.emerald500;
      weight = FontWeight.w600;
    }
    final filled = empty ? 0 : (score == 1 ? 1 : (score == 2 ? 2 : 3));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('密码强度', style: TS.body(size: 12, color: C.slate400)),
            Text(label,
                style: TS.px('11', family: F.mono, weight: weight, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < filled ? color : C.slate200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const MIcon(MSym.info, size: 14, color: C.slate400),
            const SizedBox(width: 4),
            Expanded(
              child: Text('建议包含大小写字母、数字及特殊字符组合',
                  style: TS.body(size: 12, color: C.slate400)),
            ),
          ],
        ),
      ],
    );
  }

  // ---- 邀请码（选填）折叠区 ----
  Widget _referralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _referralOpen = !_referralOpen),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const MIcon(MSym.card_giftcard, size: 18, color: C.indigo600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('填写邀请码（选填，获赠 100K 算力额度）',
                      style: TS.body(
                          size: 12, weight: FontWeight.w500, color: C.indigo600)),
                ),
                AnimatedRotation(
                  turns: _referralOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child:
                      const MIcon(MSym.expand_more, size: 18, color: C.indigo600),
                ),
              ],
            ),
          ),
        ),
        if (_referralOpen) ...[
          const SizedBox(height: 8),
          _RefField(controller: _referralCtrl),
        ],
      ],
    );
  }

  // ---- 服务协议勾选 ----
  Widget _termsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: _CheckSquare(checked: _agreed, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TS.body(size: 12, color: C.slate500, height: 1.7),
                children: const [
                  TextSpan(text: '我已阅读并同意 '),
                  TextSpan(
                      text: '《智流记账服务协议》',
                      style: TextStyle(
                          color: C.emerald600, fontWeight: FontWeight.w500)),
                  TextSpan(text: '、'),
                  TextSpan(
                      text: '《用户隐私保护条例》',
                      style: TextStyle(
                          color: C.emerald600, fontWeight: FontWeight.w500)),
                  TextSpan(text: '与 '),
                  TextSpan(
                      text: '《AI模型数据安全规范》',
                      style: TextStyle(
                          color: C.indigo600, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 登录跳转 ----
  Widget _loginRedirect() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('已有账号？', style: TS.body(size: 14, color: C.slate500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Text('直接登录',
                style: TS.body(
                    size: 14, weight: FontWeight.w600, color: C.emerald600)),
          ),
        ],
      ),
    );
  }

  // ---- 快捷授权通道 ----
  Widget _socialSection() {
    const items = <(IconData, String, Color)>[
      (MSym.laptop_mac, 'Apple ID', C.slate800),
      (MSym.chat, '微信登录', C.emerald600),
      (MSym.deployed_code, 'Google', C.indigo600),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: C.slate200, height: 1, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('快捷授权通道',
                  style: TS.px('11',
                      family: F.mono,
                      weight: FontWeight.w500,
                      color: C.slate400,
                      letterSpacing: 2)),
            ),
            const Expanded(child: Divider(color: C.slate200, height: 1, thickness: 1)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0D000000), blurRadius: 3),
                    ],
                  ),
                  child: Column(
                    children: [
                      MIcon(items[i].$1, size: 22, color: items[i].$3),
                      const SizedBox(height: 4),
                      Text(items[i].$2,
                          style: TS.body(
                              size: 12,
                              weight: FontWeight.w500,
                              color: C.slate800)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// 勾选方块（w-4 h-4 rounded，参考 login_screen 的 _CheckSquare 样式）。
class _CheckSquare extends StatelessWidget {
  const _CheckSquare({required this.checked, this.size = 16});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? C.emerald500 : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: checked ? C.emerald500 : C.slate300,
          width: 1,
        ),
      ),
      child: checked
          ? Center(
              child: MIcon(MSym.check,
                  size: size - 6, color: Colors.white, fill: true))
          : null,
    );
  }
}

/// 邀请码输入框（bg-indigo-50/50 + indigo focus 光环的定制 Field）。
class _RefField extends StatefulWidget {
  const _RefField({this.controller});

  final TextEditingController? controller;

  @override
  State<_RefField> createState() => _RefFieldState();
}

class _RefFieldState extends State<_RefField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
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
              ? C.indigo500.withValues(alpha: 0.55)
              : C.slate200,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: C.indigo500.withValues(alpha: 0.18),
                  blurRadius: 0,
                  spreadRadius: 2.5,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        cursorColor: C.indigo500,
        textCapitalization: TextCapitalization.characters,
        style: TS.mono(size: 12, weight: FontWeight.w400, color: C.slate800),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor:
              focused ? Colors.white : C.indigo50.withValues(alpha: 0.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const MIcon(MSym.tag, size: 18, color: C.slate400),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 36, minHeight: 0),
          hintText: '输入 6-8 位专属邀请码',
          hintStyle:
              TS.mono(size: 12, weight: FontWeight.w400, color: C.slate400),
        ),
      ),
    );
  }
}
