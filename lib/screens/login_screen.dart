import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

/// 登录页（设计稿 _4）— FlowAI Ledger 品牌展示 + 终端风登录容器。
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const double _loginControlHeight = 46;

  // bool _smsMode = false; // 验证模式 Tab：false=账号密码 true=短信快捷
  bool _pwdVisible = false;
  bool _remember = true;
  bool _agreed = true;
  bool _shakeAgreement = false; // 未勾选协议时的红圈提示
  bool _submitting = false;
  bool _submitted = false;
  // int _countdown = 0;
  // Timer? _timer;
  final _pwdController = TextEditingController(text: '');

  @override
  void dispose() {
    // _timer?.cancel();
    _pwdController.dispose();
    super.dispose();
  }

  // 短信验证暂时隐藏，保留倒计时实现便于恢复。
  // void _sendCode() {
  //   if (_countdown > 0) return;
  //   setState(() => _countdown = 60);
  //   _timer = Timer.periodic(const Duration(seconds: 1), (t) {
  //     if (!mounted) return t.cancel();
  //     setState(() => _countdown--);
  //     if (_countdown <= 0) t.cancel();
  //   });
  // }

  void _submit() {
    if (!_agreed) {
      setState(() => _shakeAgreement = true);
      Timer(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _shakeAgreement = false);
      });
      return;
    }
    setState(() {
      _submitting = true;
      _submitted = false;
    });
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
      });
      Timer(const Duration(milliseconds: 700), () {
        if (mounted && Navigator.of(context).canPop() == false) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (mounted) {
          Navigator.of(context).pushNamed('/home');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        child: Stack(
          children: [
            // ---- 环境光晕背景（blur-3xl 渐变圆）----
            const _AmbientGlow(),
            SingleChildScrollView(
              padding: const PageContentInsets(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.vertical -
                      kPageInset * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: kCardGap),
                    _loginCard(),
                    const SizedBox(height: kCardGap),
                    _agreementFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== 登录卡片 =====================
  Widget _loginCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.slate200.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部高亮渐变线
          Align(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              height: 2.5,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    C.emerald500.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: kCardGap),
          // 原始验证方式切换代码保留，短信快捷验证继续隐藏。
          // SegTabs(
          //   items: const [(MSym.key, '账号密码验证'), (MSym.sms, '短信快捷验证')],
          //   index: _smsMode ? 1 : 0,
          //   onChanged: (i) => setState(() => _smsMode = i == 1),
          // ),
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: C.emerald50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MIcon(MSym.key, size: 15, color: C.emerald700),
                const SizedBox(width: 4),
                Text(
                  '账号密码验证',
                  style: TS.body(
                    size: 14,
                    weight: FontWeight.w600,
                    color: C.emerald700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _accountField(),
          const SizedBox(height: 18),
          // if (_smsMode) _smsField() else _passwordField(),
          _passwordField(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rememberRow(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '忘记密码？',
                  style: TS.body(size: 12, color: C.slate500),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 6),
          // 生物识别 Passkey 行
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     GestureDetector(
          //       onTap: _bio,
          //       behavior: HitTestBehavior.opaque,
          //       child: Row(
          //         children: [
          //           const MIcon(MSym.fingerprint, size: 18, color: C.emerald600),
          //           const SizedBox(width: 6),
          //           Text('使用 Passkey / 生物识别解锁',
          //               style: TS.body(size: 12, weight: FontWeight.w500, color: C.slate600)),
          //         ],
          //       ),
          //     ),
          //     Text('遇到问题？', style: TS.body(size: 12, color: C.slate400)),
          //   ],
          // ),
          const SizedBox(height: 12),
          _submitBtn(),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('还没有账号？', style: TS.body(size: 12, color: C.slate500)),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/register'),
                child: Row(
                  children: [
                    Text(
                      '立即免费注册',
                      style: TS.body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: C.emerald600,
                      ),
                    ),
                    const MIcon(
                      MSym.arrow_forward,
                      size: 14,
                      color: C.emerald600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _divider(),
          const SizedBox(height: 12),
          const _SocialRow(),
        ],
      ),
    );
  }

  Widget _accountField() {
    return SizedBox(
      height: _loginControlHeight,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          FieldX(
            hint: '请输入手机号或邮箱',
            icon: MSym.person,
            initialText: 'neo.hacker@neuralflow.ai',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: MIcon(MSym.verified, size: 18, color: C.emerald600),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return SizedBox(
      height: _loginControlHeight,
      child: FieldX(
        controller: _pwdController,
        hint: '请输入登录密码',
        icon: MSym.lock,
        obscure: !_pwdVisible,
        mono: true,
        trailing: GestureDetector(
          onTap: () => setState(() => _pwdVisible = !_pwdVisible),
          child: MIcon(
            _pwdVisible ? MSym.visibility : MSym.visibility_off,
            size: 18,
            color: C.slate400,
          ),
        ),
      ),
    );
  }

  // 短信验证码输入区域暂时隐藏，保留原始实现。
  // Widget _smsField() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: FieldX(
  //           hint: '6位短信动态码',
  //           icon: MSym.shield,
  //           maxLength: 6,
  //           mono: true,
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       GestureDetector(
  //         onTap: _sendCode,
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
  //           decoration: BoxDecoration(
  //             color: _countdown > 0 ? C.slate100 : C.emerald50,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Text(
  //             _countdown > 0 ? '$_countdown s 后重发' : '获取验证码',
  //             style: TS.body(
  //               size: 12,
  //               weight: FontWeight.w600,
  //               color: _countdown > 0 ? C.slate400 : C.emerald600,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _rememberRow() {
    return GestureDetector(
      onTap: () => setState(() => _remember = !_remember),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _CheckSquare(size: 14, checked: _remember),
          const SizedBox(width: 6),
          Text('记住登录', style: TS.body(size: 12, color: C.slate500)),
        ],
      ),
    );
  }

  Widget _submitBtn() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _submitting ? 0.85 : 1,
      child: GestureDetector(
        onTap: _submitting ? null : _submit,
        child: Container(
          height: _loginControlHeight,
          decoration: BoxDecoration(
            color: _submitting ? C.emerald600 : C.emerald500,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: C.emerald500.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_submitting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              else
                MIcon(
                  _submitted ? MSym.check_circle : MSym.bolt,
                  size: 20,
                  color: Colors.white,
                  fill: true,
                ),
              const SizedBox(width: 8),
              Text(
                _submitting
                    ? '正在安全校验...'
                    : _submitted
                    ? '验证通过，进入中...'
                    : '立即登录',
                style: TS.body(
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: C.slate200, thickness: 1, height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '其他快捷登录方式',
            style: TS.body(
              size: 11,
              weight: FontWeight.w500,
              color: C.slate400,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: C.slate200, thickness: 1, height: 1),
        ),
      ],
    );
  }

  Widget _agreementFooter() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _shakeAgreement ? C.red500 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: _CheckSquare(size: 16, checked: _agreed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TS.body(size: 12, color: C.slate500, height: 1.6),
                children: const [
                  TextSpan(text: '我已阅读并同意 '),
                  TextSpan(
                    text: '《智流记账服务协议》',
                    style: TextStyle(
                      color: C.emerald600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: '、'),
                  TextSpan(
                    text: '《数据安全隐私保护条例》',
                    style: TextStyle(
                      color: C.emerald600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' 与 '),
                  TextSpan(
                    text: '《AI模型数据本地加密准则》',
                    style: TextStyle(
                      color: C.slate700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: '。未注册账号验证后将自动开通。'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 勾选方块（w-4 h-4 rounded bg-slate-200 peer-checked:bg-emerald-500）。
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
        color: checked ? C.emerald500 : C.slate200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? Center(
              child: MIcon(
                MSym.check,
                size: size - 3,
                color: Colors.white,
                fill: true,
              ),
            )
          : null,
    );
  }
}

/// 顶部环境光晕（absolute blur-3xl 渐变圆盘）。
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      C.emerald100.withValues(alpha: 0.7),
                      C.teal50.withValues(alpha: 0.5),
                      C.indigo100.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 380,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.emerald100.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 品牌展示区：发光 Logo + 标题 + Slogan。
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo（深色渐变圆角方块 + 钱包图标 + 机器人角标 + ping 状态点）
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    C.emerald400.withValues(alpha: 0.6),
                    C.teal300.withValues(alpha: 0.6),
                    C.indigo300.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [C.slate900, C.slate800, C.emerald950],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: MIcon(
                    MSym.account_balance_wallet,
                    size: 30,
                    color: C.emerald400,
                    fill: true,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: C.emerald500,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: MIcon(MSym.smart_toy, size: 9, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: kCardGap),
        // 标题
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'FlowAI',
              style: TS.headline(
                size: 24,
                weight: FontWeight.w700,
                color: C.slate900,
              ),
            ),
            const SizedBox(width: 6),
            ShaderMask(
              shaderCallback: (bounds) =>
                  const LinearGradient(colors: [C.emerald600, C.teal600])
                      .createShader(bounds),
              child: Text(
                'Ledger',
                style: TS.headline(
                  size: 24,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '智流记账',
              style: TS.body(
                size: 16,
                weight: FontWeight.w500,
                color: C.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: TS.body(size: 14, color: C.slate600, height: 1.5),
            children: const [
              TextSpan(text: '智能双轨记账 '),
              TextSpan(
                text: '·',
                style: TextStyle(
                  color: C.emerald500,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: ' 日常与AI算力开支一站式把控'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// 快捷社交登录三联按钮。
class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String, Color, Color)>[
      (MSym.chat, '微信登录', C.emerald50, C.emerald600),
      (MSym.ios, 'Apple ID', C.slate100, C.slate900),
      (MSym.cloud_sync, 'Google', C.sky50, C.sky600),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: kCardGap),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.slate200),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 3),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: items[i].$3,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: MIcon(items[i].$1, size: 20, color: items[i].$4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].$2,
                    style: TS.body(size: 12, color: C.slate600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
