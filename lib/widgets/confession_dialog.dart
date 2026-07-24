import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_assets.dart';

enum ConfessionResponse {
  pending,
  accepted,
  declined,
}

class ConfessionDialog extends StatefulWidget {
  final VoidCallback onAccept;

  const ConfessionDialog({
    super.key,
    required this.onAccept,
  });

  @override
  State<ConfessionDialog> createState() => _ConfessionDialogState();
}

class _ConfessionDialogState extends State<ConfessionDialog> {
  ConfessionResponse _response = ConfessionResponse.pending;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0),
      backgroundColor: const Color(0xFF230D2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.amber, width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 130,
              child: Lottie.asset(
                AppAssets.giftOpeningLottie,
                repeat: true,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'DÍA 30 • EL RETO FINAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'El Comienzo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF14071C),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Durante estos 30 días hemos compartido recuerdos, risas y nos hemos conocido mucho mejor día a día.\n\nHoy llegamos al final de este primer capítulo, y quiero dar el siguiente paso contigo.\n\n¿Aceptas que seamos pareja oficialmente?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  if (_response == ConfessionResponse.accepted) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            '¡Oficialmente Pareja!',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_response == ConfessionResponse.declined) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purpleAccent),
                      ),
                      child: const Text(
                        'Entendido perfectamente. Lo importante es ir a nuestro propio ritmo sin presiones. ✨',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_response == ConfessionResponse.pending)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        setState(() {
                          _response = ConfessionResponse.accepted;
                        });
                        widget.onAccept();
                      },
                      child: const Text(
                        '¡Sí, acepto!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white60,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        setState(() {
                          _response = ConfessionResponse.declined;
                        });
                      },
                      child: const Text(
                        'Aún no / Necesito un tiempo',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  _response == ConfessionResponse.accepted ? 'Guardar Registro' : 'Cerrar',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
