import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/error.dart';
import '../repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit({required AuthRepo authRepo})
      : _authRepo = authRepo,
        super(const AuthState());

  Future<void> checkAuth() async {
    emit(state.copyWith(
        checkAuthInfo: const OperationInfo(status: OperationStatus.loading)));

    final result = await _authRepo.getCurrentUserProfile();
    
    result.fold(
      (failure) => emit(state.copyWith(
        checkAuthInfo: OperationInfo(status: OperationStatus.error, error: failure),
      )),
      (user) => emit(state.copyWith(
        user: user,
        checkAuthInfo: const OperationInfo(status: OperationStatus.success),
      )),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(
        loginInfo: const OperationInfo(status: OperationStatus.loading)));

    final result = await _authRepo.signInWithGoogle();

    result.fold(
      (failure) => emit(state.copyWith(
        loginInfo: OperationInfo(status: OperationStatus.error, error: failure),
      )),
      (user) => emit(state.copyWith(
        user: user,
        loginInfo: const OperationInfo(status: OperationStatus.success),
      )),
    );
  }

  Future<void> completeProfileSetup(String username, String avatarUrl) async {
    emit(state.copyWith(
        profileSetupInfo: const OperationInfo(status: OperationStatus.loading)));

    final result = await _authRepo.completeProfileSetup(username, avatarUrl);

    result.fold(
      (failure) => emit(state.copyWith(
        profileSetupInfo: OperationInfo(status: OperationStatus.error, error: failure),
      )),
      (user) => emit(state.copyWith(
        user: user,
        profileSetupInfo: const OperationInfo(status: OperationStatus.success),
      )),
    );
  }

  Future<void> logout() async {
    await _authRepo.logout();
    emit(state.copyWith(clearUser: true));
  }
}

