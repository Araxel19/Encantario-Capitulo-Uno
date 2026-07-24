import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_assets.dart';
import '../models/day_challenge.dart';
import 'minigames_widget.dart';

class DayDetailDialog extends StatefulWidget {
  final DayChallenge challenge;
  final Function(String answer, String? imagePath) onSaveAnswer;

  const DayDetailDialog({
    super.key,
    required this.challenge,
    required this.onSaveAnswer,
  });

  @override
  State<DayDetailDialog> createState() => _DayDetailDialogState();
}

class _DayDetailDialogState extends State<DayDetailDialog> {
  late TextEditingController _textController;
  int? _selectedOptionIndex;
  bool _gamePassed = false;
  String _gameResultText = '';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.challenge.userAnswer ?? '');
    _imagePath = widget.challenge.imagePath;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _shareViaWhatsApp() {
    final challenge = widget.challenge;
    final String answerText = _textController.text.isNotEmpty
        ? _textController.text
        : (_selectedOptionIndex != null && challenge.options != null
            ? challenge.options![_selectedOptionIndex!]
            : (_gameResultText.isNotEmpty ? _gameResultText : '¡Reto Completado!'));

    final bool isMusic = challenge.title.toLowerCase().contains('canción') ||
        challenge.title.toLowerCase().contains('melodía') ||
        challenge.title.toLowerCase().contains('banda sonora') ||
        challenge.prompt.toLowerCase().contains('canciones');

    final String labelHeader = isMusic ? '🎶 Recomendación Musical / Playlist' : '💬 Respuesta';

    final String message = '''
✨ ENCANTARIO: CAPÍTULO UNO ✨
📌 Día ${challenge.dayNumber}: ${challenge.title}
$labelHeader:
"$answerText"

👉 ¡Tu turno para responder en la app!
''';

    if (_imagePath != null && File(_imagePath!).existsSync()) {
      Share.shareXFiles([XFile(_imagePath!)], text: message);
    } else {
      Share.share(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final isMilestone = challenge.isMilestone;
    final isCompleted = challenge.isCompleted;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0),
      backgroundColor: const Color(0xFF1E1035),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isMilestone ? Colors.amber : Colors.purpleAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation or Icon Header
            if (isMilestone)
              SizedBox(
                height: 120,
                child: Lottie.asset(
                  AppAssets.giftOpeningLottie,
                  repeat: true,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Image.asset(
                  isCompleted ? AppAssets.cardComplete : AppAssets.cardOpen,
                  height: 70,
                ),
              ),

            // Category Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isMilestone
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.purple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMilestone ? Colors.amber : Colors.purpleAccent,
                ),
              ),
              child: Text(
                'DÍA ${challenge.dayNumber} • ${challenge.category.toUpperCase()}',
                style: TextStyle(
                  color: isMilestone ? Colors.amber : Colors.purpleAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              challenge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Prompt Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF120B20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                challenge.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Render Content based on Challenge Type
            if (challenge.type == ChallengeType.multipleChoice && challenge.options != null)
              _buildMultipleChoice(challenge.options!)
            else if (challenge.type == ChallengeType.miniGame && challenge.gameType != null)
              MiniGamesWidget(
                gameType: challenge.gameType!,
                onGameSuccess: (result) {
                  setState(() {
                    _gamePassed = true;
                    _gameResultText = result;
                    _textController.text = result;
                  });
                },
              )
            else
              // Open Question Text Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (challenge.title.toLowerCase().contains('canción') ||
                      challenge.title.toLowerCase().contains('melodía') ||
                      challenge.title.toLowerCase().contains('banda sonora') ||
                      challenge.prompt.toLowerCase().contains('canciones')) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.music_note_rounded, color: Colors.amber, size: 16),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Puedes escribir los nombres de las canciones o pegar enlaces de Spotify / YouTube / audio.',
                              style: TextStyle(color: Colors.amber, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: (challenge.title.toLowerCase().contains('canción') ||
                              challenge.title.toLowerCase().contains('melodía') ||
                              challenge.title.toLowerCase().contains('banda sonora') ||
                              challenge.prompt.toLowerCase().contains('canciones'))
                          ? 'Ej. 1. Canción - Artista (o enlace Spotify/YouTube)'
                          : 'Escribe tu respuesta o experiencia aquí...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF120B20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Image attachment UI
                  if (_imagePath != null && File(_imagePath!).existsSync())
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imagePath = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xB3000000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                      label: const Text('Adjuntar Foto o Recurso 📷', style: TextStyle(fontSize: 13)),
                    ),
                ],
              ),
            const SizedBox(height: 16),

            // WhatsApp Share Button (if answered or completed)
            if (isCompleted || _textController.text.isNotEmpty || _selectedOptionIndex != null || _gamePassed || _imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _shareViaWhatsApp,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text(
                      'Compartir por WhatsApp (Texto y Foto)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    String answer = _textController.text;
                    if (challenge.type == ChallengeType.multipleChoice &&
                        _selectedOptionIndex != null &&
                        challenge.options != null) {
                      answer = challenge.options![_selectedOptionIndex!];
                    }
                    widget.onSaveAnswer(
                      answer.isEmpty ? '¡Día Completado!' : answer,
                      _imagePath,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    isCompleted ? 'Guardar Cambios' : '¡Completar Día!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoice(List<String> options) {
    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        final isSelected = _selectedOptionIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedOptionIndex = index;
                _textController.text = option;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple.shade900 : const Color(0xFF120B20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.amber : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.amber : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
