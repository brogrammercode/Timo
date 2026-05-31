import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import '../../../components/layout/safe_scaffold.dart';
import '../../../components/ui/app_button.dart';
import '../../../components/ui/app_text_field.dart';
import '../../../core/routes.dart';
import '../constants/auth_constants.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _randomAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Funky random avatar generation (using DiceBear API for example)
    final randomSeed = Random().nextInt(10000).toString();
    _randomAvatarUrl = 'https://api.dicebear.com/7.x/fun-emoji/png?seed=$randomSeed';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().completeProfileSetup(
            _usernameController.text.trim(),
            _randomAvatarUrl,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.profileSetupInfo.status != current.profileSetupInfo.status,
      listener: (context, state) {
        if (state.profileSetupInfo.isSuccess && state.isAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state.profileSetupInfo.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    state.profileSetupInfo.error?.message ?? 'Setup failed')),
          );
        }
      },
      child: SafeScaffold(
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AuthConstants.profileSetupTitle,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                AuthConstants.profileSetupSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              Center(
                child: CircleAvatar(
                  radius: 64.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(_randomAvatarUrl),
                ),
              ),
              SizedBox(height: 48.h),
              AppTextField(
                controller: _usernameController,
                hintText: AuthConstants.usernameHint,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Must be at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return AppButton(
                    text: AuthConstants.getStartedButton,
                    isLoading: state.profileSetupInfo.isLoading,
                    onPressed: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

