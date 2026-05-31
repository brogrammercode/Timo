import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/color.dart';

enum AppButtonType { primary, secondary, social }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AppButtonType type;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          disabledBackgroundColor: AppColors.softGrey,
          disabledForegroundColor: AppColors.deepOnyx.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;
    switch (type) {
      case AppButtonType.primary:
        return AppColors.primaryIndigo;
      case AppButtonType.secondary:
        return AppColors.deepOnyx;
      case AppButtonType.social:
        return AppColors.softGrey;
    }
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return AppColors.pureWhite;
      case AppButtonType.social:
        return AppColors.deepOnyx;
    }
  }
}

