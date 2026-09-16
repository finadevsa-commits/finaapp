import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/models/operation_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../controllers/releve_controller.dart';

class ReleveScreen extends StatelessWidget {
  const ReleveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReleveController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Relevé de compte'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sélection période ─────────────────────────────────────────
            Text(
              'Sélectionnez une plage de dates',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'DMSans',
              ),
            ),

            const SizedBox(height: 14),

            // Raccourcis
            Obx(() => Row(
              children: ['7 Jours', '30 Jours', '90 Jours'].map((label) {
                final jours = int.parse(label.split(' ')[0]);
                final isActive = ctrl.periodeActive.value == jours.toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ctrl.selectionnerPeriode(jours),
                    child: AnimatedContainer(
                      duration: 250.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                        boxShadow: isActive
                            ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                            : [],
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontFamily: 'DMSans',
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // Champs de dates
            _DateField(
              label: 'Date de début *',
              value: ctrl.dateDebut,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(ctrl.dateDebut.value) ??
                      DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  ctrl.dateDebut.value =
                      picked.toString().substring(0, 10);
                  ctrl.periodeActive.value = '';
                }
              },
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 12),

            _DateField(
              label: 'Date de fin *',
              value: ctrl.dateFin,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                  DateTime.tryParse(ctrl.dateFin.value) ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme:
                      ColorScheme.light(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  ctrl.dateFin.value = picked.toString().substring(0, 10);
                  ctrl.periodeActive.value = '';
                }
              },
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Bouton obtenir relevé
            Obx(() => PrimaryButton(
              label: 'OBTENIR LE RELEVÉ',
              isLoading: ctrl.isLoading.value,
              onPressed: ctrl.chargerReleve,
            )).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 24),

            // ── Résultats ─────────────────────────────────────────────────
            Obx(() {
              if (!ctrl.releveCharge.value) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card résumé
                  _ReleveResume(ctrl: ctrl)
                      .animate()
                      .fadeIn()
                      .slideY(begin: 0.15),

                  const SizedBox(height: 20),

                  // Bouton télécharger PDF
                  _DownloadPdfButton()
                      .animate(delay: 100.ms)
                      .fadeIn(),

                  const SizedBox(height: 20),

                  // Transactions de la période
                  if (ctrl.operations.isNotEmpty) ...[
                    Text(
                      'Transactions récentes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...ctrl.operations.asMap().entries.map(
                          (e) => _ReleveOperationTile(
                        op: e.value,
                        index: e.key,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final RxString value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(() => Text(
                value.value.isEmpty ? label : value.value,
                style: TextStyle(
                  fontSize: 14,
                  color: value.value.isEmpty
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                  fontWeight: value.value.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w600,
                  fontFamily: 'DMSans',
                ),
              )),
            ),
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ReleveResume extends StatelessWidget {
  final ReleveController ctrl;
  const _ReleveResume({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ResumeRow(
            label: 'Solde actuel',
            value: ctrl.formaterMontant(ctrl.soldeFin.value),
            valueStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _ResumeRow(
            label: 'Argent entrant',
            value: '+${ctrl.formaterMontant(ctrl.totalCredit.value)}',
            valueStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.credit,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 8),
          _ResumeRow(
            label: 'Argent sortant',
            value: '-${ctrl.formaterMontant(ctrl.totalDebit.value)}',
            valueStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.debit,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 8),
          _ResumeRow(
            label: 'Période',
            value:
            'Du ${ctrl.dateDebut.value} au ${ctrl.dateFin.value}',
            valueStyle: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;
  const _ResumeRow({
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _DownloadPdfButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.snackbar(
        'Bientôt disponible',
        'Le téléchargement PDF sera disponible prochainement.',
        backgroundColor: AppColors.info,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Obtenir relevés',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleveOperationTile extends StatelessWidget {
  final OperationModel op;
  final int index;
  const _ReleveOperationTile({required this.op, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: op.isCredit
                  ? AppColors.credit.withOpacity(0.1)
                  : AppColors.debit.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              op.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: op.isCredit ? AppColors.credit : AppColors.debit,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(op.description,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(op.date,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '${op.isCredit ? '+' : '-'} ${op.montantFormate}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: op.isCredit ? AppColors.credit : AppColors.debit,
              fontFamily: 'DMSans',
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
  }
}
