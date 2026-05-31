import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/routes.dart';
import '../constants/session_constants.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';
import '../components/animated_overlay.dart';
import '../../../constants/backgrounds.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _bgUrl;
  bool _isBatterySaver = false;
  bool _showDateTime = false;

  @override
  void initState() {
    super.initState();
    _bgUrl = AppBackgrounds.getRandomWallpaperUrl();
    WakelockPlus.enable(); // Keep screen alive
    _loadPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionCubit>().loadTodaySession();
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isBatterySaver = prefs.getBool('isBatterySaver') ?? false;
    setState(() {
      _isBatterySaver = isBatterySaver;
    });
    if (isBatterySaver) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _toggleBatterySaver(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBatterySaver', value);
    setState(() {
      _isBatterySaver = value;
      if (!value) _showDateTime = false;
    });
    if (value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // Allow sleep when leaving page
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = remainingSeconds.toString().padLeft(2, '0');

    return "$hStr:$mStr:$sStr";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _isBatterySaver
            ? SystemUiOverlayStyle
                  .dark // Dark icons (black)
            : SystemUiOverlayStyle.light, // Light icons (white)
        child: GestureDetector(
          onTap: () {
            if (_isBatterySaver) {
              setState(() {
                _showDateTime = !_showDateTime;
              });
            }
          },
          onLongPress: () {
            if (_isBatterySaver) {
              _toggleBatterySaver(false);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Background Image
              if (!_isBatterySaver)
                Positioned.fill(
                  child: Image.network(
                    _bgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF2B2D42),
                    ), // Fallback color
                  ),
                ),

              // Premium Animated Overlay (Waves, Bokeh, or Rain)
              if (!_isBatterySaver)
                const Positioned.fill(child: AnimatedEffectOverlay()),

              // Dark Overlay for readability
              if (!_isBatterySaver)
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
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (state.loadInfo.isError && !state.hasActiveSession) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48.w,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Failed to load session',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<SessionCubit>()
                                  .loadTodaySession(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final session = state.activeSession;
                    final bool isActive =
                        session?.status == SessionConstants.statusActive;
                    final duration = session?.durationSeconds ?? 0;

                    if (_isBatterySaver) {
                      return Center(
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDuration(duration),
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 160.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -4,
                                  height: 1.0,
                                ),
                              ),
                              if (_showDateTime) ...[
                                SizedBox(height: 12.h),
                                StreamBuilder(
                                  stream: Stream.periodic(
                                    const Duration(seconds: 1),
                                  ),
                                  builder: (context, snapshot) {
                                    final now = DateTime.now();
                                    final formattedDate = DateFormat(
                                      'h:mm a • EEEE, MMM d',
                                    ).format(now);
                                    return Text(
                                      formattedDate,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Bar (History Icon)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!_isBatterySaver) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.mode_night,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    _toggleBatterySaver(true);
                                  },
                                ),
                                SizedBox(width: 8.w),
                                IconButton(
                                  icon: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.history,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const Spacer(flex: 1),

                        // Massive Timer
                        Text(
                          _formatDuration(duration),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 80.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                            height: 1.0,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        const Spacer(flex: 2),

                        // Action Pill Button (Pause / Start)
                        if (!_isBatterySaver)
                          GestureDetector(
                            onTap: () {
                              if (session == null) {
                                context
                                    .read<SessionCubit>()
                                    .loadTodaySession(); // Fallback if no session
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

                        SizedBox(height: 48.h),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
