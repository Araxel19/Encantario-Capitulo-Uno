import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/challenges_data.dart';
import '../models/day_challenge.dart';
import '../widgets/confession_dialog.dart';
import '../widgets/day_detail_dialog.dart';
import '../widgets/day_node_widget.dart';
import '../widgets/helper_avatar_widget.dart';
import '../widgets/snake_path_painter.dart';
import '../widgets/starry_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<DayChallenge> _challenges;
  bool _isLoading = true;
  DateTime? _startDate;
  bool _devModeUnlockAll = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _challenges = ChallengesData.getInitialChallenges();
    _loadProgress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final String? startDateStr = prefs.getString('encantario_start_date');
    if (startDateStr != null) {
      _startDate = DateTime.tryParse(startDateStr);
    }
    if (_startDate == null) {
      _startDate = DateTime.now();
      await prefs.setString('encantario_start_date', _startDate!.toIso8601String());
    }

    _devModeUnlockAll = prefs.getBool('encantario_dev_mode') ?? false;

    final String? savedData = prefs.getString('encantario_progress');
    if (savedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(savedData);
        for (var item in jsonList) {
          final int day = item['dayNumber'];
          final index = _challenges.indexWhere((c) => c.dayNumber == day);
          if (index != -1) {
            _challenges[index].isCompleted = item['isCompleted'] ?? false;
            _challenges[index].userAnswer = item['userAnswer'];
            _challenges[index].imagePath = item['imagePath'];
          }
        }
      } catch (e) {
        debugPrint('Error al cargar progreso: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final int targetDay = _unlockedMaxDay;
        final int visualIndex = 30 - targetDay;
        final double targetY = visualIndex * 110.0;
        _scrollController.animateTo(
          targetY.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _challenges.map((c) => c.toJson()).toList();
    await prefs.setString('encantario_progress', jsonEncode(jsonList));
  }

  int get _completedCount => _challenges.where((c) => c.isCompleted).length;

  int get _calendarAllowedDay {
    if (_devModeUnlockAll) return 30;
    if (_startDate == null) return 1;
    final now = DateTime.now();
    final difference = now.difference(DateTime(_startDate!.year, _startDate!.month, _startDate!.day));
    final int daysElapsed = difference.inDays + 1;
    return daysElapsed.clamp(1, 30);
  }

  int get _unlockedMaxDay {
    if (_devModeUnlockAll) return 30;
    int maxCompletedDay = 0;
    for (var c in _challenges) {
      if (c.isCompleted && c.dayNumber > maxCompletedDay) {
        maxCompletedDay = c.dayNumber;
      }
    }
    final int nextSequentialDay = maxCompletedDay + 1;
    final int calendarLimit = _calendarAllowedDay;
    return nextSequentialDay < calendarLimit ? nextSequentialDay : calendarLimit;
  }

  void _onNodeTap(DayChallenge challenge, bool isUnlocked) {
    if (!isUnlocked) {
      final int allowedDay = _calendarAllowedDay;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_clock, color: Colors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  challenge.dayNumber > allowedDay
                      ? '⏳ El Día ${challenge.dayNumber} se desbloqueará en el calendario en unos días.'
                      : '🔒 Debes completar el Día ${challenge.dayNumber - 1} primero.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF281343),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (challenge.dayNumber == 30) {
      showDialog(
        context: context,
        builder: (context) => ConfessionDialog(
          onAccept: () {
            setState(() {
              challenge.isCompleted = true;
            });
            _saveProgress();
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => DayDetailDialog(
          challenge: challenge,
          onSaveAnswer: (answer, imagePath) {
            setState(() {
              challenge.isCompleted = true;
              challenge.userAnswer = answer;
              challenge.imagePath = imagePath;
            });
            _saveProgress();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F081D),
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    final double progressPercent = _completedCount / 30.0;
    final int unlockedDay = _unlockedMaxDay;

    final List<DayChallenge> displayChallenges =
        List.from(_challenges.reversed);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0416),
      body: StarryBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Header Limpio
                  _buildHeader(progressPercent),

                  // Camino Serpenteante Ascendente
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double screenWidth = constraints.maxWidth;
                        const double rowHeight = 110.0;
                        final int totalNodes = displayChallenges.length;

                        final List<Offset> points = [];
                        for (int i = 0; i < totalNodes; i++) {
                          final double y = (i * rowHeight) + 70.0;
                          double xRatio;
                          if (i % 4 == 0) {
                            xRatio = 0.5;
                          } else if (i % 4 == 1) {
                            xRatio = 0.75;
                          } else if (i % 4 == 2) {
                            xRatio = 0.5;
                          } else {
                            xRatio = 0.25;
                          }

                          final double x = screenWidth * xRatio;
                          points.add(Offset(x, y));
                        }

                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            height: (totalNodes * rowHeight) + 140.0,
                            width: screenWidth,
                            child: Stack(
                              children: [
                                // Línea serpenteante
                                CustomPaint(
                                  size: Size(screenWidth, (totalNodes * rowHeight) + 140.0),
                                  painter: SnakePathPainter(
                                    points: points,
                                    completedIndex: _completedCount,
                                  ),
                                ),

                                // Nodos
                                ...List.generate(totalNodes, (index) {
                                  final challenge = displayChallenges[index];
                                  final point = points[index];
                                  final isUnlocked = challenge.dayNumber <= unlockedDay;
                                  final isCurrent = challenge.dayNumber == unlockedDay && !challenge.isCompleted;

                                  return Positioned(
                                    left: point.dx - 57.5,
                                    top: point.dy - 40,
                                    child: DayNodeWidget(
                                      challenge: challenge,
                                      isCurrent: isCurrent,
                                      isUnlocked: isUnlocked,
                                      onTap: () => _onNodeTap(challenge, isUnlocked),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Avatar Flotante del Gato Asistente
            HelperAvatarWidget(
              completedDays: _completedCount,
              unlockedMaxDay: unlockedDay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progressPercent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0D33).withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'ASCENSO AL DÍA 30',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        if (_devModeUnlockAll)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'DEV',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Día $_calendarAllowedDay del Calendario • Retos Diarios',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _devModeUnlockAll ? Icons.lock_open_rounded : Icons.lock_clock_rounded,
                      color: _devModeUnlockAll ? Colors.pinkAccent : Colors.white54,
                      size: 20,
                    ),
                    tooltip: _devModeUnlockAll ? 'Modo Calendario Real' : 'Modo Pruebas (Desbloquear Todo)',
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      setState(() {
                        _devModeUnlockAll = !_devModeUnlockAll;
                      });
                      await prefs.setBool('encantario_dev_mode', _devModeUnlockAll);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _devModeUnlockAll
                                  ? '🔓 Modo Pruebas Activado: Todos los días desbloqueados.'
                                  : '📅 Modo Calendario Activado: Un día desbloqueado por fecha.',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.amber),
                    tooltip: 'Reiniciar Progreso',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1035),
                          title: const Text('¿Reiniciar Camino?', style: TextStyle(color: Colors.amber)),
                          content: const Text('Esto borrará el progreso y respuestas guardadas.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () async {
                                final nav = Navigator.of(context);
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('encantario_progress');
                                await prefs.remove('encantario_start_date');
                                setState(() {
                                  _challenges = ChallengesData.getInitialChallenges();
                                  _startDate = DateTime.now();
                                });
                                nav.pop();
                              },
                              child: const Text('Reiniciar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra de Progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso: $_completedCount de 30 Días',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(progressPercent * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
