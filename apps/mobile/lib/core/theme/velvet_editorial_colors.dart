import 'package:flutter/material.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Theme-aware surface + typography colors (black canvas).
@immutable
class VelvetEditorialColors extends ThemeExtension<VelvetEditorialColors> {
  const VelvetEditorialColors({
    required this.ink,
    required this.parchment,
    required this.parchmentDeep,
    required this.parchmentLift,
    required this.line,
    required this.muted,
    required this.glassFill,
    required this.glassStrong,
    required this.surface,
    required this.onGlass,
  });

  final Color ink;
  final Color parchment;
  final Color parchmentDeep;
  final Color parchmentLift;
  final Color line;
  final Color muted;
  final Color glassFill;
  final Color glassStrong;
  final Color surface;
  final Color onGlass;

  static const light = VelvetEditorialColors(
    ink: VelvetTokens.ink,
    parchment: VelvetTokens.parchment,
    parchmentDeep: VelvetTokens.parchmentDeep,
    parchmentLift: VelvetTokens.parchmentLift,
    line: VelvetTokens.line,
    muted: VelvetTokens.muted,
    glassFill: VelvetTokens.glassFill,
    glassStrong: VelvetTokens.glassStrong,
    surface: VelvetTokens.parchment,
    onGlass: VelvetTokens.ink,
  );

  static const dark = VelvetEditorialColors(
    ink: VelvetTokens.darkInk,
    parchment: VelvetTokens.darkVoid,
    parchmentDeep: VelvetTokens.darkSurface,
    parchmentLift: VelvetTokens.darkLift,
    line: VelvetTokens.darkLine,
    muted: VelvetTokens.darkMuted,
    glassFill: VelvetTokens.darkGlassFill,
    glassStrong: VelvetTokens.darkGlassStrong,
    surface: VelvetTokens.darkVoid,
    onGlass: VelvetTokens.darkInk,
  );

  @override
  VelvetEditorialColors copyWith({
    Color? ink,
    Color? parchment,
    Color? parchmentDeep,
    Color? parchmentLift,
    Color? line,
    Color? muted,
    Color? glassFill,
    Color? glassStrong,
    Color? surface,
    Color? onGlass,
  }) {
    return VelvetEditorialColors(
      ink: ink ?? this.ink,
      parchment: parchment ?? this.parchment,
      parchmentDeep: parchmentDeep ?? this.parchmentDeep,
      parchmentLift: parchmentLift ?? this.parchmentLift,
      line: line ?? this.line,
      muted: muted ?? this.muted,
      glassFill: glassFill ?? this.glassFill,
      glassStrong: glassStrong ?? this.glassStrong,
      surface: surface ?? this.surface,
      onGlass: onGlass ?? this.onGlass,
    );
  }

  @override
  VelvetEditorialColors lerp(ThemeExtension<VelvetEditorialColors>? other, double t) {
    if (other is! VelvetEditorialColors) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return VelvetEditorialColors(
      ink: lerpColor(ink, other.ink),
      parchment: lerpColor(parchment, other.parchment),
      parchmentDeep: lerpColor(parchmentDeep, other.parchmentDeep),
      parchmentLift: lerpColor(parchmentLift, other.parchmentLift),
      line: lerpColor(line, other.line),
      muted: lerpColor(muted, other.muted),
      glassFill: lerpColor(glassFill, other.glassFill),
      glassStrong: lerpColor(glassStrong, other.glassStrong),
      surface: lerpColor(surface, other.surface),
      onGlass: lerpColor(onGlass, other.onGlass),
    );
  }
}

extension VelvetEditorialContext on BuildContext {
  VelvetEditorialColors get velvet =>
      Theme.of(this).extension<VelvetEditorialColors>() ?? VelvetEditorialColors.dark;
}
