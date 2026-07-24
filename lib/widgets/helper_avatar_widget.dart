import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

class HelperAvatarWidget extends StatefulWidget {
  final int completedDays;
  final int unlockedMaxDay;

  const HelperAvatarWidget({
    super.key,
    required this.completedDays,
    required this.unlockedMaxDay,
  });

  @override
  State<HelperAvatarWidget> createState() => _HelperAvatarWidgetState();
}

class _HelperAvatarWidgetState extends State<HelperAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  final List<String> _tips = [
    '✨ Completa cada día respondiendo con sinceridad para avanzar al siguiente reto.',
    '🎵 Los Días 5, 10, 15, 20 y 25 son hitos especiales con retos diferentes.',
    '🎯 El Día 30 es el reto final en la cima del camino.',
    '💡 Si quieres revisar un día completado para leer tu respuesta, solo debes tocarlo.',
    '🌟 Disfruten cada pregunta y conozcan nuevos detalles del otro.',
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _showHelperDialog(BuildContext context) {
    // Escoger tip acorde al progreso
    String currentTip;
    if (widget.completedDays == 0) {
      currentTip = _tips[0];
    } else if (widget.completedDays >= 29) {
      currentTip = _tips[2];
    } else {
      currentTip = _tips[(widget.completedDays % (_tips.length - 1)) + 1];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1035),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.amber, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(AppAssets.retroAvatar),
                backgroundColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Guía Místico',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF120B20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                currentTip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Progreso Actual: ${widget.completedDays} / 30 Días Completados',
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Entendido!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 18,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          final offset = _bounceController.value * -6.0;
          return Transform.translate(
            offset: Offset(0, offset),
            child: GestureDetector(
              onTap: () => _showHelperDialog(context),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.purpleAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundImage: AssetImage(AppAssets.retroAvatar),
                      backgroundColor: Color(0xFF1E1035),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          size: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
