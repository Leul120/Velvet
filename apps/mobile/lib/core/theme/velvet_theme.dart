import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Black canvas design system — lime (#B2D959) primary, Syne display.
class VelvetTheme {
  // Legacy aliases → tokens (preserves existing references)
  static const Color ink = VelvetTokens.ink;
  static const Color night = VelvetTokens.parchment;
  static const Color nightSoft = VelvetTokens.parchment;
  static const Color nightLift = VelvetTokens.parchmentLift;
  static const Color porcelain = VelvetTokens.parchmentDeep;
  static const Color mistSage = VelvetTokens.mist;
  static const Color mistSlate = VelvetTokens.line;
  static const Color surface = VelvetTokens.parchmentLift;
  static const Color line = VelvetTokens.line;

  static const Color teal = VelvetTokens.ember;
  static const Color tealDeep = VelvetTokens.emberDeep;
  static const Color orangeSoft = VelvetTokens.emberSoft;
  static const Color champagne = VelvetTokens.gold;
  static const Color lapis = VelvetTokens.lapis;
  static const Color danger = VelvetTokens.danger;
  static const Color muted = VelvetTokens.muted;
  static const Color softShadow = VelvetTokens.softShadow;
  static const Color glassFill = VelvetTokens.glassFill;
  static const Color glassStrong = VelvetTokens.glassStrong;
  static const Color plum = VelvetTokens.plum;
  static const Color berry = VelvetTokens.lapis;

  static const Color cream = VelvetTokens.parchment;
  static const Color sand = VelvetTokens.line;
  static const Color emerald = VelvetTokens.ember;
  static const Color gold = VelvetTokens.gold;

  static const double radiusSm = VelvetTokens.radiusSm;
  static const double radiusMd = VelvetTokens.radiusMd;
  static const double radiusLg = VelvetTokens.radiusLg;
  static const double radiusXl = VelvetTokens.radiusXl;

  static List<BoxShadow> get softLift => VelvetTokens.depthLift();

  static List<BoxShadow> get orangeGlow => VelvetTokens.emberHalo();

  static List<BoxShadow> get roseHalo => VelvetTokens.depthLift(elevation: 0.5);

  static BoxDecoration glass({
    double radius = radiusLg,
    Color? fill,
    Color? border,
    bool lift = true,
  }) {
    return BoxDecoration(
      color: fill ?? VelvetTokens.glassFill.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: border ?? VelvetTokens.line.withValues(alpha: 0.65),
        width: 0.8,
      ),
      boxShadow: lift ? softLift : null,
    );
  }

  static ThemeData get light {
    final body = GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme);
    final display = GoogleFonts.syneTextTheme(ThemeData.dark().textTheme);

    final colorScheme = ColorScheme.dark(
      primary: teal,
      onPrimary: VelvetTokens.onPrimary,
      secondary: champagne,
      onSecondary: VelvetTokens.onPrimary,
      surface: nightSoft,
      onSurface: ink,
      error: danger,
      onError: ink,
      outline: line,
    );

    final textTheme = body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.0,
        height: 0.92,
        fontSize: VelvetTokens.displayHero,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
        height: 0.95,
        fontSize: VelvetTokens.displayLarge,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        fontSize: VelvetTokens.displaySmall,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.0,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.05,
        fontSize: 30,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.08,
        fontSize: 24,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: body.titleSmall?.copyWith(
        color: muted,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: ink,
        height: 1.58,
        fontSize: 16,
      ),
      bodyMedium: body.bodyMedium?.copyWith(color: ink, height: 1.52),
      bodySmall: body.bodySmall?.copyWith(color: muted, height: 1.48),
      labelLarge: body.labelLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: nightSoft,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: display.titleLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: glassStrong,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: line.withValues(alpha: 0.7)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        minVerticalPadding: 14,
        iconColor: teal,
        textColor: ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.square(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: line,
        thickness: 0.5,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: porcelain.withValues(alpha: 0.85),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: line.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: teal.withValues(alpha: 0.55), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        labelStyle: body.bodyMedium?.copyWith(color: muted),
        floatingLabelStyle: body.bodySmall?.copyWith(
          color: teal,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: body.bodyMedium?.copyWith(
          color: muted.withValues(alpha: 0.55),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: VelvetTokens.onPrimary,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: line.withValues(alpha: 0.8)),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: teal,
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: porcelain,
        selectedColor: teal.withValues(alpha: 0.12),
        side: BorderSide(color: line.withValues(alpha: 0.7)),
        labelStyle: body.labelMedium?.copyWith(color: ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        checkmarkColor: teal,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: nightLift,
        contentTextStyle: body.bodyMedium?.copyWith(color: ink),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: nightLift,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: display.titleLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        showDragHandle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: nightLift,
        indicatorColor: teal.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          body.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: teal,
        selectionColor: teal.withValues(alpha: 0.28),
        selectionHandleColor: tealDeep,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return teal;
          return porcelain;
        }),
        checkColor: WidgetStateProperty.all(VelvetTokens.onPrimary),
        side: BorderSide(color: line.withValues(alpha: 0.9), width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: teal),
      badgeTheme: const BadgeThemeData(backgroundColor: teal),
      extensions: const [VelvetEditorialColors.dark],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Warm editorial dark — void surfaces, ember accents, cream typography.
  static ThemeData get dark {
    final base = light;
    const inkDark = VelvetTokens.darkInk;
    const surfaceDark = VelvetTokens.darkSurface;
    const liftDark = VelvetTokens.darkLift;

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VelvetTokens.darkVoid,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: surfaceDark,
        onSurface: inkDark,
        onPrimary: VelvetTokens.onPrimary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: inkDark,
        displayColor: inkDark,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        foregroundColor: inkDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: liftDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: VelvetTokens.darkLine),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: liftDark,
        labelStyle: base.textTheme.bodyMedium?.copyWith(color: VelvetTokens.darkMuted),
        floatingLabelStyle: base.textTheme.bodySmall?.copyWith(
          color: teal,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: base.textTheme.bodyMedium?.copyWith(
          color: VelvetTokens.darkMuted.withValues(alpha: 0.55),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: VelvetTokens.darkLine.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: teal.withValues(alpha: 0.55), width: 1.5),
        ),
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: liftDark,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(color: inkDark),
      ),
      dialogTheme: base.dialogTheme.copyWith(backgroundColor: liftDark),
      dividerTheme: base.dividerTheme.copyWith(color: VelvetTokens.darkLine),
      extensions: const [VelvetEditorialColors.dark],
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = VelvetTheme.radiusLg,
    this.blur = VelvetTokens.blurGlass,
    this.fill,
    this.border,
    this.lift = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final Color? fill;
  final Color? border;
  final bool lift;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Container(
      margin: margin,
      decoration: lift
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: 0.07),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur * 0.55, sigmaY: blur * 0.55),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (fill ?? colors.glassFill).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: border ?? colors.line.withValues(alpha: 0.45),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Asymmetric editorial page header with kinetic underline accent.
class VelvetPageHeader extends StatelessWidget {
  const VelvetPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.brand = false,
    this.eyebrow,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool brand;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(VelvetTokens.space4, VelvetTokens.space4, VelvetTokens.space4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: VelvetTokens.space8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: VelvetTokens.gold,
                      fontSize: VelvetTokens.labelCaps,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space8),
                ],
                Text(
                  title,
                  style: brand
                      ? GoogleFonts.syne(
                          color: context.velvet.ink,
                          fontSize: VelvetTokens.displayHero,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.0,
                          height: 0.92,
                        )
                      : Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontFamily: GoogleFonts.syne().fontFamily,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                ),
                if (!brand) ...[
                  const SizedBox(height: VelvetTokens.space16),
                  Transform.translate(
                    offset: const Offset(-2, 0),
                    child: Container(
                      width: 56,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            VelvetTokens.ember,
                            VelvetTokens.gold.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(VelvetTokens.radiusPill),
                      ),
                    ),
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: VelvetTheme.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Small editorial label for visual rhythm.
class VelvetEyebrow extends StatelessWidget {
  const VelvetEyebrow({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: VelvetTheme.champagne),
          const SizedBox(width: VelvetTokens.space6),
        ],
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: VelvetTheme.muted,
            fontSize: VelvetTokens.labelCaps,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}
