import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/ui/app_button.dart';
import '../../../core/color.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: label,
      onPressed: onPressed,
      isLoading: isLoading,
      type: AppButtonType.social,
      backgroundColor: AppColors.googleRed,
      textColor: AppColors.pureWhite,
      icon: Icon(Icons.g_mobiledata, color: AppColors.pureWhite, size: 32.w),
    );
  }
}

