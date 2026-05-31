import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/layout/safe_scaffold.dart';
import '../../../core/routes.dart';
import '../constants/auth_constants.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../components/auth_social_button.dart';
import '../../../components/ui/app_error_dialog.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.loginInfo.status != current.loginInfo.status,
      listener: (context, state) {
        if (state.loginInfo.isSuccess) {
          if (state.needsProfileSetup) {
            Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
          } else if (state.isAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        } else if (state.loginInfo.isError) {
          AppErrorDialog.show(
            context,
            message: state.loginInfo.error?.message ?? 'Login failed',
            onRetry: () => context.read<AuthCubit>().signInWithGoogle(),
          );
        }
      },
      child: SafeScaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              AuthConstants.welcomeTitle,
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              AuthConstants.welcomeSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return GoogleSignInButton(
                  label: AuthConstants.googleSignInLabel,
                  isLoading: state.loginInfo.isLoading,
                  onPressed: () {
                    context.read<AuthCubit>().signInWithGoogle();
                  },
                );
              },
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

