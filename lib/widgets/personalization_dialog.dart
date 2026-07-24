import 'package:flutter/material.dart';

class PersonalizationDialog extends StatefulWidget {
  final String currentTheme;
  final String currentTitle;
  final Function(String themeId, String customTitle) onSave;

  const PersonalizationDialog({
    super.key,
    required this.currentTheme,
    required this.currentTitle,
    required this.onSave,
  });

  @override
  State<PersonalizationDialog> createState() => _PersonalizationDialogState();
}

class _PersonalizationDialogState extends State<PersonalizationDialog> {
  late String _selectedTheme;
  late TextEditingController _titleController;

  final List<Map<String, String>> _themes = [
    {'id': 'cosmic', 'name': '🌌 Noche Cósmica', 'desc': 'Violeta profundo y dorado místico'},
    {'id': 'sunset', 'name': '🌅 Atardecer Mágico', 'desc': 'Cálidos tonos de atardecer y rosa'},
    {'id': 'aurora', 'name': '🌲 Aurora Boreal', 'desc': 'Tonos esmeralda, cian y menta'},
    {'id': 'pink_galaxy', 'name': '💖 Galaxia Magenta', 'desc': 'Brillos rosa y magenta cósmico'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _titleController = TextEditingController(text: widget.currentTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0),
      backgroundColor: const Color(0xFF1B0D33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.amber, width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  'Personalización de la App',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Título Personalizado
            const Text(
              'Título del Encabezado / Nombres:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej. CAMINO DE JOHAN & MARIA',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
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
            const SizedBox(height: 18),

            // Selector de Temas
            const Text(
              'Tema del Fondo Cósmico:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Column(
              children: _themes.map((theme) {
                final isSelected = _selectedTheme == theme['id'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTheme = theme['id']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? Colors.amber : Colors.white38,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  theme['name']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.amber : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  theme['desc']!,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final String title = _titleController.text.trim().isEmpty
                        ? 'ASCENSO AL DÍA 30'
                        : _titleController.text.trim().toUpperCase();
                    widget.onSave(_selectedTheme, title);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Guardar Tema', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
