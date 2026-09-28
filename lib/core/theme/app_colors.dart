import 'package:flutter/material.dart';

/// Oxlift "Volt" palette: near-black graphite with an electric lime accent.
abstract final class AppColors {
  // Brand
  static const volt = Color(0xFFC6FF3D);
  static const voltDeep = Color(0xFF4E7A00); // volt readable on light surfaces
  static const ice = Color(0xFF3DD8FF); // secondary data series
  static const ember = Color(0xFFFF7A45); // PRs, streaks, highlights

  // Dark surfaces
  static const ink = Color(0xFF0B0D10);
  static const graphite = Color(0xFF111418);
  static const slate = Color(0xFF171B21);
  static const slateHigh = Color(0xFF1F242C);
  static const slateHighest = Color(0xFF282E37);
  static const line = Color(0xFF2C323C);
  static const lineSoft = Color(0xFF20252D);

  // Dark text
  static const fog = Color(0xFFF2F4F7);
  static const mist = Color(0xFF9AA3AF);

  // Light surfaces
  static const paper = Color(0xFFF5F6F8);
  static const card = Color(0xFFFFFFFF);
  static const cardHigh = Color(0xFFECEEF2);
  static const cardHighest = Color(0xFFE2E5EA);
  static const lineLight = Color(0xFFD5D9E0);
  static const graphiteText = Color(0xFF5B6472);

  static const danger = Color(0xFFFF4D5E);
  static const dangerDeep = Color(0xFFC62837);
}
