import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/shared_widgets.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _ctrl     = Get.find<AuthController>();
  final _otpCtrl  = TextEditingController();
  int _countdown  = 60;
  late final _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_countdown > 0) _countdown--;
      });
      return _countdown > 0;
    });
  }

  void _resetCountdown() {
    setState(() => _countdown = 60);
    _startCountdown();
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AuthHeader(
            title: 'Vérification\ndu code',
            subtitle: 'Code envoyé au ${_ctrl.telephoneMasque.value}',
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                children: [
                  // Icône SMS
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sms_outlined,
                        color: AppColors.primary, size: 38),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 32),

                  // Champ PIN OTP (6 chiffres) via Pinput
                  OtpField(
                    controller: _otpCtrl,
                    onCompleted: (val) => _ctrl.verifierOtp(val),
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 16),

                  Obx(() {
                    if (_ctrl.errorMessage.isEmpty) return const SizedBox.shrink();
                    return ErrorBanner(message: _ctrl.errorMessage.value)
                        .animate()
                        .fadeIn()
                        .shakeX();
                  }),

                  const SizedBox(height: 28),

                  // Bouton vérifier
                  Obx(() => PrimaryButton(
                    label: 'VÉRIFIER',
                    isLoading: _ctrl.isLoading.value,
                    onPressed: () => _ctrl.verifierOtp(_otpCtrl.text),
                  )).animate(delay: 300.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Renvoi OTP avec countdown
                  _ctrl.isLoading.value
                      ? const SizedBox.shrink()
                      : _countdown > 0
                      ? RichText(
                    text: TextSpan(
                      text: 'Renvoyez dans ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                      children: [
                        TextSpan(
                          text: '$_countdown s',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )
                      : TextButton.icon(
                    onPressed: () {
                      _resetCountdown();
                      _ctrl.renvoyerOtp();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('RENVOYER LE CODE'),
                  ),

                  Obx(() {
                    if (_ctrl.successMessage.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Text(_ctrl.successMessage.value,
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ).animate().fadeIn();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}