import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryVinho,
        primary: AppColors.primaryVinho,
        secondary: AppColors.secondaryCinza,
        tertiary: AppColors.success, // Cor de sucesso para feedback positivo
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      // Padroniza o estilo dos botões do app
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryVinho,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}