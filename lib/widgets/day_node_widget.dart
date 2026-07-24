import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../models/day_challenge.dart';

class DayNodeWidget extends StatefulWidget {
  final DayChallenge challenge;
  final bool isCurrent;
  final bool isUnlocked;
  final VoidCallback onTap;

  const DayNodeWidget({
    super.key,
    required this.challenge,
    required this.isCurrent,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  State<DayNodeWidget> createState() => _DayNodeWidgetState();
}

class _DayNodeWidgetState extends State<DayNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildNodeContent(
    bool isClimaxDay,
    bool isCompleted,
    bool isUnlocked,
    int dayNumber,
  ) {
    if (isClimaxDay && isCompleted) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.favorite,
            color: Colors.pinkAccent,
            size: 38,
          ),
          Icon(Icons.check_circle, color: Colors.amber, size: 16),
        ],
      );
    }

    if (isCompleted) {
      // Día ya realizado y completado -> card_complete.png
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            AppAssets.cardComplete,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.black),
            ),
          ),
        ],
      );
    }

    if (isUnlocked) {
      // Día desbloqueado pendiente por hacer -> card_open.png
      return Image.asset(
        AppAssets.cardOpen,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      );
    }

    // Día bloqueado -> card_locked.png con cadenas/candado sobrepuesto
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.65,
          child: Image.asset(
            AppAssets.cardLocked,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          ),
        ),
        // Overlay de cadenas y candado
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Colors.white54,
            size: 20,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final isCompleted = challenge.isCompleted;
    final isUnlocked = widget.isUnlocked;
    final isCurrent = widget.isCurrent;
    final isMilestone = challenge.isMilestone;
    final isClimaxDay = challenge.dayNumber == 30;

    double nodeSize = isClimaxDay ? 92.0 : (isMilestone ? 78.0 : 68.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isUnlocked ? widget.onTap : null,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = isCurrent ? 1.0 + (_pulseController.value * 0.08) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getNodeBackgroundColor(
                      isCompleted: isCompleted,
                      isUnlocked: isUnlocked,
                      isClimax: isClimaxDay,
                    ),
                    border: Border.all(
                      color: _getNodeBorderColor(
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isUnlocked: isUnlocked,
                        isClimax: isClimaxDay,
                      ),
                      width: isCurrent || isClimaxDay ? 3.5 : 2.0,
                    ),
                    boxShadow: [
                      if (isUnlocked || isCompleted)
                        BoxShadow(
                          color: isClimaxDay
                              ? Colors.pinkAccent.withValues(alpha: 0.7)
                              : (isMilestone
                                  ? Colors.amber.withValues(alpha: 0.6)
                                  : Colors.purpleAccent.withValues(alpha: 0.4)),
                          blurRadius: isCurrent || isClimaxDay ? 18 : 10,
                          spreadRadius: isCurrent ? 3 : 1,
                        ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildNodeContent(isClimaxDay, isCompleted, isUnlocked, challenge.dayNumber),

                      // Badge de número de día
                      Positioned(
                        bottom: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.amber
                                : (isUnlocked ? Colors.purpleAccent : Colors.black87),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Día ${challenge.dayNumber}',
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.black
                                  : (isUnlocked ? Colors.white : Colors.white38),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Etiqueta del título debajo
        SizedBox(
          width: 115,
          child: Text(
            isMilestone && challenge.milestoneTitle != null
                ? challenge.milestoneTitle!
                : challenge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isUnlocked
                  ? (isMilestone ? Colors.amberAccent : Colors.white)
                  : Colors.white38,
              fontSize: isMilestone ? 12 : 11,
              fontWeight: isMilestone || isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Color _getNodeBackgroundColor({
    required bool isCompleted,
    required bool isUnlocked,
    required bool isClimax,
  }) {
    if (isClimax) return const Color(0xFF4A0E2E);
    if (isCompleted) return const Color(0xFF281343);
    if (isUnlocked) return const Color(0xFF1B0D33);
    return const Color(0xFF10091D);
  }

  Color _getNodeBorderColor({
    required bool isCompleted,
    required bool isCurrent,
    required bool isUnlocked,
    required bool isClimax,
  }) {
    if (isClimax) return Colors.pinkAccent;
    if (isCompleted) return Colors.amber;
    if (isCurrent) return Colors.purpleAccent;
    if (isUnlocked) return Colors.deepPurpleAccent;
    return Colors.white12;
  }
}
