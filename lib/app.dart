import 'package:car_wash/core/router/app_router.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.brandGreen,
      secondary: AppColors.brandGreenLight,
      surface: AppColors.surface,
      error: Color(0xFFFF7B7B),
      onPrimary: Colors.white,
      onSecondary: AppColors.deepInk,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Lavego',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.appBackground,
        canvasColor: AppColors.appBackground,
        cardColor: AppColors.surface,
        dividerColor: AppColors.border,
        splashFactory: InkRipple.splashFactory,
        splashColor: AppColors.brandGreenLight.withValues(alpha: 0.14),
        highlightColor: AppColors.brandGreen.withValues(alpha: 0.06),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBackground,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 0.9,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          labelStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14.5,
          ),
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.brandGreen,
              width: 1.2,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: AppButtonStyles.filled(),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(
              AppColors.brandGreenLight,
            ),
            animationDuration: const Duration(milliseconds: 110),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.brandGreenLight.withValues(alpha: 0.14);
              }
              return null;
            }),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppButtonStyles.outlined(
            foregroundColor: AppColors.brandGreenLight,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          contentTextStyle: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
