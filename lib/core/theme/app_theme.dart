import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Premium Apple-quality theme following Human Interface Guidelines.
///
/// Uses CupertinoThemeData as the primary design system with Material
/// overrides for components that need them (e.g., SnackBar, Slidable).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      colorScheme: ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surfacePrimary,
        error: AppColors.destructive,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: AppColors.backgroundPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.largeTitleBold.copyWith(
          color: AppColors.labelPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfacePrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
        dragHandleColor: AppColors.separator,
        dragHandleSize: const Size(36, 5),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.separator,
        thickness: 0.5,
        space: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.largeTitleBold,
        headlineMedium: AppTypography.title1Bold,
        headlineSmall: AppTypography.title2Bold,
        titleLarge: AppTypography.title3Semibold,
        titleMedium: AppTypography.headline,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.callout,
        bodySmall: AppTypography.footnote,
        labelLarge: AppTypography.subhead,
        labelSmall: AppTypography.caption1,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.accent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundPrimaryDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accentDark,
        secondary: AppColors.accentSecondaryDark,
        surface: AppColors.surfacePrimaryDark,
        error: AppColors.destructiveDark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: AppColors.backgroundPrimaryDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.largeTitleBold.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfacePrimaryDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
        dragHandleColor: AppColors.separatorDark,
        dragHandleSize: const Size(36, 5),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.separatorDark,
        thickness: 0.5,
        space: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.largeTitleBold.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        headlineMedium: AppTypography.title1Bold.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        headlineSmall: AppTypography.title2Bold.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        titleLarge: AppTypography.title3Semibold.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        titleMedium: AppTypography.headline.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        bodyLarge: AppTypography.body.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        bodyMedium: AppTypography.callout.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        bodySmall: AppTypography.footnote.copyWith(
          color: AppColors.labelSecondaryDark,
        ),
        labelLarge: AppTypography.subhead.copyWith(
          color: AppColors.labelPrimaryDark,
        ),
        labelSmall: AppTypography.caption1.copyWith(
          color: AppColors.labelSecondaryDark,
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.accentDark,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
