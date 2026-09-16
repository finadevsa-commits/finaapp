import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/operation_model.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../controllers/depot_momo_controller.dart';

class DepotMomoScreen extends StatelessWidget {
  const DepotMomoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DepotMomoController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dépôt MoMo'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: Obx(() => ctrl.step.value == 2
          ? _DepotSucces(ctrl: ctrl)
          : _DepotFormulaire(ctrl: ctrl)),
    );
  }
}

class _DepotFormulaire extends StatelessWidget {
  final DepotMomoController ctrl;
  const _DepotFormulaire({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Sélection opérateur
          Text('Opérateur Mobile Money',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, fontFamily: 'DMSans')),
          const SizedBox(height: 10),

          Obx(() => Row(
            children: ['MTN', 'MOOV'].map((op) {
              final isActive = ctrl.operateurSelec.value == op;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.operateurSelec.value = op,
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: EdgeInsets.only(right: op == 'MTN' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (op == 'MTN'
                          ? const Color(0xFFFFCC00)
                          : const Color(0xFF0066CC))
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? Colors.transparent
                            : AppColors.divider,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Text(op == 'MTN' ? '📱' : '📱',
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          op == 'MTN' ? 'MTN MoMo' : 'Moov Money',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? (op == 'MTN' ? Colors.black87 : Colors.white)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Compte FINADEV destination
          FieldLabel(label: 'Compte FINADEV destination'),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl.compteDestCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.account_balance_outlined,
                  color: AppColors.primary),
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 14),

          // Numéro MoMo
          FieldLabel(label: 'Numéro ${ctrl.operateurSelec.value} MoMo'),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl.telMomoCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Ex: 97000000',
              prefixIcon: const Icon(Icons.phone_android_rounded,
                  color: AppColors.primary),
            ),
            onChanged: (_) => ctrl.errorMessage.value = '',
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 14),

          // Montant
          FieldLabel(label: 'Montant (FCFA)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl.montantCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'DMSans'),
            decoration: const InputDecoration(
              hintText: '0',
              suffixText: 'FCFA',
              suffixStyle: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
            onChanged: (_) => ctrl.errorMessage.value = '',
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 12),

          Obx(() {
            if (ctrl.errorMessage.isEmpty) return const SizedBox.shrink();
            return ErrorBanner(message: ctrl.errorMessage.value)
                .animate().fadeIn().shakeX();
          }),

          const SizedBox(height: 24),

          Obx(() => PrimaryButton(
            label: 'DÉPOSER',
            isLoading: ctrl.isLoading.value,
            onPressed: ctrl.soumettreDepot,
          )).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          // Note info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vous recevrez les instructions de paiement MoMo après validation. Votre compte FINADEV sera crédité automatiquement.',
                    style: TextStyle(
                      fontSize: 12, color: AppColors.info, height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }
}

class _DepotSucces extends StatelessWidget {
  final DepotMomoController ctrl;
  const _DepotSucces({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 56),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            const Text('Demande enregistrée !',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  fontFamily: 'DMSans',
                )).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 16),

            Obx(() => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text('Instructions de paiement',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          fontFamily: 'DMSans')),
                  const SizedBox(height: 10),
                  Text(ctrl.instructions.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary,
                          height: 1.5)),
                  const SizedBox(height: 10),
                  Text('Réf: ${ctrl.reference.value}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ],
              ),
            )).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 32),

            PrimaryButton(
              label: 'RETOUR À L\'ACCUEIL',
              isLoading: false,
              onPressed: () => Get.offAllNamed(AppRoutes.HOME),
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}