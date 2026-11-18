import 'package:flutter/material.dart';

import '../core/msym.dart';

/// Material Symbols 图标组件。
///
/// 对应设计稿中的 `<span class="material-symbols-outlined ...">name</span>`。
/// [fill] 等价于 `font-variation-settings: "FILL" 1`（切换为实心字形）。
class MIcon extends StatelessWidget {
  const MIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.fill = false,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    var data = icon;
    if (fill && icon.fontFamily == 'MaterialSymbolsOutlined') {
      // 同名图标在两个字体资产中码点一致：查实心镜像表切换 FILL 字形。
      data = MSymFill.byCode[icon.codePoint] ?? icon;
    }
    return Icon(data, size: size, color: color);
  }
}
