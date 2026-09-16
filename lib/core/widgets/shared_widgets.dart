import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import '../theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({ super.key,required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AuthHeaderClipper(),
      child: Container(
        width: double.infinity,
        color: AppColors.surfaceDark,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 32,
          left: 28,
          right: 28,
          bottom: 52,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo petit
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('F',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        )),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MY FINAAPP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
                fontFamily: 'DMSans',
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.65),
                height: 1.4,
              ),
            ).animate(delay: 150.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class AuthHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(AuthHeaderClipper old) => false;
}

// Bouton principal
class PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2.5),
        )
            : Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontFamily: 'DMSans',
          ),
        ),
      ),
    );
  }
}

// Champ OTP 6 chiffres
class OtpField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;

  const OtpField({super.key,required this.controller, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: controller,
      length: 6,
      keyboardType: TextInputType.number,
      autofocus: true,
      onCompleted: onCompleted,
      defaultPinTheme: PinTheme(
        width: 48,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: 'DMSans',
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 48,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          fontFamily: 'DMSans',
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 48,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
          fontFamily: 'DMSans',
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Champ PIN 4 chiffres
class PinField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;

  const PinField({ super.key,required this.controller, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: controller,
      length: 4,
      keyboardType: TextInputType.number,
      obscureText: true,
      autofocus: true,
      onCompleted: onCompleted,
      defaultPinTheme: PinTheme(
        width: 64,
        height: 72,
        textStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 64,
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2.5),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withOpacity(0.05),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 64,
        height: 72,
        textStyle: const TextStyle(fontSize: 28, color: Colors.white),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// Bannière d'erreur
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({  super.key,required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Label de champ
class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        fontFamily: 'DMSans',
      ),
    );
  }
}

// Dot d'étape PIN
class StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const StepDot({  super.key,required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.divider,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Formatter majuscules
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    return value.copyWith(text: value.text.toUpperCase());
  }
}