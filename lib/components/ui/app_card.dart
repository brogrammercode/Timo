import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/color.dart';

enum AppCardShadow { none, light, medium }

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color backgroundColor;
  final AppCardShadow shadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor = AppColors.pureWhite,
    this.shadow = AppCardShadow.light,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = borderRadius ?? 16.r;
    
    Widget content = Container(
      padding: padding ?? EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        boxShadow: _getShadow(),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(defaultRadius),
          child: content,
        ),
      );
    }

    return content;
  }

  List<BoxShadow>? _getShadow() {
    switch (shadow) {
      case AppCardShadow.none:
        return null;
      case AppCardShadow.light:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ];
      case AppCardShadow.medium:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ];
    }
  }
}

