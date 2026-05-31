import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/color.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: isActive ? 24.w : 8.w,
          decoration: BoxDecoration(
            color: isActive ? AppColors.pureWhite : AppColors.pureWhite.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

