import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MiniGamesWidget extends StatefulWidget {
  final String gameType;
  final Function(String result) onGameSuccess;

  const MiniGamesWidget({
    super.key,
    required this.gameType,
    required this.onGameSuccess,
  });

  @override
  State<MiniGamesWidget> createState() => _MiniGamesWidgetState();
}

class _MiniGamesWidgetState extends State<MiniGamesWidget> {
  bool _isGameOver = false;

  // --- GEM CATCHER STATE ---
  int _gemsCaught = 0;
  final int _targetGems = 8;
  int _secondsLeft = 12;
  Timer? _timer;
  double _gemX = 0.5;
  double _gemY = 0.5;
  final Random _random = Random();
  final List<String> _gemIcons = ['💎', '✨', '🌟', '⚡'];
  int _currentIconIndex = 0;

  // --- MEMORY MATCH 3x3 STATE ---
  late List<String> _gridIcons;
  late List<bool> _cardFlipped;
  int? _firstFlippedIndex;
  int _matchedPairs = 0;

  // --- WORD SCRAMBLE STATE ---
  final String _targetWord = 'DESTINO';
  late List<String> _scrambledLetters;
  final List<String> _selectedLetters = [];

  @override
  void initState() {
    super.initState();
    if (widget.gameType == 'gem_catcher' || widget.gameType == 'heart_catcher') {
      _startGemCatcherTimer();
      _moveGem();
    } else if (widget.gameType == 'memory_match') {
      _setupMemoryGrid();
    } else if (widget.gameType == 'word_scramble') {
      _setupWordScramble();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ==================== 1. GEM CATCHER LOGIC ====================
  void _startGemCatcherTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        if (_gemsCaught >= _targetGems) {
          _winGame('¡Completado! Atrapaste $_gemsCaught destellos.');
        } else {
          setState(() {
            _isGameOver = true;
          });
        }
      }
    });
  }

  void _moveGem() {
    setState(() {
      _gemX = _random.nextDouble() * 0.7 + 0.15;
      _gemY = _random.nextDouble() * 0.5 + 0.25;
      _currentIconIndex = _random.nextInt(_gemIcons.length);
    });
  }

  void _onGemTap() {
    setState(() {
      _gemsCaught++;
    });
    if (_gemsCaught >= _targetGems) {
      _timer?.cancel();
      _winGame('¡Desafío de agilidad completado!');
    } else {
      _moveGem();
    }
  }

  // ==================== 2. MEMORY 3x3 LOGIC ====================
  void _setupMemoryGrid() {
    final pairs = ['🚀', '💎', '⚡', '🎮', '🚀', '💎', '⚡', '🎮'];
    pairs.shuffle();

    _gridIcons = List.from(pairs);
    final bonusPos = Random().nextInt(9);
    _gridIcons.insert(bonusPos, '🌟');

    _cardFlipped = List.filled(9, false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _cardFlipped[bonusPos] = true;
        });
      }
    });
  }

  void _onMemoryCardTap(int index) {
    if (_cardFlipped[index] || _isGameOver) return;

    if (_gridIcons[index] == '🌟') {
      setState(() {
        _cardFlipped[index] = true;
      });
      return;
    }

    setState(() {
      _cardFlipped[index] = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      final first = _firstFlippedIndex!;
      _firstFlippedIndex = null;

      if (_gridIcons[first] == _gridIcons[index]) {
        _matchedPairs++;
        if (_matchedPairs == 4) {
          _winGame('¡Desafío de Memoria 3x3 Completado!');
        }
      } else {
        Future.delayed(const Duration(milliseconds: 550), () {
          if (mounted) {
            setState(() {
              _cardFlipped[first] = false;
              _cardFlipped[index] = false;
            });
          }
        });
      }
    }
  }

  // ==================== 3. WORD SCRAMBLE LOGIC ====================
  void _setupWordScramble() {
    _scrambledLetters = _targetWord.split('')..shuffle();
  }

  void _onLetterTap(String letter, int index) {
    if (_selectedLetters.length >= _targetWord.length) return;

    setState(() {
      _selectedLetters.add(letter);
      if (_selectedLetters.join('') == _targetWord) {
        _winGame('¡Código descifrado: DESTINO!');
      }
    });
  }

  void _winGame(String message) {
    setState(() {
      _isGameOver = true;
    });
    widget.onGameSuccess(message);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameType == 'gem_catcher' || widget.gameType == 'heart_catcher') {
      return _buildGemCatcher();
    } else if (widget.gameType == 'memory_match') {
      return _buildMemoryGrid3x3();
    } else {
      return _buildWordScramble();
    }
  }

  // --- UI GEM CATCHER ---
  Widget _buildGemCatcher() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF120B20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atrapados: $_gemsCaught / $_targetGems',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  'Tiempo: $_secondsLeft s',
                  style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          if (!_isGameOver)
            Align(
              alignment: FractionalOffset(_gemX, _gemY),
              child: GestureDetector(
                onTap: _onGemTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    _gemIcons[_currentIconIndex],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tiempo agotado', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                    onPressed: () {
                      setState(() {
                        _gemsCaught = 0;
                        _secondsLeft = 12;
                        _isGameOver = false;
                      });
                      _startGemCatcherTimer();
                    },
                    child: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- UI MEMORY 3x3 GRID ---
  Widget _buildMemoryGrid3x3() {
    return Container(
      height: 230,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF120B20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Memoria 3x3',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                'Parejas: $_matchedPairs / 4',
                style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.builder(
              itemCount: 9,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final isFlipped = _cardFlipped[index];
                final icon = _gridIcons[index];
                final isBonus = icon == '🌟';

                return GestureDetector(
                  onTap: () => _onMemoryCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isFlipped
                          ? (isBonus ? Colors.amber.withValues(alpha: 0.25) : const Color(0xFF2E1548))
                          : const Color(0xFF1E1035),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFlipped
                            ? (isBonus ? Colors.amber : Colors.purpleAccent)
                            : Colors.white24,
                        width: isFlipped ? 1.5 : 1,
                      ),
                      boxShadow: [
                        if (isFlipped)
                          BoxShadow(
                            color: isBonus ? Colors.amber.withValues(alpha: 0.4) : Colors.purpleAccent.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isFlipped ? icon : '❓',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI WORD SCRAMBLE (SIN OVERFLOW) ---
  Widget _buildWordScramble() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF120B20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Descifra la palabra clave:',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),

          // User letters display en FittedBox para evitar overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1035),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                _selectedLetters.isEmpty
                    ? '_ ' * _targetWord.length
                    : _selectedLetters.join(' '),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Letter Tiles compactos y con wrap ajustado
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_scrambledLetters.length, (index) {
              final letter = _scrambledLetters[index];
              return SizedBox(
                width: 34,
                height: 34,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E1548),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.purpleAccent),
                    ),
                  ),
                  onPressed: () => _onLetterTap(letter, index),
                  child: Text(
                    letter,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),

          TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 24)),
            onPressed: () {
              setState(() {
                _selectedLetters.clear();
              });
            },
            icon: const Icon(Icons.cleaning_services_rounded, size: 12, color: Colors.white38),
            label: const Text('Limpiar', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
