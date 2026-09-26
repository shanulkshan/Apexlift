import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'glass_theme.dart';

abstract final class AppTheme {
  static const fontFamily = 'Poppins';

  static ThemeData dark() => _build(
        const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.volt,
          onPrimary: AppColors.ink,
          secondary: AppColors.ice,
          onSecondary: AppColors.ink,
          tertiary: AppColors.ember,
          onTertiary: AppColors.ink,
          error: AppColors.danger,
          onError: AppColors.ink,
          surface: AppColors.slate,
          onSurface: AppColors.fog,
          onSurfaceVariant: AppColors.mist,
          surfaceContainerLowest: AppColors.ink,
          surfaceContainerLow: AppColors.graphite,
          surfaceContainer: AppColors.slate,
          surfaceContainerHigh: AppColors.slateHigh,
          surfaceContainerHighest: AppColors.slateHighest,
          outline: AppColors.line,
          outlineVariant: AppColors.lineSoft,
        ),
        glass: GlassTheme.dark,
      );

  static ThemeData light() => _build(
        const ColorScheme(
          brightness: Brightness.light,
          // Near-black primary on light glass: volt text on white is illegible,
          // so volt stays an accent (bubble highlights, charts) in light mode.
          primary: AppColors.ink,
          onPrimary: AppColors.volt,
          primaryContainer: AppColors.volt,
          onPrimaryContainer: AppColors.ink,
          secondary: Color(0xFF007A99),
          onSecondary: Colors.white,
          tertiary: Color(0xFFC24A12),
          onTertiary: Colors.white,
          error: AppColors.dangerDeep,
          onError: Colors.white,
          surface: AppColors.card,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.graphiteText,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: AppColors.paper,
          surfaceContainer: AppColors.card,
          surfaceContainerHigh: AppColors.cardHigh,
          surfaceContainerHighest: AppColors.cardHighest,
          outline: AppColors.lineLight,
          outlineVariant: AppColors.cardHighest,
        ),
        glass: GlassTheme.light,
      );

  static ThemeData _build(ColorScheme scheme, {required GlassTheme glass}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
    );
    final t = base.textTheme;

    // Poppins is wide, so large sizes get slightly tighter tracking.
    TextStyle? tight(TextStyle? s, FontWeight w, double spacing) =>
        s?.copyWith(fontWeight: w, letterSpacing: spacing, height: 1.15);

    final text = t.copyWith(
      displayLarge: tight(t.displayLarge, FontWeight.w700, -1.5),
      displayMedium: tight(t.displayMedium, FontWeight.w700, -1.2),
      displaySmall: tight(t.displaySmall?.copyWith(fontSize: 34), FontWeight.w700, -1),
      headlineLarge: tight(t.headlineLarge, FontWeight.w700, -0.8),
      headlineMedium: tight(t.headlineMedium?.copyWith(fontSize: 26), FontWeight.w700, -0.6),
      headlineSmall: tight(t.headlineSmall?.copyWith(fontSize: 21), FontWeight.w600, -0.3),
      titleLarge: tight(t.titleLarge?.copyWith(fontSize: 19), FontWeight.w600, -0.2),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15.5),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 15, height: 1.5),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 13.5, height: 1.45),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
    );

    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));

    return base.copyWith(
      // Screens are transparent: the ambient background behind the whole
      // app (AmbientBackground) shows through the glass.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textTheme: text,
      extensions: [glass],
      appBarTheme: AppBarTheme(
        // App bars are transparent, so status-bar icon colour must follow
        // the theme rather than be guessed from the bar colour.
        systemOverlayStyle: (scheme.brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: rounded,
          textStyle: text.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: rounded,
          side: BorderSide(color: scheme.outline),
          textStyle: text.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: text.labelLarge),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      dividerTheme: DividerThemeData(color: glass.rimDim, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.brightness == Brightness.dark ? scheme.primary : AppColors.voltDeep,
        linearTrackColor: glass.fillTop,
        circularTrackColor: Colors.transparent,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
