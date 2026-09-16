import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/operation_model.dart';
import '../controllers/historique_controller.dart';

class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HistoriqueController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: () => _showFilterSheet(context, ctrl),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filtres TOUS / CRÉDIT / DÉBIT ──────────────────────────────
          _FiltreBar(ctrl: ctrl),

          // ── Liste opérations ───────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: ctrl.rafraichir,
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.operations.isEmpty) {
                  return _HistoriqueSkeleton();
                }

                if (ctrl.operations.isEmpty) {
                  return _HistoriqueVide();
                }

                // Grouper par date
                final grouped = _grouperParDate(ctrl.operations);

                return ListView.builder(
                  controller: ctrl.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: grouped.length + (ctrl.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i >= grouped.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2),
                        ),
                      );
                    }

                    final item = grouped[i];

                    if (item is String) {
                      // Header de date
                      return _DateHeader(date: item);
                    }

                    return _OperationTile(
                      op: item as OperationModel,
                      index: i,
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Grouper les opérations par date
  List<dynamic> _grouperParDate(List<OperationModel> ops) {
    final result = <dynamic>[];
    String? lastDate;

    for (final op in ops) {
      final date = op.date.length >= 10 ? op.date.substring(0, 10) : op.date;
      if (date != lastDate) {
        result.add(date);
        lastDate = date;
      }
      result.add(op);
    }
    return result;
  }

  void _showFilterSheet(BuildContext context, HistoriqueController ctrl) {
    // Sheet de filtre avancé (dates)
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtres avancés',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DMSans')),
            const SizedBox(height: 20),
            // Raccourcis période
            Wrap(
              spacing: 8,
              children: ['7 jours', '30 jours', '90 jours'].map((label) {
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    final days = int.parse(label.split(' ')[0]);
                    final debut = DateTime.now()
                        .subtract(Duration(days: days))
                        .toString()
                        .substring(0, 10);
                    final fin = DateTime.now().toString().substring(0, 10);
                    Get.back();
                    ctrl.chargerHistorique();
                  },
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  labelStyle: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Barre de filtres
class _FiltreBar extends StatelessWidget {
  final HistoriqueController ctrl;
  const _FiltreBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceDark,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Obx(() => Row(
              children: [
                _FiltreChip(
                  label: 'Tous',
                  isActive: ctrl.filtreActif.value == 'TOUS',
                  onTap: () => ctrl.changerFiltre('TOUS'),
                ),
                const SizedBox(width: 8),
                _FiltreChip(
                  label: 'Entrées',
                  isActive: ctrl.filtreActif.value == 'CREDIT',
                  activeColor: AppColors.credit,
                  onTap: () => ctrl.changerFiltre('CREDIT'),
                ),
                const SizedBox(width: 8),
                _FiltreChip(
                  label: 'Sorties',
                  isActive: ctrl.filtreActif.value == 'DEBIT',
                  activeColor: AppColors.debit,
                  onTap: () => ctrl.changerFiltre('DEBIT'),
                ),
              ],
            )),
          ),
          Container(
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltreChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FiltreChip({
    required this.label,
    required this.isActive,
    this.activeColor = AppColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            fontFamily: 'DMSans',
          ),
        ),
      ),
    );
  }
}

// Header de date
class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  String _formaterDate(String date) {
    try {
      final d = DateTime.parse(date);
      final maintenant = DateTime.now();
      final hier = maintenant.subtract(const Duration(days: 1));
      if (d.day == maintenant.day && d.month == maintenant.month) {
        return "Aujourd'hui";
      }
      if (d.day == hier.day && d.month == hier.month) {
        return 'Hier';
      }
      const mois = [
        '', 'Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin',
        'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
      ];
      return '${d.day} ${mois[d.month]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Text(
            _formaterDate(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Divider(height: 1, color: AppColors.divider),
          ),
        ],
      ),
    );
  }
}

// Tile opération
class _OperationTile extends StatelessWidget {
  final OperationModel op;
  final int index;
  const _OperationTile({required this.op, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 44,
            height: 44,
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
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  op.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'DMSans',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  op.date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Montant
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${op.isCredit ? '+' : '-'} ${op.montantFormate}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: op.isCredit ? AppColors.credit : AppColors.debit,
                  fontFamily: 'DMSans',
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: op.isCredit
                      ? AppColors.credit.withOpacity(0.1)
                      : AppColors.debit.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  op.isCredit ? 'CRÉDIT' : 'DÉBIT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: op.isCredit ? AppColors.credit : AppColors.debit,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: (index * 40).ms).fadeIn().slideX(begin: 0.05);
  }
}

class _HistoriqueSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 8,
      itemBuilder: (_, i) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHigh,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _HistoriqueVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos opérations apparaîtront ici',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}