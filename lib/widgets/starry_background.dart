import 'dart:math';
import 'package:flutter/material.dart';

class StarryBackground extends StatefulWidget {
  final Widget child;

  const StarryBackground({
    super.key,
    required this.child,
  });

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
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
        return CustomPaint(
          painter: _StarryBackgroundPainter(animationValue: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _StarData {
  final double xRatio;
  final double yRatio;
  final double size;
  final double baseOpacity;
  final Color color;
  final bool isSparkle;

  _StarData({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.baseOpacity,
    required this.color,
    this.isSparkle = false,
  });
}

class _StarryBackgroundPainter extends CustomPainter {
  final double animationValue;

  static final List<_StarData> _stars = _generateStars();

  _StarryBackgroundPainter({required this.animationValue});

  static List<_StarData> _generateStars() {
    final random = Random(42); // Semilla fija para consistencia
    final List<_StarData> list = [];

    final colors = [
      Colors.white,
      const Color(0xFFFFF7C2), // Dorado cálido
      const Color(0xFFE0C3FC), // Violeta suave
      const Color(0xFFBEE3F8), // Azul celeste
    ];

    for (int i = 0; i < 90; i++) {
      list.add(_StarData(
        xRatio: random.nextDouble(),
        yRatio: random.nextDouble(),
        size: random.nextDouble() * 2.5 + 1.0,
        baseOpacity: random.nextDouble() * 0.5 + 0.3,
        color: colors[random.nextInt(colors.length)],
        isSparkle: i % 7 == 0,
      ));
    }
    return list;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fondo Degradado Cósmico Profundo
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF280B44), // Púrpura en la cima (Día 30)
        Color(0xFF140728), // Violeta profundo intermedio
        Color(0xFF070212), // Noche cósmica abajo (Día 1)
      ],
    );

    final bgPaint = Paint()..shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Nebulosas y Resplandores Ambientales
    final nebulaPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.pinkAccent.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.15),
        radius: size.width * 0.7,
      ));
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.15), size.width * 0.7, nebulaPaint1);

    final nebulaPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purpleAccent.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.6),
        radius: size.width * 0.6,
      ));
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), size.width * 0.6, nebulaPaint2);

    final nebulaPaint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.9),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.9), size.width * 0.5, nebulaPaint3);

    // 3. Dibujo de Estrellas Brillantes y Parpadeantes
    for (int i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      final dx = star.xRatio * size.width;
      final dy = star.yRatio * size.height;

      // Cálculo del parpadeo
      final phase = (i * 0.3) % 1.0;
      final twinkle = sin((animationValue + phase) * pi * 2);
      final opacity = (star.baseOpacity + (twinkle * 0.25)).clamp(0.1, 1.0);

      final starPaint = Paint()
        ..color = star.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Dibujar resplandor si es una estrella grande
      if (star.size > 2.2) {
        final glowPaint = Paint()
          ..color = star.color.withValues(alpha: opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(dx, dy), star.size * 2, glowPaint);
      }

      canvas.drawCircle(Offset(dx, dy), star.size, starPaint);

      // Dibujar destello de 4 puntas para estrellas especiales
      if (star.isSparkle) {
        final sparklePaint = Paint()
          ..color = star.color.withValues(alpha: opacity * 0.7)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

        final armLen = star.size * 2.5;
        canvas.drawLine(Offset(dx - armLen, dy), Offset(dx + armLen, dy), sparklePaint);
        canvas.drawLine(Offset(dx, dy - armLen), Offset(dx, dy + armLen), sparklePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarryBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
