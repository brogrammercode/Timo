class FocusSessionModel {
  final String id;
  final String userId;
  final int durationSeconds;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;

  const FocusSessionModel({
    required this.id,
    required this.userId,
    required this.durationSeconds,
    required this.status,
    required this.startedAt,
    required this.endedAt,
  });

  FocusSessionModel copyWith({
    String? id,
    String? userId,
    int? durationSeconds,
    String? status,
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearEndedAt = false,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
    );
  }

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      durationSeconds: json['duration_seconds'] ?? 0,
      status: json['status'] ?? '',
      startedAt: _readDate(json['started_at']),
      endedAt: json['ended_at'] == null ? null : _readDate(json['ended_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'duration_seconds': durationSeconds,
      'status': status,
      'started_at': startedAt,
      'ended_at': endedAt,
    };
  }

  static DateTime _readDate(dynamic date) {
    if (date == null) return DateTime.now().toUtc();
    if (date is String) return DateTime.parse(date).toUtc();
    try {
      return (date as dynamic).toDate().toUtc();
    } catch (_) {
      return DateTime.now().toUtc();
    }
  }
}

