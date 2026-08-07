import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';

@immutable
sealed class AppThemes {
  static final light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppThemeColors.light.background,
    cardColor: AppThemeColors.light.card,
    extensions: const [AppThemeColors.light],
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: AppThemeColors.light.surface,
      error: AppColors.error,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: AppStyles.text16Px.w500.light,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AppColors.button,
        disabledBackgroundColor: AppColors.disabledButton,
        foregroundColor: AppColors.light,
        disabledForegroundColor: AppColors.light,
      ),
    ),
    splashColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: AppStyles.text18Px.w500.dark.copyWith(
        fontWeight: FontWeight.w500,
        color: AppThemeColors.light.textPrimary,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: AppThemeColors.light.background,
      surfaceTintColor: AppThemeColors.light.background,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeColors.light.fieldFill,
      errorStyle: AppStyles.text14Px.poppins.w400.error,
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );

  static final dark = ThemeData.dark(useMaterial3: true).copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppThemeColors.dark.background,
    cardColor: AppThemeColors.dark.card,
    dialogBackgroundColor: AppThemeColors.dark.surface,
    extensions: const [AppThemeColors.dark],
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppThemeColors.dark.surface,
      error: AppColors.error,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF121212),
      surfaceTintColor: Color(0xFF121212),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF121212),
      surfaceTintColor: Color(0xFF121212),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Colors.white70, fontSize: 14),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF121212),
      surfaceTintColor: Color(0xFF121212),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: AppStyles.text16Px.w500.light,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.disabledButton,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white54,
      ),
    ),
    splashColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: AppStyles.text18Px.w500.light.copyWith(
        fontWeight: FontWeight.w500,
        color: AppThemeColors.dark.textPrimary,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: AppThemeColors.dark.background,
      surfaceTintColor: AppThemeColors.dark.background,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeColors.dark.fieldFill,
      errorStyle: AppStyles.text14Px.poppins.w400.error,
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );
}
