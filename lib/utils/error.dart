abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class FirebaseFailure extends Failure {
  const FirebaseFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

// App-level Exceptions
class AppExceptions implements Exception {
  final String message;
  const AppExceptions(this.message);
  @override
  String toString() => message;
}

class FirebaseAppException extends AppExceptions {
  const FirebaseAppException(super.message);
}

class CacheException extends AppExceptions {
  const CacheException(super.message);
}

class NetworkException extends AppExceptions {
  const NetworkException(super.message);
}

class AuthException extends AppExceptions {
  const AuthException(super.message);
}

class ValidationException extends AppExceptions {
  const ValidationException(super.message);
}

class PermissionException extends AppExceptions {
  const PermissionException(super.message);
}

enum OperationStatus { initial, loading, success, error }

class OperationInfo {
  final OperationStatus status;
  final Failure? error;

  const OperationInfo({
    this.status = OperationStatus.initial,
    this.error,
  });

  bool get isInitial => status == OperationStatus.initial;
  bool get isLoading => status == OperationStatus.loading;
  bool get isSuccess => status == OperationStatus.success;
  bool get isError => status == OperationStatus.error;
}

