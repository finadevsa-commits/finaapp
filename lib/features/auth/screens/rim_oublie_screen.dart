import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/shared_widgets.dart';

class RimOublieScreen extends StatefulWidget {
  const RimOublieScreen({super.key});
  @override
  State<RimOublieScreen> createState() => _RimOublieScreenState();
}

class _RimOublieScreenState extends State<RimOublieScreen> {
  final _ctrl     = Get.find<AuthController>();
  final _compteCtrl = TextEditingController();
  final _telCtrl    = TextEditingController();

  @override
  void dispose() {
    _compteCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RIM oublié'),
        backgroundColor: AppColors.surfaceDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Icône + titre
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search_rounded,
                    color: AppColors.primary, size: 34),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Retrouvez votre numéro membre',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DMSans',
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Entrez un de vos numéros de compte\net votre numéro de téléphone enregistré.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Champ numéro de compte
            FieldLabel(label: 'Numéro de compte'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _compteCtrl,
              decoration: const InputDecoration(
                hintText: 'Ex: 222-U123456',
                prefixIcon: Icon(Icons.account_balance_outlined,
                    color: AppColors.primary),
              ),
              onChanged: (_) => _ctrl.clearError(),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Champ téléphone
            FieldLabel(label: 'Numéro de téléphone'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Ex: 97000000',
                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
              ),
              onChanged: (_) => _ctrl.clearError(),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 12),

            Obx(() {
              if (_ctrl.errorMessage.isEmpty) return const SizedBox.shrink();
              return ErrorBanner(message: _ctrl.errorMessage.value).animate().fadeIn();
            }),

            const SizedBox(height: 32),

            Obx(() => PrimaryButton(
              label: 'ENVOYER LE CODE',
              isLoading: _ctrl.isLoading.value,
              onPressed: () => _ctrl.rimOublieEnvoyerOtp(
                numeroCompte: _compteCtrl.text,
                telephone: _telCtrl.text,
              ),
            )).animate(delay: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
