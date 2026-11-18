import 'package:material_ui/material_ui.dart';

import '../core/msym.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/common.dart';
import '../widgets/m_icon.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          GlassHeader.back(title: '关于我们'),
          Expanded(
            child: SingleChildScrollView(
              padding: const PageContentInsets(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardX(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: C.emerald50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: MIcon(
                              MSym.account_balance_wallet,
                              size: 32,
                              color: C.emerald600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FlowAI Ledger',
                          style: TS.headline(size: 24, color: C.slate900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '智流记账',
                          style: TS.body(
                            size: 17,
                            weight: FontWeight.w600,
                            color: C.slate800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '日常消费与 AI 算力开支，双轨管理',
                          textAlign: TextAlign.center,
                          style: TS.body(size: 13, color: C.slate500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kCardGap),
                  CardX(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '关于我们',
                          style: TS.body(
                            size: 16,
                            weight: FontWeight.w600,
                            color: C.slate900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '智流记账将生活账单、AI 订阅与算力消费集中管理，帮助你了解每一笔支出，掌握预算与账户资产。',
                          style: TS.body(size: 14, color: C.slate600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kCardGap),
                  CardX(
                    child: Row(
                      children: [
                        Text(
                          '当前版本',
                          style: TS.body(size: 14, color: C.slate700),
                        ),
                        const Spacer(),
                        Text(
                          '2.4.0',
                          style: TS.mono(size: 13, color: C.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
