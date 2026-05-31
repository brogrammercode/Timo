import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/layout/safe_scaffold.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../components/history_list_item.dart';
import '../components/empty_history.dart';
import '../constants/history_constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryCubit>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      usePadding: false,
      appBar: AppBar(
        title: Text(
          HistoryConstants.pageTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.loadInfo.isLoading && state.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.loadInfo.isError && state.isEmpty) {
            return Center(
              child: Text(
                state.loadInfo.error?.message ?? 'Failed to load history',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          if (state.isEmpty) {
            return const Center(child: EmptyHistory());
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            itemCount: state.sessions.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return HistoryListItem(session: state.sessions[index]);
            },
          );
        },
      ),
    );
  }
}

