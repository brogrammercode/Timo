import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/history_constants.dart';

class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Placeholder for 3D claymorphism illustration
        Icon(Icons.history_toggle_off, size: 100.w, color: Colors.grey.shade400),
        SizedBox(height: 24.h),
        Text(
          HistoryConstants.emptyStateTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 16.h),
        Text(
          HistoryConstants.emptyStateSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

