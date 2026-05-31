import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/error.dart';
import '../constants/session_constants.dart';
import '../repo/session_repo.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> with WidgetsBindingObserver {
  final SessionRepo _sessionRepo;
  Timer? _timer;
  int _syncCounter = 0;

  SessionCubit({required SessionRepo sessionRepo})
      : _sessionRepo = sessionRepo,
        super(const SessionState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    return super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      pauseSession();
    } else if (state == AppLifecycleState.resumed) {
      resumeSession();
    }
  }

  Future<void> loadTodaySession() async {
    emit(state.copyWith(loadInfo: const OperationInfo(status: OperationStatus.loading)));
    
    final result = await _sessionRepo.getActiveOrTodaySession();
    
    await result.fold(
      (failure) async => emit(state.copyWith(
        loadInfo: OperationInfo(status: OperationStatus.error, error: failure)
      )),
      (session) async {
        if (session != null) {
          emit(state.copyWith(
            activeSession: session,
            loadInfo: const OperationInfo(status: OperationStatus.success)
          ));
          if (session.status == SessionConstants.statusActive) {
            _startLocalTimer();
          }
        } else {
          // No session today, create one
          await _createNewSession();
        }
      }
    );
  }

  Future<void> _createNewSession() async {
    final result = await _sessionRepo.createDailySession();
    result.fold(
      (failure) => emit(state.copyWith(
        loadInfo: OperationInfo(status: OperationStatus.error, error: failure)
      )),
      (session) {
        emit(state.copyWith(
          activeSession: session,
          loadInfo: const OperationInfo(status: OperationStatus.success)
        ));
        _startLocalTimer();
      }
    );
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.activeSession != null && state.activeSession!.status == SessionConstants.statusActive) {
        // Midnight Rollover Check
        final sessionDate = state.activeSession!.startedAt.toLocal();
        final now = DateTime.now();
        if (sessionDate.day != now.day || sessionDate.month != now.month || sessionDate.year != now.year) {
          _rollOverSession();
          return;
        }

        final newDuration = state.activeSession!.durationSeconds + 1;
        final updatedSession = state.activeSession!.copyWith(durationSeconds: newDuration);
        
        emit(state.copyWith(activeSession: updatedSession));
        
        _syncCounter++;
        // Sync to Firestore every 30 seconds to save writes
        if (_syncCounter >= 30) {
          _syncCounter = 0;
          _sessionRepo.syncSession(updatedSession.id, newDuration, SessionConstants.statusActive);
        }
      }
    });
  }

  Future<void> pauseSession() async {
    _timer?.cancel();
    if (state.activeSession != null) {
      final updatedSession = state.activeSession!.copyWith(status: SessionConstants.statusPaused);
      emit(state.copyWith(activeSession: updatedSession));
      await _sessionRepo.syncSession(updatedSession.id, updatedSession.durationSeconds, SessionConstants.statusPaused);
    }
  }

  Future<void> resumeSession() async {
    // Before resuming, we should check if it's still the same day.
    // To keep it simple based on flow, we just resume and the repo handles day changes on initial load.
    if (state.activeSession != null) {
      final updatedSession = state.activeSession!.copyWith(status: SessionConstants.statusActive);
      emit(state.copyWith(activeSession: updatedSession));
      await _sessionRepo.syncSession(updatedSession.id, updatedSession.durationSeconds, SessionConstants.statusActive);
      _startLocalTimer();
    } else {
      loadTodaySession();
    }
  }

  Future<void> _rollOverSession() async {
    _timer?.cancel();
    if (state.activeSession != null) {
      await _sessionRepo.completeSession(state.activeSession!.id, state.activeSession!.durationSeconds);
      emit(state.copyWith(activeSession: null));
      await loadTodaySession();
    }
  }

  Future<void> endSession() async {
    _timer?.cancel();
    if (state.activeSession != null) {
      await _sessionRepo.completeSession(state.activeSession!.id, state.activeSession!.durationSeconds);
      emit(state.copyWith(activeSession: null));
      await loadTodaySession();
    }
  }
}

