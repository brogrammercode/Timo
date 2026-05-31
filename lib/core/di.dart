import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../services/local_storage.dart';
import '../services/connectivity_service.dart';
import '../features/auth/repo/auth_repo.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/session/repo/session_repo.dart';
import '../features/session/cubit/session_cubit.dart';
import '../features/history/repo/history_repo.dart';
import '../features/history/cubit/history_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  serviceLocator.registerLazySingleton<LocalStorage>(() => LocalStorage(
    secureStorage: secureStorage,
    sharedPrefs: sharedPrefs,
  ));

  serviceLocator.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  serviceLocator.registerFactory<AuthRepo>(() => AuthRepo(
    auth: FirebaseService.auth,
    firestore: FirebaseService.firestore,
    localStorage: serviceLocator(),
  ));

  serviceLocator.registerFactory<AuthCubit>(() => AuthCubit(authRepo: serviceLocator()));

  serviceLocator.registerFactory<SessionRepo>(() => SessionRepo(
    firestore: FirebaseService.firestore,
    auth: FirebaseService.auth,
    localStorage: serviceLocator(),
    connectivityService: serviceLocator(),
  ));

  serviceLocator.registerFactory<SessionCubit>(() => SessionCubit(sessionRepo: serviceLocator()));

  serviceLocator.registerFactory<HistoryRepo>(() => HistoryRepo(
    firestore: FirebaseService.firestore,
    auth: FirebaseService.auth,
  ));

  serviceLocator.registerFactory<HistoryCubit>(() => HistoryCubit(historyRepo: serviceLocator()));
}

class AppDependencies {}

