import 'package:equatable/equatable.dart';
import '../../../utils/error.dart';
import '../../session/models/focus_session_model.dart';

class HistoryState extends Equatable {
  final List<FocusSessionModel> sessions;
  final OperationInfo loadInfo;

  const HistoryState({
    this.sessions = const [],
    this.loadInfo = const OperationInfo(),
  });

  bool get isEmpty => sessions.isEmpty;

  HistoryState copyWith({
    List<FocusSessionModel>? sessions,
    OperationInfo? loadInfo,
  }) {
    return HistoryState(
      sessions: sessions ?? this.sessions,
      loadInfo: loadInfo ?? this.loadInfo,
    );
  }

  @override
  List<Object?> get props => [
        sessions,
        loadInfo.status,
      ];
}

