import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.checkAuthInfo.status != current.checkAuthInfo.status,
      listener: (context, state) {
        if (state.checkAuthInfo.isSuccess) {
          if (state.isAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state.needsProfileSetup) {
            Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        } else if (state.checkAuthInfo.isError) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

