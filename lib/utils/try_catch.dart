import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'error.dart';

typedef TaskResult<T> = Future<Either<Failure, T>>;
typedef SyncResult<T> = Either<Failure, T>;

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

Future<Either<Failure, T>> tryCatchAsync<T>(Future<T> Function() action) async {
  try {
    final result = await action();
    return Right(result);
  } on AuthException catch (e) {
    return Left(AuthFailure(e.message));
  } on FirebaseException catch (e) {
    return Left(FirebaseFailure(e.message ?? 'Unknown Firebase Error'));
  } on FirebaseAppException catch (e) {
    return Left(FirebaseFailure(e.message));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } on PermissionException catch (e) {
    return Left(PermissionFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}

Either<Failure, T> tryCatchSync<T>(T Function() action) {
  try {
    final result = action();
    return Right(result);
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}

