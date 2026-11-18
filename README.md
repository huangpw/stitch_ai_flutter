# FlowAI Ledger 智流记账（stitch-ai-flutter）

依据 Stitch 设计稿（`glacial_cyber_finance` / `light_luxury_cyber_finance` 设计系统 + 移动端 HTML 屏幕）**1:1 还原**的 Flutter APP：日常消费与 AI 算力开支「双轨记账」一站式管理。

## 运行

```bash
cd stitch-ai-flutter
flutter pub get
flutter run                 # iOS / Android / macOS / Chrome 均可
```

Web 构建深链预览（逐屏直达）：

```bash
flutter build web --release
cd build/web && python3 -m http.server 8100
# 浏览器打开（390×844 视口最佳）：
#   http://localhost:8100/#/            登录
#   http://localhost:8100/#/register    注册
#   http://localhost:8100/#/home        记账（Tab）
#   http://localhost:8100/#/home-ai     AI订阅（Tab）
#   http://localhost:8100/#/home-stats  账单统计（Tab）
#   http://localhost:8100/#/home-profile 我的（Tab）
#   其余路由见下表
```

## 屏幕清单（页面 ↔ 设计稿目录）

| 设计稿 | 屏幕 | 路由 | 类型 |
|---|---|---|---|
| `_4` | 登录 | `/` | 入口 |
| `_1` | 注册 | `/register` | 推送 |
| `_13` | 日常记账 | `/home`（Tab 1） | Tab |
| `ai_2` | AI 订阅与充值 | `/home-ai`（Tab 2） | Tab |
| 新版统计参考 | 账单统计 | `/home-stats`（Tab 3） | Tab |
| `_10` | 预算控制中心 | `/budget` | 推送 |
| 新增 | 本月预算明细（记账页「预算分析」） | `/monthly-budget` | 推送 |
| 新增 | 本月收入明细（记账页「本月总收入」） | `/monthly-income` | 推送 |
| 新增 | 财务净结余明细（记账页「财务净结余」） | `/monthly-balance` | 推送 |
| `_2` | 个人中心 | `/home-profile`（Tab 4） | Tab |
| `_6` | 新增记账 | `/add-expense` | 推送 |
| `_11` | 新增日常收入 | `/add-income` | 推送 |
| `ai_3` | 记一笔 AI 消费 | `/ai-add` | 推送 |
| `_8` | 单笔消费详情 | `/tx-detail` | 推送 |
| `_9` | 账户资产管理 | `/assets` | 推送 |
| `_5` | 消息中心与通知 | `/notifications` | 推送 |
| `_7` | 偏好设置与系统 | `/settings` | 推送 |
| `_3` | 编辑个人资料 | `/edit-profile` | 推送 |
| `_12` | 账本与分类管理 | `/books` | 推送 |
| `_14` | 全局搜索 | `/search` | 推送 |
| `ai_1` | AI 充值与订阅详情 | `/ai-detail` | 推送 |
| `ai_4` | 智能票据识别 | `/ai-scan` | 推送 |
| `ai_5` | AI 算力月度预算超支预警 | `/ai-alert` | 推送 |

底部为设计稿同款悬浮胶囊导航：记账 / AI订阅 / [+]记一笔 / 统计 / 我的；「+」弹出 记日常支出 / 记日常收入 / 记 AI 消费 三选一。

账单统计按补充的 `code.html`、`DESIGN.md` 和截图实现：周期切换、总支出拆分、分类环形图、支出排行、预算达成和 AI 充值尖峰趋势；保留半透明悬浮底栏。旧预算控制页通过个人中心「预算控制」进入。当前统计数据沿用设计稿的 2025 年 5 月样例，未提供数据的区间显示空状态。Excel/PDF 导出生成实际文件，通过系统分享或 Web 下载交付。

## 设计系统还原要点

- **字体**：`Inter`（正文）、`Space Grotesk`（展示标题/大金额）、`JetBrains Mono`（遥测/币值标签）——全部以下载的 TTF 内置打包，离线可用；中文回退系统字体（与浏览器行为一致）。
- **图标**：内置 Material Symbols Outlined 字体（`lib/core/msym.dart` 生成 163 个设计稿用到的码点常量）；`MIcon(icon, fill: true)` 通过 `MSymFill` 镜像表切换 FILL 实心字形，等价 HTML 的 `font-variation-settings: "FILL" 1`。个别旧名图标（`wechat`、`phone_iphone` 等）回退 Flutter 内置 MaterialIcons。
- **调色板**：`lib/core/palette.dart` 完整映射 Tailwind slate/emerald/teal/indigo/violet/rose/amber/sky 等色阶 + DESIGN.md 设计令牌。
- **版式**：`lib/core/type.dart` 按 Tailwind 字号/行高映射 `TS.body / TS.headline / TS.mono / TS.px`。
- **组件**：`lib/widgets/common.dart`（卡片、呼吸状态点、分段切换、输入框、渐变按钮等）；`lib/widgets/nav_shell.dart` 悬浮胶囊导航。
- **统一顶栏**：全部页面共用 `GlassHeader`——内容高固定 **56px**、毛玻璃底 `rgba(248,249,255,0.85)` + 20px 模糊 + 0.5px 发丝线、标题**绝对居中 17px/w600/slate-900**；推送页统一 `GlassHeader.back()`（标准 40×40 命中区返回键 chevron_left 24px），动作按钮统一 `HeaderIconButton`（32px 圆形、slate-100/80 底、18px 图标、可选 `badgeColor` 角标）。Tab 页 leading 为头像。唯一例外：登录页为品牌画布，按设计稿无顶栏。
- **交互**：HTML `<script>` 行为均以 StatefulWidget 还原——验证码倒计时、密码可见切换、密码强度评分、Tab 过滤、金额联动换算、开关/滑块、账本手风琴、搜索即时过滤、OCR 扫描动画、预算超支进度等。

## 目录结构

```
lib/
├── main.dart              # 入口 + 路由表 + Web 深链
├── core/
│   ├── palette.dart       # Tailwind 全色阶 + 设计令牌
│   ├── type.dart          # 字体家族与字号体系
│   └── msym.dart          # Material Symbols 码点常量（生成文件）
├── widgets/
│   ├── m_icon.dart        # Material Symbols 图标组件（含 FILL）
│   ├── common.dart        # 通用组件库
│   └── nav_shell.dart     # 悬浮胶囊底部导航 + 快捷记一笔
└── screens/               # 各页面（每屏一文件）
assets/fonts/              # Inter / SpaceGrotesk / JetBrainsMono / MaterialSymbols
assets/images/avatar.jpg   # 设计稿头像素材
```

## 质量

- `flutter analyze`：0 error / 0 warning（仅 SDK 级 `material.dart` 弃用 info，本机 Flutter 预览版全局提示）
- `flutter test`：7 项测试通过（图标码点、实心镜像、登录页、统计入口/手机布局、周期空状态、Excel 金额、PDF 生成）
- Web（`--release`）构建通过，图标字体 tree-shake 正常
