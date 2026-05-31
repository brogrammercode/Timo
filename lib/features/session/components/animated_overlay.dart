import 'dart:math';
import 'package:flutter/material.dart';

enum EffectType {
  waves,
  bokeh,
  rain,
  snow,
  stars,
  shootingStars,
  fireflies,
  sunbeams,
  floatingPetals,
  aurora,
  warpSpeed,
  mist
}

class AnimatedEffectOverlay extends StatefulWidget {
  const AnimatedEffectOverlay({super.key});

  @override
  State<AnimatedEffectOverlay> createState() => _AnimatedEffectOverlayState();
}

class _AnimatedEffectOverlayState extends State<AnimatedEffectOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final EffectType _effectType;
  late final int _seed;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _effectType = EffectType.values[random.nextInt(EffectType.values.length)];
    _seed = random.nextInt(10000);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        CustomPainter painter;
        switch (_effectType) {
          case EffectType.waves:
            painter = WavesPainter(_controller.value, _seed);
            break;
          case EffectType.bokeh:
            painter = BokehPainter(_controller.value, _seed);
            break;
          case EffectType.rain:
            painter = RainPainter(_controller.value, _seed);
            break;
          case EffectType.snow:
            painter = SnowPainter(_controller.value, _seed);
            break;
          case EffectType.stars:
            painter = StarsPainter(_controller.value, _seed);
            break;
          case EffectType.shootingStars:
            painter = ShootingStarsPainter(_controller.value, _seed);
            break;
          case EffectType.fireflies:
            painter = FirefliesPainter(_controller.value, _seed);
            break;
          case EffectType.sunbeams:
            painter = SunbeamsPainter(_controller.value, _seed);
            break;
          case EffectType.floatingPetals:
            painter = FloatingPetalsPainter(_controller.value, _seed);
            break;
          case EffectType.aurora:
            painter = AuroraPainter(_controller.value, _seed);
            break;
          case EffectType.warpSpeed:
            painter = WarpSpeedPainter(_controller.value, _seed);
            break;
          case EffectType.mist:
            painter = MistPainter(_controller.value, _seed);
            break;
        }

        return CustomPaint(
          size: Size.infinite,
          painter: painter,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 1. WAVES PAINTER
// ---------------------------------------------------------------------------
class WavesPainter extends CustomPainter {
  final double progress;
  final int seed;
  WavesPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1 + (i * 0.05))
        ..style = PaintingStyle.fill;
      final path = Path();
      final phaseShift = (progress * 2 * pi) + (i * pi / 2) + rand.nextDouble();
      final waveHeight = size.height * 0.15 + (i * 20);
      final baseHeight = size.height * 0.75 - (i * 40);
      
      path.moveTo(0, size.height);
      path.lineTo(0, baseHeight);
      for (double x = 0; x <= size.width; x++) {
        final freq = (x / size.width) * 2 * pi;
        final y = baseHeight + sin(freq + phaseShift) * waveHeight;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant WavesPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 2. BOKEH PAINTER
// ---------------------------------------------------------------------------
class BokehPainter extends CustomPainter {
  final double progress;
  final int seed;
  BokehPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (int i = 0; i < 30; i++) {
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;
      final radius = 5.0 + rand.nextDouble() * 20.0;
      final speedY = 0.2 + rand.nextDouble() * 0.8;
      final swaySpeed = 1.0 + rand.nextDouble() * 3.0;
      double y = startY - (progress * size.height * speedY);
      y = y % size.height;
      double x = startX + sin(progress * 2 * pi * swaySpeed) * 30.0;
      paint.color = Colors.white.withValues(alpha: 0.1 + rand.nextDouble() * 0.2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant BokehPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 3. RAIN PAINTER
// ---------------------------------------------------------------------------
class RainPainter extends CustomPainter {
  final double progress;
  final int seed;
  RainPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final dx = size.width * 0.2;
    for (int i = 0; i < 100; i++) {
      final startX = rand.nextDouble() * size.width * 1.5;
      final startY = rand.nextDouble() * size.height;
      final length = 10.0 + rand.nextDouble() * 20.0;
      final speedY = 2.0 + rand.nextDouble() * 3.0;
      double y = startY + (progress * size.height * 10 * speedY);
      y = y % size.height;
      double x = startX - (y * (dx / size.height));
      canvas.drawLine(Offset(x, y), Offset(x - dx * (length / size.height), y - length), paint);
    }
  }
  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 4. SNOW PAINTER
// ---------------------------------------------------------------------------
class SnowPainter extends CustomPainter {
  final double progress;
  final int seed;
  SnowPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < 100; i++) {
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;
      final speedY = 0.5 + rand.nextDouble() * 1.5;
      final swaySpeed = 1.0 + rand.nextDouble() * 2.0;
      double y = startY + (progress * size.height * speedY * 3);
      y = y % size.height;
      double x = startX + sin(progress * 2 * pi * swaySpeed + rand.nextDouble() * pi) * 15.0;
      canvas.drawCircle(Offset(x, y), 1.0 + rand.nextDouble() * 2.0, paint);
    }
  }
  @override
  bool shouldRepaint(covariant SnowPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 5. STARS PAINTER
// ---------------------------------------------------------------------------
class StarsPainter extends CustomPainter {
  final double progress;
  final int seed;
  StarsPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final paint = Paint();
    for (int i = 0; i < 150; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final blinkRate = 2.0 + rand.nextDouble() * 5.0;
      final phase = rand.nextDouble() * 2 * pi;
      // Opacity goes between 0.1 and 0.9
      final alpha = 0.1 + ((sin(progress * 2 * pi * blinkRate + phase) + 1) / 2) * 0.8;
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 0.5 + rand.nextDouble() * 1.5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 6. SHOOTING STARS PAINTER
// ---------------------------------------------------------------------------
class ShootingStarsPainter extends CustomPainter {
  final double progress;
  final int seed;
  ShootingStarsPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    // Only occasionally draw shooting stars
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Progress goes 0 to 1 over 15 seconds. Let's make a star shoot every 3 seconds.
    final localTime = (progress * 5) % 1.0; 
    
    if (localTime < 0.2) {
      final xStart = size.width * 0.8;
      final yStart = size.height * 0.2;
      
      final headX = xStart - (localTime * 5 * size.width);
      final headY = yStart + (localTime * 5 * size.width);
      
      final tailX = headX + 40;
      final tailY = headY - 40;
      
      canvas.drawLine(Offset(tailX, tailY), Offset(headX, headY), paint);
    }
  }
  @override
  bool shouldRepaint(covariant ShootingStarsPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 7. FIREFLIES PAINTER
// ---------------------------------------------------------------------------
class FirefliesPainter extends CustomPainter {
  final double progress;
  final int seed;
  FirefliesPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < 40; i++) {
      final startX = rand.nextDouble() * size.width;
      final startY = size.height * 0.5 + rand.nextDouble() * size.height * 0.5; // lower half mostly
      
      final phaseX = rand.nextDouble() * 2 * pi;
      final phaseY = rand.nextDouble() * 2 * pi;
      
      final x = startX + sin(progress * 2 * pi * 2 + phaseX) * 40;
      final y = startY + cos(progress * 2 * pi * 1.5 + phaseY) * 40 - (progress * size.height * 0.2); // drift up slightly
      
      final alpha = 0.2 + ((sin(progress * 2 * pi * 4 + phaseX) + 1) / 2) * 0.6;
      paint.color = const Color(0xFFE2F091).withValues(alpha: alpha); // Yellow-green glow
      
      canvas.drawCircle(Offset(x, y % size.height), 2.0 + rand.nextDouble() * 3.0, paint);
    }
  }
  @override
  bool shouldRepaint(covariant FirefliesPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 8. SUNBEAMS PAINTER
// ---------------------------------------------------------------------------
class SunbeamsPainter extends CustomPainter {
  final double progress;
  final int seed;
  SunbeamsPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    for (int i = 0; i < 5; i++) {
      final phase = rand.nextDouble() * 2 * pi;
      final alpha = 0.05 + ((sin(progress * 2 * pi * 1 + phase) + 1) / 2) * 0.15;
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      final path = Path();
      final startX = size.width * (0.2 + i * 0.15);
      
      path.moveTo(startX, 0);
      path.lineTo(startX + 80, 0);
      
      // beam angled down to the right
      path.lineTo(startX + 300, size.height);
      path.lineTo(startX + 200, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant SunbeamsPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 9. FLOATING PETALS PAINTER
// ---------------------------------------------------------------------------
class FloatingPetalsPainter extends CustomPainter {
  final double progress;
  final int seed;
  FloatingPetalsPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final paint = Paint()..color = const Color(0xFFFFB7C5).withValues(alpha: 0.6); // Pink sakura
    
    for (int i = 0; i < 30; i++) {
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;
      final speedY = 1.0 + rand.nextDouble() * 2.0;
      final swaySpeed = 2.0 + rand.nextDouble() * 2.0;
      
      double y = startY + (progress * size.height * speedY * 2);
      y = y % size.height;
      double x = startX + sin(progress * 2 * pi * swaySpeed + rand.nextDouble() * pi) * 40.0;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 2 * pi * 3 + rand.nextDouble());
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 8, height: 14), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant FloatingPetalsPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 10. AURORA PAINTER
// ---------------------------------------------------------------------------
class AuroraPainter extends CustomPainter {
  final double progress;
  final int seed;
  AuroraPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF00FF9D).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
      
    final paint2 = Paint()
      ..color = const Color(0xFF7A00FF).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Aurora blob 1
    final x1 = size.width * 0.5 + sin(progress * 2 * pi) * size.width * 0.3;
    final y1 = size.height * 0.3 + cos(progress * 2 * pi * 1.5) * size.height * 0.1;
    canvas.drawOval(Rect.fromCenter(center: Offset(x1, y1), width: size.width * 1.5, height: size.height * 0.4), paint1);

    // Aurora blob 2
    final x2 = size.width * 0.5 + cos(progress * 2 * pi) * size.width * 0.3;
    final y2 = size.height * 0.6 + sin(progress * 2 * pi * 1.2) * size.height * 0.1;
    canvas.drawOval(Rect.fromCenter(center: Offset(x2, y2), width: size.width * 1.5, height: size.height * 0.4), paint2);
  }
  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 11. WARP SPEED PAINTER
// ---------------------------------------------------------------------------
class WarpSpeedPainter extends CustomPainter {
  final double progress;
  final int seed;
  WarpSpeedPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 60; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 1.0 + rand.nextDouble() * 4.0;
      
      // Progress drives distance from center
      double dist = (progress * size.width * speed) % (size.width);
      
      final length = 5.0 + dist * 0.1; // Gets longer as it gets further
      
      final startX = centerX + cos(angle) * dist;
      final startY = centerY + sin(angle) * dist;
      
      final endX = centerX + cos(angle) * (dist + length);
      final endY = centerY + sin(angle) * (dist + length);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }
  @override
  bool shouldRepaint(covariant WarpSpeedPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 12. MIST PAINTER
// ---------------------------------------------------------------------------
class MistPainter extends CustomPainter {
  final double progress;
  final int seed;
  MistPainter(this.progress, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.25);
      final speed = 0.5 + rand.nextDouble() * 1.5;
      
      double x = (progress * size.width * 2 * speed) % (size.width * 2) - size.width;
      
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: size.width * 1.5, height: 150), paint);
    }
  }
  @override
  bool shouldRepaint(covariant MistPainter oldDelegate) => oldDelegate.progress != progress;
}
