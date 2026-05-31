import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/ui/app_card.dart';
import '../../../core/color.dart';
import '../../session/models/focus_session_model.dart';
import 'package:intl/intl.dart';

class HistoryListItem extends StatelessWidget {
  final FocusSessionModel session;

  const HistoryListItem({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final hours = session.durationSeconds ~/ 3600;
    final minutes = (session.durationSeconds % 3600) ~/ 60;
    
    String durationText = '';
    if (hours > 0) {
      durationText += '${hours}h ';
    }
    durationText += '${minutes}m';
    if (hours == 0 && minutes == 0) {
      durationText = '${session.durationSeconds}s';
    }

    final date = session.startedAt.toLocal();
    final dateStr = DateFormat('MMM d, yyyy').format(date);

    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Session',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 4.h),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.softGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              durationText,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryIndigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

