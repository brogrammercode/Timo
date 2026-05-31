import 'package:equatable/equatable.dart';
import '../../../utils/error.dart';
import '../models/focus_session_model.dart';

class SessionState extends Equatable {
  final FocusSessionModel? activeSession;
  final OperationInfo loadInfo;

  const SessionState({
    this.activeSession,
    this.loadInfo = const OperationInfo(),
  });

  bool get hasActiveSession => activeSession != null;
  
  SessionState copyWith({
    FocusSessionModel? activeSession,
    bool clearSession = false,
    OperationInfo? loadInfo,
  }) {
    return SessionState(
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      loadInfo: loadInfo ?? this.loadInfo,
    );
  }

  @override
  List<Object?> get props => [
        activeSession?.id,
        activeSession?.durationSeconds,
        activeSession?.status,
        loadInfo.status,
      ];
}

