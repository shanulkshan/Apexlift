import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens for the "liquid glass" surfaces, per brightness.
///
/// Glass = translucent gradient fill + a light-catching rim (bright top-left,
/// fading toward the bottom-right) + optional backdrop blur for surfaces that
/// float over scrolling content.
@immutable
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.fillTop,
    required this.fillBottom,
    required this.rimBright,
    required this.rimDim,
    required this.shadow,
    required this.blurSigma,
    required this.backgroundBase,
    required this.orbs,
  });

  final Color fillTop;
  final Color fillBottom;
  final Color rimBright;
  final Color rimDim;
  final Color shadow;
  final double blurSigma;

  /// Ambient background behind all glass.
  final Color backgroundBase;
  final List<Color> orbs;

  static const dark = GlassTheme(
    fillTop: Color(0x24FFFFFF), // 14% white
    fillBottom: Color(0x0AFFFFFF), // 4% white
    rimBright: Color(0x66FFFFFF),
    rimDim: Color(0x0FFFFFFF),
    shadow: Color(0x66000000),
    blurSigma: 24,
    backgroundBase: AppColors.ink,
    orbs: [
      Color(0x8C7FB800), // deep volt
      Color(0x731B8FB0), // ice
      Color(0x598A3AB9), // violet
      Color(0x4DFF7A45), // ember
    ],
  );

  static const light = GlassTheme(
    fillTop: Color(0xB3FFFFFF), // 70% white
    fillBottom: Color(0x66FFFFFF), // 40% white
    rimBright: Color(0xF2FFFFFF),
    rimDim: Color(0x40FFFFFF),
    shadow: Color(0x1F1A2233),
    blurSigma: 24,
    backgroundBase: Color(0xFFEFF2F5),
    orbs: [
      Color(0x80C6FF3D), // volt
      Color(0x663DD8FF), // ice
      Color(0x4DB78CFF), // lilac
      Color(0x4DFFB38A), // peach
    ],
  );

  static GlassTheme of(BuildContext context) =>
      Theme.of(context).extension<GlassTheme>() ?? dark;

  @override
  GlassTheme copyWith({
    Color? fillTop,
    Color? fillBottom,
    Color? rimBright,
    Color? rimDim,
    Color? shadow,
    double? blurSigma,
    Color? backgroundBase,
    List<Color>? orbs,
  }) =>
      GlassTheme(
        fillTop: fillTop ?? this.fillTop,
        fillBottom: fillBottom ?? this.fillBottom,
        rimBright: rimBright ?? this.rimBright,
        rimDim: rimDim ?? this.rimDim,
        shadow: shadow ?? this.shadow,
        blurSigma: blurSigma ?? this.blurSigma,
        backgroundBase: backgroundBase ?? this.backgroundBase,
        orbs: orbs ?? this.orbs,
      );

  @override
  GlassTheme lerp(covariant GlassTheme? other, double t) {
    if (other == null) return this;
    return GlassTheme(
      fillTop: Color.lerp(fillTop, other.fillTop, t)!,
      fillBottom: Color.lerp(fillBottom, other.fillBottom, t)!,
      rimBright: Color.lerp(rimBright, other.rimBright, t)!,
      rimDim: Color.lerp(rimDim, other.rimDim, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      orbs: [
        for (var i = 0; i < orbs.length; i++)
          Color.lerp(orbs[i], other.orbs[i % other.orbs.length], t)!,
      ],
    );
  }
}
