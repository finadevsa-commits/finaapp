import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/pispi_controller.dart';

class PispiScreen extends StatelessWidget {
  const PispiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecter le controller (PispiBinding le fournit)
    final ctrl = Get.find<PispiController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Text(
          'PI-SPI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'DMSans',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.accent, size: 28),
          onPressed: Get.back,
        ),
        actions: [
          // Badge notifications non lues
          Obx(() {
            final count = ctrl.notificationsNonLues.value;
            return count > 0
                ? Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {}, // TODO: ouvrir notifications
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            )
                : const SizedBox(width: 48);
          }),
        ],
      ),
      body: Obx(() {
        // Chargement initial
        if (ctrl.isLoading.value && ctrl.pispiMessage.value.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Vérification du service PI-SPI...',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        // PI-SPI non disponible → écran "coming soon"
        if (!ctrl.pispiDisponible.value) {
          return _ComingSoonView(ctrl: ctrl);
        }

        // PI-SPI disponible → flow complet
        return _PispiActiveView(ctrl: ctrl);
      }),
    );
  }
}

// =============================================================================
// VUE "COMING SOON" — PI-SPI non configuré
// =============================================================================
class _ComingSoonView extends StatelessWidget {
  final PispiController ctrl;
  const _ComingSoonView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Illustration
                Center(
                  child: Container(
                    width: size.width * 0.72,
                    height: size.width * 0.72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF0F0F0),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [_PispiIllustration()],
                    ),
                  )
                      .animate()
                      .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 600.ms,
                      curve: Curves.elasticOut)
                      .fadeIn(),
                ),

                const SizedBox(height: 28),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Plateforme de Paiement\nInstantané',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    ctrl.pispiMessage.value.isNotEmpty
                        ? ctrl.pispiMessage.value
                        : 'Profitez de paiements rapides et sans frais avec la PI-SPI, partout dans la zone UEMOA.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.65,
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 32),

                // Chips pays cibles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Text(
                        'Pays couverts par PI-SPI',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          'Bénin 🇧🇯', 'Togo 🇹🇬', 'Côte d\'Ivoire 🇨🇮',
                          'Sénégal 🇸🇳', 'Mali 🇲🇱', 'Burkina Faso 🇧🇫',
                          'Niger 🇳🇪', 'Guinée-Bissau 🇬🇼',
                        ].map((pays) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Text(
                            pays,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 32),

                // Badge environnement (sandbox/production)
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: ctrl.pispiEnv.value == 'production'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ctrl.pispiEnv.value == 'production'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ctrl.pispiEnv.value == 'production'
                            ? Icons.check_circle_outline
                            : Icons.settings_outlined,
                        size: 14,
                        color: ctrl.pispiEnv.value == 'production'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ctrl.pispiEnv.value == 'production'
                            ? 'Environnement production'
                            : 'Configuration en cours — ${ctrl.pispiEnv.value}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ctrl.pispiEnv.value == 'production'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                )).animate(delay: 450.ms).fadeIn(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Bas de page
        Container(
          padding: EdgeInsets.fromLTRB(
            24, 16, 24,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton Rafraîchir
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton.icon(
                  onPressed:
                  ctrl.isLoading.value ? null : ctrl.verifierStatut,
                  icon: ctrl.isLoading.value
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    ctrl.isLoading.value
                        ? 'Vérification...'
                        : 'VÉRIFIER LA DISPONIBILITÉ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontFamily: 'DMSans',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                )),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 12),

              Text(
                'Vous serez notifié dès l\'activation du service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'DMSans',
                ),
              ).animate(delay: 550.ms).fadeIn(),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// VUE ACTIVE — PI-SPI configuré et disponible
// =============================================================================
class _PispiActiveView extends StatelessWidget {
  final PispiController ctrl;
  const _PispiActiveView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge "actif"
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 6),
                Text('Service PI-SPI actif',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 24),

          // Section Mes Alias
          _SectionTitre(titre: 'Mes identifiants PI-SPI'),
          const SizedBox(height: 12),

          Obx(() {
            if (ctrl.isLoadingAlias.value) {
              return const _AliasSkeleton();
            }

            if (ctrl.mesAlias.isEmpty) {
              return _AliasVide(ctrl: ctrl);
            }

            return Column(
              children: ctrl.mesAlias
                  .map((alias) => _AliasCard(
                  alias: alias,
                  onSupprimer: () => ctrl.supprimerAlias(alias.cle)))
                  .toList(),
            );
          }),

          const SizedBox(height: 8),

          // Bouton créer alias
          Obx(() => ctrl.mesAlias.length < 2
              ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () => _afficherDialogCreerAlias(context, ctrl),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter un alias'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
              : const SizedBox()),

          const SizedBox(height: 32),

          // Section Transfert
          _SectionTitre(titre: 'Transfert international'),
          const SizedBox(height: 12),

          // Card transfert PI-SPI
          _TransfertCard(ctrl: ctrl),

          const SizedBox(height: 32),

          // Historique transactions PI-SPI
          _SectionTitre(titre: 'Transactions PI-SPI récentes'),
          const SizedBox(height: 12),

          Obx(() {
            if (ctrl.isLoadingTransactions.value) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary));
            }
            if (ctrl.transactions.isEmpty) {
              return Center(
                child: Text('Aucune transaction PI-SPI',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return Column(
              children: ctrl.transactions
                  .take(5)
                  .map((t) => _TransactionPispiTile(tx: t))
                  .toList(),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _afficherDialogCreerAlias(
      BuildContext context, PispiController ctrl) {
    final compteCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    String typeSelectionne = 'SHID';

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Créer un alias PI-SPI',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type alias
              Row(
                children: ['SHID', 'MBNO'].map((type) {
                  final isSelected = typeSelectionne == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => typeSelectionne = type),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: type == 'SHID' ? 6 : 0,
                            left: type == 'MBNO' ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          type,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Numéro de compte
              TextField(
                controller: compteCtrl,
                decoration: InputDecoration(
                  labelText: 'Numéro de compte',
                  hintText: 'Ex: 275-000375',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon:
                  const Icon(Icons.account_balance_outlined),
                ),
              ),

              // Téléphone (MBNO seulement)
              if (typeSelectionne == 'MBNO') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: 'Ex: +22997000000',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
              ],

              const SizedBox(height: 8),
              Text(
                typeSelectionne == 'SHID'
                    ? 'Un identifiant unique sera généré automatiquement pour votre compte.'
                    : 'Votre numéro de téléphone devient votre identifiant PI-SPI. Un SMS de confirmation sera envoyé.',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: Get.back, child: const Text('ANNULER')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                ctrl.creerAlias(
                  numeroCompte: compteCtrl.text.trim(),
                  type: typeSelectionne,
                  telephone: typeSelectionne == 'MBNO'
                      ? telCtrl.text.trim()
                      : null,
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('CRÉER',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGETS RÉUTILISABLES
// =============================================================================

class _SectionTitre extends StatelessWidget {
  final String titre;
  const _SectionTitre({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Text(
      titre,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'DMSans',
      ),
    );
  }
}

class _AliasCard extends StatelessWidget {
  final PispiAliasModel alias;
  final VoidCallback onSupprimer;

  const _AliasCard({required this.alias, required this.onSupprimer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              alias.type == 'SHID'
                  ? Icons.badge_outlined
                  : Icons.phone_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alias.type,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: alias.estActif
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alias.estActif ? 'Actif' : 'En attente',
                        style: TextStyle(
                            color:
                            alias.estActif ? Colors.green : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alias.type == 'SHID'
                      ? alias.cle.length > 20
                      ? '${alias.cle.substring(0, 20)}...'
                      : alias.cle
                      : alias.cle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'DMSans',
                  ),
                ),
                Text(
                  alias.numeroCompte,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.red, size: 20),
            onPressed: onSupprimer,
          ),
        ],
      ),
    );
  }
}

class _AliasVide extends StatelessWidget {
  final PispiController ctrl;
  const _AliasVide({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
            style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.badge_outlined,
              color: AppColors.primary, size: 40),
          const SizedBox(height: 8),
          const Text(
            'Pas encore d\'identifiant PI-SPI',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Créez un alias pour recevoir des paiements PI-SPI.',
            textAlign: TextAlign.center,
            style:
            TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AliasSkeleton extends StatelessWidget {
  const _AliasSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _TransfertCard extends StatelessWidget {
  final PispiController ctrl;
  const _TransfertCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceDark, Color(0xFF1A3A5C)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceDark.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Envoyer de l\'argent',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'DMSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Transférez vers n\'importe quelle banque de la zone UEMOA en quelques secondes.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: naviguer vers l'écran de transfert PI-SPI
                    // Get.toNamed(AppRoutes.PISPI_TRANSFERT)
                    Get.snackbar(
                      'Transfert PI-SPI',
                      'Sélectionnez un compte source et un bénéficiaire.',
                      snackPosition: SnackPosition.TOP,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'ENVOYER',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: ctrl.chargerTransactions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('HISTORIQUE'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionPispiTile extends StatelessWidget {
  final PispiTransactionModel tx;
  const _TransactionPispiTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tx.estIrrevocable
                  ? Colors.green.withOpacity(0.1)
                  : tx.estRejete
                  ? Colors.red.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.estIrrevocable
                  ? Icons.check_circle_outline
                  : tx.estRejete
                  ? Icons.cancel_outlined
                  : Icons.hourglass_top_rounded,
              color: tx.estIrrevocable
                  ? Colors.green
                  : tx.estRejete
                  ? Colors.red
                  : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.clientNom ?? 'Bénéficiaire inconnu',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  tx.statut.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: tx.estIrrevocable
                        ? Colors.green
                        : tx.estRejete
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ${tx.montant.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.debit,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ILLUSTRATION (inchangée depuis pispi_screen.dart original)
// =============================================================================
class _PispiIllustration extends StatelessWidget {
  const _PispiIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 190,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(-6, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 130,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.accent,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4956A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 36,
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}