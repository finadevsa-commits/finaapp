import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/models/operation_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../controllers/transfert_controller.dart';

class TransfertScreen extends StatefulWidget {
  const TransfertScreen({super.key});
  @override
  State<TransfertScreen> createState() => _TransfertScreenState();
}

class _TransfertScreenState extends State<TransfertScreen> {
  final ctrl = Get.find<TransfertController>();
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transfert'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Obx(() => IconButton(
          icon: Icon(
            ctrl.step.value > 1
                ? Icons.arrow_back_ios_new_rounded
                : Icons.close_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (ctrl.step.value > 1) {
              ctrl.step.value--;
            } else {
              ctrl.reset();
              Get.back();
            }
          },
        )),
      ),
      body: Obx(() {
        switch (ctrl.step.value) {
          case 1: return _EtapeRecherche(ctrl: ctrl, searchCtrl: _searchCtrl);
          case 2: return _EtapeConfirmation(ctrl: ctrl);
          case 3: return _EtapeSucces(ctrl: ctrl);
          default: return const SizedBox.shrink();
        }
      }),
    );
  }
}

class _EtapeRecherche extends StatelessWidget {
  final TransfertController ctrl;
  final TextEditingController searchCtrl;
  const _EtapeRecherche({required this.ctrl, required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur étapes
          _StepIndicator(currentStep: 1),
          const SizedBox(height: 24),

          Text('Rechercher un bénéficiaire',
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                fontFamily: 'DMSans',
              )),
          const SizedBox(height: 8),
          Text(
            'Saisissez le RIM ou le numéro de compte du bénéficiaire',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Champ recherche
          TextFormField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Ex: U12345 ou 222-U123456',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: Obx(() => ctrl.isSearching.value
                  ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ))
                  : IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                onPressed: () =>
                    ctrl.rechercherBeneficiaire(searchCtrl.text),
              )),
            ),
            onFieldSubmitted: ctrl.rechercherBeneficiaire,
            onChanged: (_) => ctrl.errorMessage.value = '',
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 12),

          Obx(() {
            if (ctrl.errorMessage.isNotEmpty) {
              return ErrorBanner(message: ctrl.errorMessage.value)
                  .animate().fadeIn().shakeX();
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 20),

          // Résultat bénéficiaire
          Obx(() {
            if (ctrl.beneficiaireNom.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card bénéficiaire
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ctrl.beneficiaireInitiales.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ctrl.beneficiaireNom.value,
                                style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700,
                                  fontFamily: 'DMSans',
                                )),
                            Text('RIM : ${ctrl.beneficiaireRim.value}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 24),
                    ],
                  ),
                ).animate().fadeIn().scale(
                    begin: const Offset(0.95, 0.95), duration: 300.ms),

                const SizedBox(height: 16),

                // Sélection compte destination
                if (ctrl.beneficiaireComptes.isNotEmpty) ...[
                  Text('Compte destination',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ...ctrl.beneficiaireComptes.map((c) {
                    final num = c['numero_compte'] ?? '';
                    final type = c['type_compte'] ?? '';
                    return Obx(() => GestureDetector(
                      onTap: () => ctrl.compteDestSelected.value = num,
                      child: AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: ctrl.compteDestSelected.value == num
                              ? AppColors.primary.withOpacity(0.07)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ctrl.compteDestSelected.value == num
                                ? AppColors.primary
                                : AppColors.divider,
                            width: ctrl.compteDestSelected.value == num ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(num,
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w700,
                                          fontFamily: 'DMSans')),
                                  Text(type,
                                      style: TextStyle(
                                          fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            if (ctrl.compteDestSelected.value == num)
                              const Icon(Icons.radio_button_checked,
                                  color: AppColors.primary, size: 20)
                            else
                              const Icon(Icons.radio_button_unchecked,
                                  color: AppColors.divider, size: 20),
                          ],
                        ),
                      ),
                    ));
                  }),
                ],

                const SizedBox(height: 20),

                // Montant
                Text('Montant (FCFA)',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: ctrl.montantCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    fontFamily: 'DMSans',
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'FCFA',
                    suffixStyle: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                ),

                const SizedBox(height: 12),

                // Motif (optionnel)
                TextFormField(
                  controller: ctrl.motifCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Motif (optionnel)',
                    prefixIcon: Icon(Icons.edit_note_rounded,
                        color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 24),

                Obx(() => PrimaryButton(
                  label: 'CONTINUER',
                  isLoading: ctrl.isLoading.value,
                  onPressed: ctrl.demanderOtp,
                )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _EtapeConfirmation extends StatelessWidget {
  final TransfertController ctrl;
  const _EtapeConfirmation({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _StepIndicator(currentStep: 2),
          const SizedBox(height: 24),

          // Résumé transfert
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text('Vous envoyez',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '${ctrl.montantCtrl.text} FCFA',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 32,
                    fontWeight: FontWeight.w800, fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_downward_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(ctrl.beneficiaireNom.value,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ],
                ),
                Text(ctrl.compteDestSelected.value,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Champ OTP
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.sms_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => Text(
                        'Code envoyé au ${ctrl.telephoneMasque.value}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ctrl.otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    letterSpacing: 8, fontFamily: 'DMSans',
                  ),
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                  onChanged: (_) => ctrl.errorMessage.value = '',
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 12),

          Obx(() {
            if (ctrl.errorMessage.isEmpty) return const SizedBox.shrink();
            return ErrorBanner(message: ctrl.errorMessage.value)
                .animate().fadeIn().shakeX();
          }),

          const SizedBox(height: 20),

          Obx(() => PrimaryButton(
            label: 'CONFIRMER LE TRANSFERT',
            isLoading: ctrl.isLoading.value,
            onPressed: ctrl.executerTransfert,
          )).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _EtapeSucces extends StatelessWidget {
  final TransfertController ctrl;
  const _EtapeSucces({required this.ctrl});

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
            ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),

            const SizedBox(height: 24),

            const Text('Transfert effectué !',
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800,
                  fontFamily: 'DMSans',
                )).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 8),

            Obx(() => Text(
              '${ctrl.montantTransfere.value.toStringAsFixed(0)} FCFA\nenvoyés à ${ctrl.beneficiaireNom.value}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, color: AppColors.textSecondary, height: 1.5,
              ),
            )).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 8),

            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Réf: ${ctrl.reference.value}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary,
                      fontFamily: 'DMSans')),
            )).animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 40),

            PrimaryButton(
              label: 'RETOUR À L\'ACCUEIL',
              isLoading: false,
              onPressed: () {
                ctrl.reset();
                Get.offAllNamed(AppRoutes.HOME);
              },
            ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

// Indicateur d'étapes transfert
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Step(num: 1, label: 'Bénéficiaire', isActive: currentStep >= 1, isDone: currentStep > 1),
        _StepLine(isDone: currentStep > 1),
        _Step(num: 2, label: 'Confirmation', isActive: currentStep >= 2, isDone: currentStep > 2),
        _StepLine(isDone: currentStep > 2),
        _Step(num: 3, label: 'Succès', isActive: currentStep >= 3, isDone: false),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int num;
  final String label;
  final bool isActive;
  final bool isDone;
  const _Step({required this.num, required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: 300.ms,
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.divider,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text('$num', style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isDone;
  const _StepLine({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: 300.ms,
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isDone ? AppColors.primary : AppColors.divider,
      ),
    );
  }
}
