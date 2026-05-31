import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes.dart';
import '../constants/session_constants.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';
import '../../../constants/backgrounds.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _bgUrl;

  @override
  void initState() {
    super.initState();
    _bgUrl = AppBackgrounds.getRandomWallpaperUrl();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionCubit>().loadTodaySession();
    });
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return "00:00";
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = remainingSeconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hStr = hours.toString().padLeft(2, '0');
      return "$hStr:$mStr:$sStr";
    }
    return "$mStr:$sStr";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              _bgUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF2B2D42)), // Fallback color
            ),
          ),
          
          // Dark Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) {
                if (state.loadInfo.isLoading && !state.hasActiveSession) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (state.loadInfo.isError && !state.hasActiveSession) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.white, size: 48.w),
                        SizedBox(height: 16.h),
                        Text('Failed to load session', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18.sp)),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context.read<SessionCubit>().loadTodaySession(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final session = state.activeSession;
                final bool isActive = session?.status == SessionConstants.statusActive;
                final duration = session?.durationSeconds ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Bar (History Icon)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // "Play lo-fi music" Pill
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                      ),
                      child: Text(
                        'Play lo-fi music 🎵',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Massive Timer
                    Text(
                      _formatDuration(duration),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 96.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Subtitle
                    Text(
                      'Aim for 150-200 words.',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Action Pill Button (Pause / Start)
                    GestureDetector(
                      onTap: () {
                        if (session == null) {
                          context.read<SessionCubit>().loadTodaySession(); // Fallback if no session
                        } else if (isActive) {
                          context.read<SessionCubit>().pauseSession();
                        } else {
                          context.read<SessionCubit>().resumeSession();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 32.w),
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isActive ? 'Pause' : 'Start Focus',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // End Focus Session Link
                    GestureDetector(
                      onTap: () => context.read<SessionCubit>().endSession(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(
                          'End Focus Session',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 48.h),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
