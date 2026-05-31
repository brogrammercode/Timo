import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/error.dart';
import '../repo/history_repo.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepo _historyRepo;

  HistoryCubit({required HistoryRepo historyRepo})
      : _historyRepo = historyRepo,
        super(const HistoryState());

  Future<void> loadHistory() async {
    emit(state.copyWith(
        loadInfo: const OperationInfo(status: OperationStatus.loading)));

    final result = await _historyRepo.getCompletedSessions();

    result.fold(
      (failure) => emit(state.copyWith(
        loadInfo: OperationInfo(status: OperationStatus.error, error: failure),
      )),
      (sessions) => emit(state.copyWith(
        sessions: sessions,
        loadInfo: const OperationInfo(status: OperationStatus.success),
      )),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final result = await _historyRepo.deleteSession(sessionId);
    result.fold(
      (failure) {
        // Optionally handle failure (e.g. emit error state)
      },
      (_) {
        final newSessions = state.sessions.where((s) => s.id != sessionId).toList();
        emit(state.copyWith(sessions: newSessions));
      },
    );
  }
}

