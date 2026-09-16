import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/shared_widgets.dart';

class BiometrieScreen extends StatelessWidget {
  const BiometrieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();

    return Scaffold(
      body: Column(
        children: [
          // Header bleu sombre
          Container(
            height: MediaQuery.of(context).size.height * 0.48,
            width: double.infinity,
            color: AppColors.surfaceDark,
            child: Stack(
              children: [
                // Cercle décoratif
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration biométrie
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.fingerprint_rounded,
                                  size: 100,
                                  color: Colors.white),
                              Positioned(
                                bottom: 24,
                                right: 24,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.surfaceDark, width: 3),
                                  ),
                                  child: const Icon(Icons.face_retouching_natural,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Zone texte + boutons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Authentification\nBiométrique',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      fontFamily: 'DMSans',
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  Text(
                    'Activez l\'authentification biométrique pour sécuriser l\'accès et valider vos opérations plus rapidement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const Spacer(),

                  Obx(() => PrimaryButton(
                    label: 'ACTIVER',
                    isLoading: ctrl.isLoading.value,
                    onPressed: ctrl.activerBiometrie,
                  )).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: ctrl.passerBiometrie,
                      child: const Text('PLUS TARD'),
                    ),
                  ).animate(delay: 500.ms).fadeIn(),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

