import 'package:flutter/material.dart';

/// 字体家族与 Tailwind 字号体系（与设计稿一一对应）。
class F {
  F._();
  static const sans = 'Inter'; // font-sans / body-*
  static const display = 'SpaceGrotesk'; // font-display / headline / Space Grotesk
  static const mono = 'JetBrainsMono'; // font-label-code / JetBrains Mono
}

/// Tailwind 字号 → (fontSize, lineHeight)。
class TS {
  TS._();

  static const _map = <String, (double, double)>{
    '10': (10, 12),
    '11': (11, 13),
    '12': (12, 16), // text-xs
    '13': (13, 18),
    '14': (14, 20), // text-sm
    '15': (15, 20),
    '16': (16, 24), // text-base
    '17': (17, 24),
    '18': (18, 28), // text-lg
    '20': (20, 28), // text-xl
    '22': (22, 28),
    '24': (24, 32), // text-2xl
    '26': (26, 32),
    '28': (28, 34),
    '30': (30, 36), // text-3xl
    '32': (32, 38),
    '36': (36, 40), // text-4xl
    '40': (40, 44),
  };

  /// 生成与设计稿 `text-[Npx]` / `text-xs` 等价的 TextStyle。
  static TextStyle px(
    String size, {
    String? family,
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final (fs, lh) = _map[size] ?? (double.parse(size), double.parse(size) * 1.4);
    return TextStyle(
      fontFamily: family ?? F.sans,
      fontSize: fs,
      height: height ?? lh / fs,
      fontWeight: weight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // ---- 常用预设（Space Grotesk 标题）----
  static TextStyle headline({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.02,
  }) =>
      TextStyle(
        fontFamily: F.display,
        fontSize: size,
        height: 1.2,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        leadingDistribution: TextLeadingDistribution.even,
      );

  // ---- 常用预设（Inter 正文）----
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) =>
      TextStyle(
        fontFamily: F.sans,
        fontSize: size,
        height: height ?? 20 / 14,
        fontWeight: weight,
        color: color,
        leadingDistribution: TextLeadingDistribution.even,
      );

  // ---- 常用预设（JetBrains Mono 遥测）----
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = -0.01,
  }) =>
      TextStyle(
        fontFamily: F.mono,
        fontSize: size,
        height: 18 / 13,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        leadingDistribution: TextLeadingDistribution.even,
      );
}
