import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

import 'core/config.dart';
import 'core/di.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/session/cubit/session_cubit.dart';
import 'features/history/cubit/history_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await setupDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => serviceLocator<AuthCubit>()),
        BlocProvider<SessionCubit>(create: (context) => serviceLocator<SessionCubit>()),
        BlocProvider<HistoryCubit>(create: (context) => serviceLocator<HistoryCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Timo',
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

