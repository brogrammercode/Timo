import 'package:equatable/equatable.dart';
import '../../../utils/error.dart';
import '../models/user_model.dart';

class AuthState extends Equatable {
  final UserModel? user;
  final OperationInfo checkAuthInfo;
  final OperationInfo loginInfo;
  final OperationInfo profileSetupInfo;

  const AuthState({
    this.user,
    this.checkAuthInfo = const OperationInfo(),
    this.loginInfo = const OperationInfo(),
    this.profileSetupInfo = const OperationInfo(),
  });

  bool get isAuthenticated => user != null && user!.userName.isNotEmpty;
  bool get needsProfileSetup => user != null && user!.userName.isEmpty;

  AuthState copyWith({
    UserModel? user,
    bool clearUser = false,
    OperationInfo? checkAuthInfo,
    OperationInfo? loginInfo,
    OperationInfo? profileSetupInfo,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      checkAuthInfo: checkAuthInfo ?? this.checkAuthInfo,
      loginInfo: loginInfo ?? this.loginInfo,
      profileSetupInfo: profileSetupInfo ?? this.profileSetupInfo,
    );
  }

  @override
  List<Object?> get props => [
        user?.id,
        user?.userName,
        checkAuthInfo.status,
        loginInfo.status,
        profileSetupInfo.status,
      ];
}

