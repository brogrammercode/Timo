import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/ui/app_card.dart';
import '../../../core/color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../session/models/focus_session_model.dart';
import '../cubit/history_cubit.dart';
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
    final remainingSeconds = session.durationSeconds % 60;
    
    String durationText = '';
    if (hours > 0) {
      durationText += '${hours}h ';
    }
    if (minutes > 0 || hours > 0) {
      durationText += '${minutes}m ';
    }
    durationText += '${remainingSeconds}s';

    final date = session.startedAt.toLocal();
    final dateStr = DateFormat('MMM d, yyyy').format(date);
    final startTimeStr = DateFormat('h:mm a').format(date);
    final endTimeStr = session.endedAt != null
        ? DateFormat('h:mm a').format(session.endedAt!.toLocal())
        : 'Ongoing';
    
    final statusText = session.status.isNotEmpty 
        ? session.status[0].toUpperCase() + session.status.substring(1) 
        : 'Unknown';

    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Session',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  '$startTimeStr - $endTimeStr',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Status: $statusText',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusText.toLowerCase() == 'completed' 
                        ? Colors.green[700] 
                        : Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
          SizedBox(width: 8.w),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Session'),
                  content: const Text('Are you sure you want to delete this session? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                context.read<HistoryCubit>().deleteSession(session.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

