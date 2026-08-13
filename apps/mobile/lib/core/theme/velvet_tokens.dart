import 'package:flutter/material.dart';

/// Design tokens — black canvas, lime primary (#B2D959).
abstract final class VelvetTokens {
  // ── Spacing rhythm ──────────────────────────────────────────────────────
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;
  static const double space96 = 96;

  static const double pageInset = 20;
  static const double plinthClearance = 108;

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double radiusXs = 8;
  static const double radiusSm = 14;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double radiusXl = 36;
  static const double radiusPill = 999;

  // ── Elevation & blur ──────────────────────────────────────────────────────
  static const double blurGlass = 28;
  static const double blurHeavy = 48;
  static const double blurAmbient = 80;

  // ── Motion durations ──────────────────────────────────────────────────────
  static const Duration motionInstant = Duration(milliseconds: 120);
  static const Duration motionFast = Duration(milliseconds: 220);
  static const Duration motionMedium = Duration(milliseconds: 380);
  static const Duration motionSlow = Duration(milliseconds: 620);
  static const Duration motionAmbient = Duration(seconds: 14);

  // ── Spring curves ─────────────────────────────────────────────────────────
  static const SpringDescription springTactile = SpringDescription(
    mass: 0.62,
    stiffness: 380,
    damping: 26,
  );

  static const SpringDescription springGentle = SpringDescription(
    mass: 0.85,
    stiffness: 220,
    damping: 24,
  );

  static const SpringDescription springSnappy = SpringDescription(
    mass: 0.45,
    stiffness: 520,
    damping: 28,
  );

  static const Curve easeEditorial = Curves.easeOutCubic;
  static const Curve easeReveal = Curves.easeOutQuart;

  // ── Typography scale ──────────────────────────────────────────────────────
  static const double displayHero = 52;
  static const double displayLarge = 42;
  static const double displayMedium = 34;
  static const double displaySmall = 28;
  static const double labelCaps = 11;

  // ── Palette: black canvas + lime primary ──────────────────────────────────
  /// Text on black.
  static const Color ink = Color(0xFFF4F6F0);
  static const Color inkSoft = Color(0xFFD8DCD0);

  /// Surfaces (legacy "parchment" names → black hierarchy).
  static const Color parchment = Color(0xFF000000);
  static const Color parchmentDeep = Color(0xFF121412);
  static const Color parchmentLift = Color(0xFF1A1C18);
  static const Color mist = Color(0xFF2A2E26);
  static const Color line = Color(0xFF2E322A);

  /// Primary — lime #B2D959.
  static const Color ember = Color(0xFFB2D959);
  static const Color emberDeep = Color(0xFF8FB33A);
  static const Color emberGlow = Color(0xFFC8E87A);
  static const Color emberSoft = Color(0xFF2A3518);

  /// On-primary (text/icons on lime buttons).
  static const Color onPrimary = Color(0xFF0A0C08);

  static const Color plum = Color(0xFF1E2420);
  static const Color plumSoft = Color(0xFF6B8F4A);
  static const Color sage = Color(0xFF7A9A5C);
  static const Color gold = Color(0xFFC4D98A);
  static const Color lapis = Color(0xFF4A6B8F);
  static const Color danger = Color(0xFFE05555);
  static const Color muted = Color(0xFF8B9280);

  static const Color glassFill = Color(0xCC121412);
  static const Color glassStrong = Color(0xE61A1C18);
  static const Color softShadow = Color(0x66000000);

  /// Mesh gradient stops for atmospheric backgrounds.
  static List<Color> meshPalette({double intensity = 1}) => [
    parchment,
    Color.lerp(parchment, emberSoft, 0.55 * intensity)!,
    Color.lerp(parchmentDeep, ember.withValues(alpha: 0.25), 0.35 * intensity)!,
    parchmentDeep,
  ];

  static List<BoxShadow> depthLift({double elevation = 1, Color? tint}) => [
    BoxShadow(
      color: (tint ?? softShadow).withValues(alpha: 0.35 + elevation * 0.08),
      blurRadius: 16 + elevation * 12,
      spreadRadius: -4,
      offset: Offset(0, 6 + elevation * 4),
    ),
    BoxShadow(
      color: ember.withValues(alpha: 0.06 * elevation),
      blurRadius: 32,
      spreadRadius: -8,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> emberHalo({double strength = 1}) => [
    BoxShadow(
      color: ember.withValues(alpha: 0.32 * strength),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Dark aliases (same black system) ──────────────────────────────────────
  static const Color darkVoid = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121412);
  static const Color darkLift = Color(0xFF1A1C18);
  static const Color darkLine = Color(0xFF2E322A);
  static const Color darkMuted = Color(0xFF8B9280);
  static const Color darkInk = Color(0xFFF4F6F0);
  static const Color darkGlassFill = Color(0xCC121412);
  static const Color darkGlassStrong = Color(0xE61A1C18);

  static List<Color> darkMeshPalette({double intensity = 1}) =>
      meshPalette(intensity: intensity);
}
