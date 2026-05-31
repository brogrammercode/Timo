import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.pureWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryIndigo,
        secondary: AppColors.softGrey,
        surface: AppColors.pureWhite,
        error: Colors.red,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.deepOnyx,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.deepOnyx,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.deepOnyx,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.deepOnyx,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryIndigo,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2.w),
        ),
        hintStyle: GoogleFonts.outfit(
          color: AppColors.deepOnyx.withValues(alpha: 0.5),
          fontSize: 16.sp,
        ),
      ),
    );
  }
}

