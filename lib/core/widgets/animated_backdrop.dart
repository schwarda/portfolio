import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnimatedBackdrop extends StatefulWidget {
  const AnimatedBackdrop({super.key});

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _VibrantBackgroundPainter(t: _controller.value),
          );
        },
      ),
    );
  }
}

class _VibrantBackgroundPainter extends CustomPainter {
  _VibrantBackgroundPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgStart, AppColors.bgMiddle, AppColors.bgEnd],
        ).createShader(rect),
    );

    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.20 + 0.06 * _wave(0.2)),
        size.height * (0.18 + 0.03 * _wave(1.2)),
      ),
      radius: size.width * 0.40,
      color: const Color(0xFF7A5CFF),
      opacity: 0.50,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.84 + 0.04 * _wave(2.4)),
        size.height * (0.24 + 0.04 * _wave(0.6)),
      ),
      radius: size.width * 0.32,
      color: const Color(0xFF00D5FF),
      opacity: 0.40,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.75 + 0.07 * _wave(1.7)),
        size.height * (0.74 + 0.03 * _wave(2.0)),
      ),
      radius: size.width * 0.34,
      color: const Color(0xFFFF6E6A),
      opacity: 0.38,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.16 + 0.05 * _wave(2.6)),
        size.height * (0.82 + 0.04 * _wave(0.9)),
      ),
      radius: size.width * 0.28,
      color: const Color(0xFF6EF5A9),
      opacity: 0.30,
    );

    _drawRibbon(
      canvas,
      size,
      yFactor: 0.28,
      stroke: 2.0,
      colors: const [
        Color(0x00FFFFFF),
        Color(0x66FFFFFF),
        Color(0x00FFFFFF),
      ],
      phase: 0.0,
      amplitude: 28,
    );
    _drawRibbon(
      canvas,
      size,
      yFactor: 0.60,
      stroke: 1.8,
      colors: const [
        Color(0x00FFFFFF),
        Color(0x55A2D9FF),
        Color(0x00FFFFFF),
      ],
      phase: 1.4,
      amplitude: 24,
    );
    _drawRibbon(
      canvas,
      size,
      yFactor: 0.82,
      stroke: 1.6,
      colors: const [
        Color(0x00FFFFFF),
        Color(0x44FFE6C7),
        Color(0x00FFFFFF),
      ],
      phase: 2.3,
      amplitude: 20,
    );

    _drawNoiseDots(canvas, size);
  }

  void _drawGlow(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(rect)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(center, radius, paint);
  }

  void _drawRibbon(
    Canvas canvas,
    Size size, {
    required double yFactor,
    required double stroke,
    required List<Color> colors,
    required double phase,
    required double amplitude,
  }) {
    final path = Path();
    const step = 14.0;
    final yStart = size.height * yFactor;
    path.moveTo(0, yStart);

    for (double x = 0; x <= size.width; x += step) {
      final y = yStart +
          amplitude *
              (0.9 * _sin((x / size.width) * 2.2 * math.pi + phase) +
                  0.5 * _sin((x / size.width) * 6.2 * math.pi - phase));
      path.lineTo(x, y);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: colors,
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  void _drawNoiseDots(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0x33FFFFFF);
    const count = 120;

    for (int i = 0; i < count; i++) {
      final fx = ((i * 73) % 997) / 997;
      final fy = ((i * 199) % 991) / 991;
      final shift = 0.008 * _wave(i / 7.0);
      final x = size.width * ((fx + shift) % 1.0);
      final y = size.height * ((fy + shift * 1.7) % 1.0);
      final radius = 0.7 + ((i % 4) * 0.25);
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  double _wave(double n) => _sin((t * 2 * math.pi) + n);

  double _sin(double value) => math.sin(value);

  @override
  bool shouldRepaint(covariant _VibrantBackgroundPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
