import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_assets.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F081D),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Magic Circle Lottie Animation in center as Splash
          Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: Lottie.asset(
                AppAssets.magicCircleLottie,
                repeat: true,
              ),
            ),
          ),

          // Logo overlaid in center
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.logo,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'ENCANTARIO',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Capítulo Uno • El Camino del Corazón',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
