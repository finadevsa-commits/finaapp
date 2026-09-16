import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/shared_widgets.dart';

class EnterRimScreen extends StatefulWidget {
  const EnterRimScreen({super.key});
  @override
  State<EnterRimScreen> createState() => _EnterRimScreenState();
}

class _EnterRimScreenState extends State<EnterRimScreen> {
  final _controller = Get.find<AuthController>();
  final _rimCtrl    = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  @override
  void dispose() {
    _rimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Header bleu sombre avec courbe ──────────────────────────────
          AuthHeader(
            title: 'Bienvenue sur\nMY FINAAPP',
            subtitle: 'Saisissez votre numéro membre FINADEV pour continuer',
          ),

          // ── Formulaire ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      'Numéro membre (RIM)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Champ RIM
                    TextFormField(
                      controller: _rimCtrl,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                        LengthLimitingTextInputFormatter(10),
                        UpperCaseFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Ex: U12345',
                        prefixIcon: const Icon(Icons.badge_outlined,
                            color: AppColors.primary),
                        suffixIcon: Obx(() => _controller.errorMessage.isNotEmpty
                            ? const Icon(Icons.error_outline,
                            color: AppColors.error)
                            : const SizedBox.shrink()),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontFamily: 'DMSans',
                      ),
                      onChanged: (_) => _controller.clearError(),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 12),

                    // Message d'erreur
                    Obx(() {
                      if (_controller.errorMessage.isEmpty) return const SizedBox.shrink();
                      return ErrorBanner(message: _controller.errorMessage.value)
                          .animate()
                          .fadeIn()
                          .shakeX();
                    }),

                    const SizedBox(height: 32),

                    // Bouton continuer
                    Obx(() => PrimaryButton(
                      label: 'CONTINUER',
                      isLoading: _controller.isLoading.value,
                      onPressed: () {
                        if (_rimCtrl.text.trim().isNotEmpty) {
                          _controller.soumettrRim(_rimCtrl.text);
                        }
                      },
                    )).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ou',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Bouton RIM oublié
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.RIM_OUBLIE),
                        icon: const Icon(Icons.help_outline_rounded, size: 20),
                        label: const Text('RIM OUBLIÉ ?'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ).animate(delay: 400.ms).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
