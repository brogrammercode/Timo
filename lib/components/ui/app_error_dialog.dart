import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_button.dart';

class AppErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const AppErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  static void show(BuildContext context, {required String message, required VoidCallback onRetry}) {
    showDialog(
      context: context,
      builder: (context) => AppErrorDialog(
        title: 'Oops!',
        message: message,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 48.w,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Try Again',
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                child: Text(
                  'Dismiss',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
