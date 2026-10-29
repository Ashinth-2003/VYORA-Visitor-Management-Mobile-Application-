import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF0D77A);
  static const goldDeep = Color(0xFFB8860B);
  static const onGold = Color(0xFF1A1608);

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDeep],
  );

  static const success = Color(0xFF23995F);
  static const info = Color(0xFF4678E0);
  static const neutral = Color(0xFF8A8678);
}

extension ThemeShortcuts on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Light = white + gold, Dark = black + gold.
class AppTheme {
  static final ThemeData light = _build(dark: false);
  static final ThemeData dark = _build(dark: true);

  static ThemeData _build({required bool dark}) {
    final scheme = ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      // "primary" is the gold used for text and icons, so on white it is a darker gold.
      primary: dark ? AppColors.gold : const Color(0xFF8A6A12),
      onPrimary: dark ? AppColors.onGold : Colors.white,
      secondary: AppColors.goldDeep,
      onSecondary: AppColors.onGold,
      error: dark ? const Color(0xFFF2575C) : const Color(0xFFC72E34),
      onError: Colors.white,
      surface: dark ? const Color(0xFF0A0A0A) : Colors.white,
      onSurface: dark ? const Color(0xFFF5F1E6) : const Color(0xFF1A1608),
      onSurfaceVariant: dark ? const Color(0xFFA39E8F) : const Color(0xFF6B6454),
      surfaceContainerHighest: dark
          ? const Color(0xFF161616)
          : const Color(0xFFF7F3E8),
      outline: dark ? const Color(0x38D4AF37) : const Color(0xFFE8DFC4),
    );

    final textTheme = GoogleFonts.manropeTextTheme(
      ThemeData(brightness: scheme.brightness).textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final dialogShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(color: scheme.outline),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        border: border(scheme.outline),
        enabledBorder: border(scheme.outline),
        focusedBorder: border(AppColors.gold, 1.6),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 1.6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: dialogShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
