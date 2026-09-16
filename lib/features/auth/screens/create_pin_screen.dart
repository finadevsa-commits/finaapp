import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../controllers/auth_controller.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _ctrl    = Get.find<AuthController>();
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [

          // ── Header dynamique ──────────────────────────────────────────
          Obx(() => AuthHeader(
            title: _ctrl.pinStep.value == 1
                ? 'Créez votre\ncode PIN'
                : 'Confirmez\nvotre PIN',
            subtitle: _ctrl.pinStep.value == 1
                ? 'Choisissez un code à 4 chiffres pour sécuriser l\'accès'
                : 'Ressaisissez le même code PIN pour confirmer',
          )),

          // ── Corps scrollable ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24, 32, 24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  children: [

                    // Indicateur étapes
                    Obx(() => _StepsIndicator(
                      currentStep: _ctrl.pinStep.value,
                    )),

                    const SizedBox(height: 36),

                    // Icône cadenas — simple changement de couleur sans animation
                    Obx(() => _LockIcon(
                      isConfirmStep: _ctrl.pinStep.value == 2,
                    )),

                    const SizedBox(height: 28),

                    // Texte indicatif
                    Obx(() => Text(
                      _ctrl.pinStep.value == 1
                          ? 'Saisissez votre code PIN'
                          : 'Confirmez votre code PIN',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'DMSans',
                      ),
                    )),

                    const SizedBox(height: 24),

                    // Champ PIN — rebuild complet via key string
                    Obx(() => _PinInputField(
                      stepKey: _ctrl.pinStep.value,
                      controller: _pinCtrl,
                      onCompleted: (val) {
                        _ctrl.soumettrePin(val);
                        _pinCtrl.clear();
                      },
                    )),

                    const SizedBox(height: 16),

                    // Message d'erreur
                    Obx(() {
                      if (_ctrl.errorMessage.isEmpty) {
                        return const SizedBox(height: 0);
                      }
                      return Column(
                        children: [
                          ErrorBanner(message: _ctrl.errorMessage.value),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    // Indicateur de chargement
                    Obx(() {
                      if (!_ctrl.isLoading.value) {
                        return const SizedBox(height: 0);
                      }
                      return const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      );
                    }),
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


// ── Indicateur d'étapes — widget stateless simple ─────────────────────────────
class _StepsIndicator extends StatelessWidget {
  final int currentStep;

  const _StepsIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepCircle(number: 1, isActive: true),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 2,
          color: currentStep >= 2 ? AppColors.primary : AppColors.divider,
        ),
        _StepCircle(number: 2, isActive: currentStep >= 2),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool isActive;

  const _StepCircle({required this.number, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : AppColors.divider,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'DMSans',
          ),
        ),
      ),
    );
  }
}


// ── Icône cadenas — sans AnimatedSwitcher ─────────────────────────────────────
class _LockIcon extends StatelessWidget {
  final bool isConfirmStep;

  const _LockIcon({required this.isConfirmStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isConfirmStep
            ? AppColors.success.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isConfirmStep
            ? Icons.lock_rounded
            : Icons.lock_outline_rounded,
        color: isConfirmStep ? AppColors.success : AppColors.primary,
        size: 38,
      ),
    );
  }
}


// ── Champ PIN — rebuild via StatefulWidget avec key ───────────────────────────
// On utilise un StatefulWidget séparé avec une key pour forcer le rebuild
// sans passer par AnimatedSwitcher qui cause le conflit sémantique
class _PinInputField extends StatefulWidget {
  final int stepKey;
  final TextEditingController controller;
  final Function(String) onCompleted;

  const _PinInputField({
    required this.stepKey,
    required this.controller,
    required this.onCompleted,
  });

  @override
  State<_PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<_PinInputField> {
  @override
  Widget build(BuildContext context) {
    return Pinput(
      // ✅ Key basée sur stepKey pour forcer le rebuild propre
      key: ValueKey('pinput_step_${widget.stepKey}'),
      controller: widget.controller,
      length: 4,
      keyboardType: TextInputType.number,
      obscureText: true,
      autofocus: true,
      onCompleted: widget.onCompleted,
      defaultPinTheme: PinTheme(
        width: 68,
        height: 68,
        textStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: 'DMSans',
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.background,
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2.5),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withOpacity(0.04),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 68,
        height: 68,
        textStyle: const TextStyle(
          fontSize: 26,
          color: Colors.white,
          fontFamily: 'DMSans',
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}