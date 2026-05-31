class UserModel {
  final String id;
  final String userName;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? userName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      createdAt: _readDate(json['created_at']),
      updatedAt: _readDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static DateTime _readDate(dynamic date) {
    if (date == null) return DateTime.now().toUtc();
    if (date is String) return DateTime.parse(date).toUtc();
    // Handling Firestore Timestamp would require importing cloud_firestore, 
    // but code standard says to avoid tight coupling in models if possible, 
    // or handle conversions consistently. Assuming string/int or Timestamp with toDate().
    try {
      return (date as dynamic).toDate().toUtc();
    } catch (_) {
      return DateTime.now().toUtc();
    }
  }
}

