import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _navigate();
  }

  Future<void> _navigate() async {
    // Attendre l'animation splash
    await Future.delayed(const Duration(milliseconds: 2800));

    // Récupérer StorageService de façon robuste
    // Attendre jusqu'à 3 secondes que le service soit disponible
    StorageService? storage;
    int attempts = 0;

    while (storage == null && attempts < 6) {
      try {
        storage = Get.find<StorageService>();
      } catch (_) {
        attempts++;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Si toujours pas disponible → aller sur ENTER_RIM par défaut
    if (storage == null) {
      Get.offAllNamed(AppRoutes.ENTER_RIM);
      return;
    }

    // Navigation selon l'état de l'app
    if (!storage.isOnboardingDone()) {
      Get.offAllNamed(AppRoutes.ONBOARDING);
      return;
    }

    final hasToken = await storage.hasToken();
    if (hasToken) {
      Get.offAllNamed(AppRoutes.LOCK_SCREEN);
    } else {
      Get.offAllNamed(AppRoutes.ENTER_RIM);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2D45),
              Color(0xFF1A4A6B),
              Color(0xFF0F2D45),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Cercles décoratifs
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.10),
                ),
              ),
            ),

            // Contenu central
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        color: AppColors.primary,
                        child: const Center(
                          child: Text(
                            'F',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Nom app
                  const Text(
                    'MY FINAAPP',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontFamily: 'DMSans',
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Votre banque dans votre poche',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.65),
                      letterSpacing: 0.5,
                      fontFamily: 'DMSans',
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 60),

                  // Barre de chargement
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        color: AppColors.primary,
                        minHeight: 3,
                      ),
                    ),
                  ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // Version en bas
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'FINADEV SA  •  v${AppConstants.appVersion}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35),
                  letterSpacing: 1,
                ),
              ).animate(delay: 1000.ms).fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}