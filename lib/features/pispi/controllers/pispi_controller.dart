import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

// ── Modèle Alias PI-SPI ───────────────────────────────────────────────────────
class PispiAliasModel {
  final String type;   // SHID ou MBNO
  final String cle;
  final String numeroCompte;
  final String statut;
  final String pays;

  PispiAliasModel({
    required this.type,
    required this.cle,
    required this.numeroCompte,
    required this.statut,
    required this.pays,
  });

  factory PispiAliasModel.fromJson(Map<String, dynamic> json) {
    return PispiAliasModel(
      type: json['type'] ?? '',
      cle: json['cle'] ?? '',
      numeroCompte: json['numero_compte'] ?? '',
      statut: json['statut'] ?? '',
      pays: json['pays'] ?? 'BJ',
    );
  }

  bool get estActif => statut == 'actif';
}

// ── Modèle Transaction PI-SPI ─────────────────────────────────────────────────
class PispiTransactionModel {
  final String endToEndId;
  final double montant;
  final String statut;
  final String? clientNom;
  final String? clientPays;
  final String compteSource;
  final String createdAt;

  PispiTransactionModel({
    required this.endToEndId,
    required this.montant,
    required this.statut,
    this.clientNom,
    this.clientPays,
    required this.compteSource,
    required this.createdAt,
  });

  factory PispiTransactionModel.fromJson(Map<String, dynamic> json) {
    return PispiTransactionModel(
      endToEndId: json['end_to_end_id'] ?? '',
      montant: (json['montant'] as num?)?.toDouble() ?? 0,
      statut: json['statut'] ?? '',
      clientNom: json['client_nom'],
      clientPays: json['client_pays'],
      compteSource: json['compte_source'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get estIrrevocable => statut == 'irrevocable';
  bool get estRejete => statut == 'rejete';
}

// ── Controller Principal ──────────────────────────────────────────────────────
class PispiController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  // ── État général ─────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final pispiDisponible = false.obs;
  final pispiEnv = 'sandbox'.obs;
  final pispiMessage = ''.obs;

  // ── Alias ─────────────────────────────────────────────────────────────────
  final mesAlias = <PispiAliasModel>[].obs;
  final isLoadingAlias = false.obs;

  // ── Sélection type alias (UI) ─────────────────────────────────────────────
  final aliasSelectionne = Rxn<String>(); // 'SHID' ou 'MBNO'

  // ── Transfert en cours ────────────────────────────────────────────────────
  final transfertEndToEndId = ''.obs;
  final transfertBeneficiaire = ''.obs;
  final transfertMontant = 0.0.obs;
  final transfertStatut = ''.obs;
  final isPolling = false.obs;

  // ── Transactions ──────────────────────────────────────────────────────────
  final transactions = <PispiTransactionModel>[].obs;
  final isLoadingTransactions = false.obs;

  // ── Notifications ─────────────────────────────────────────────────────────
  final notificationsNonLues = 0.obs;

  @override
  void onInit() {
    super.onInit();
    verifierStatut();
  }

  // =========================================================================
  // STATUT PI-SPI
  // =========================================================================

  Future<void> verifierStatut() async {
    isLoading.value = true;

    final result = await _api.getPispiStatut();

    if (result['success'] == true) {
      pispiDisponible.value = result['disponible'] == true;
      pispiEnv.value = result['env'] ?? 'sandbox';
      pispiMessage.value = result['message'] ?? '';

      // Si disponible, charger les alias
      if (pispiDisponible.value) {
        await chargerAlias();
        await chargerNotificationsNonLues();
      }
    }

    isLoading.value = false;
  }

  // =========================================================================
  // ALIAS
  // =========================================================================

  Future<void> chargerAlias() async {
    isLoadingAlias.value = true;

    final result = await _api.getMesAlias();

    if (result['success'] == true) {
      final data = result['data'] as List? ?? [];
      mesAlias.value = data
          .map((a) => PispiAliasModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    isLoadingAlias.value = false;
  }

  Future<void> creerAlias({
    required String numeroCompte,
    required String type,
    String? telephone,
  }) async {
    isLoading.value = true;

    final result = await _api.creerAliaspispi(
      numeroCompte: numeroCompte,
      type: type,
      telephone: telephone,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      final confirmationRequise = result['confirmation_requise'] == true;

      if (confirmationRequise) {
        // MBNO : afficher dialog pour saisir l'OTP PI-SPI
        final cle = result['data']?['cle'];
        if (cle != null) {
          _afficherDialogConfirmationOtp(cle);
        }
      } else {
        // SHID : créé directement
        Get.snackbar(
          'Alias créé',
          'Votre identifiant PI-SPI est actif.',
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await chargerAlias();
      }
    } else {
      _afficherErreur(result['message'] ?? 'Erreur lors de la création');
    }
  }

  Future<void> confirmerAlias(String cle, String otp) async {
    isLoading.value = true;

    final result = await _api.confirmerAliasPispi(cle: cle, otp: otp);

    isLoading.value = false;

    if (result['success'] == true) {
      Get.back(); // Fermer dialog
      Get.snackbar(
        'Alias confirmé',
        'Votre alias MBNO est maintenant actif.',
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      await chargerAlias();
    } else {
      _afficherErreur(result['message'] ?? 'Code incorrect');
    }
  }

  Future<void> supprimerAlias(String cle) async {
    final confirme = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer l\'alias',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Vous ne pourrez plus recevoir de paiements avec cet identifiant.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false),
              child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SUPPRIMER',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    isLoading.value = true;
    final result = await _api.supprimerAliasPispi(cle);
    isLoading.value = false;

    if (result['success'] == true) {
      mesAlias.removeWhere((a) => a.cle == cle);
      Get.snackbar('Alias supprimé', '',
          backgroundColor: Colors.orange, colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } else {
      _afficherErreur(result['message'] ?? 'Erreur suppression');
    }
  }

  // =========================================================================
  // TRANSFERT PI-SPI — Pipeline 3 étapes
  // =========================================================================

  /// Étape 1 : Initier
  Future<bool> initierTransfert({
    required String compteSource,
    required double montant,
    required double latitude,
    required double longitude,
    String? alias,
    String? motif,
  }) async {
    isLoading.value = true;

    final result = await _api.initierTransfertPispi(
      compteSource: compteSource,
      montant: montant,
      latitude: latitude,
      longitude: longitude,
      alias: alias,
      motif: motif,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? {};
      transfertEndToEndId.value = data['end_to_end_id'] ?? '';
      transfertBeneficiaire.value = data['beneficiaire'] ?? '';
      transfertMontant.value = (data['montant'] as num?)?.toDouble() ?? montant;
      transfertStatut.value = data['statut'] ?? 'initie';
      return true;
    } else {
      _afficherErreur(result['message'] ?? 'Erreur lors de l\'initiation');
      return false;
    }
  }

  /// Étape 2 : Confirmer
  Future<bool> confirmerTransfert({
    required String methode, // 'pin' ou 'biometry'
  }) async {
    if (transfertEndToEndId.value.isEmpty) return false;

    isLoading.value = true;

    final result = await _api.confirmerTransfertPispi(
      endToEndId: transfertEndToEndId.value,
      methodeConfirmation: methode,
      montant: transfertMontant.value,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      transfertStatut.value = result['data']?['statut'] ?? 'en_cours';
      return true;
    } else {
      _afficherErreur(result['message'] ?? 'Erreur de confirmation');
      return false;
    }
  }

  /// Étape 3 : Polling statut final (appel toutes les 3 secondes)
  Future<void> pollStatutTransfert({
    required Function(String statut) onResultat,
    int maxTentatives = 10,
  }) async {
    if (transfertEndToEndId.value.isEmpty) return;

    isPolling.value = true;
    int tentatives = 0;

    while (tentatives < maxTentatives && isPolling.value) {
      await Future.delayed(const Duration(seconds: 3));

      final result =
      await _api.getStatutTransfertPispi(transfertEndToEndId.value);

      if (result['success'] == true) {
        final statut = result['data']?['statut'] ?? '';
        transfertStatut.value = statut;

        if (statut == 'irrevocable' || statut == 'rejete') {
          isPolling.value = false;
          onResultat(statut);
          return;
        }
      }

      tentatives++;
    }

    // Timeout
    isPolling.value = false;
    onResultat('timeout');
  }

  void annulerPolling() => isPolling.value = false;

  // =========================================================================
  // HISTORIQUE TRANSACTIONS
  // =========================================================================

  Future<void> chargerTransactions() async {
    isLoadingTransactions.value = true;

    final result = await _api.getHistoriquePispi();

    if (result['success'] == true) {
      final data = result['data'] as List? ?? [];
      transactions.value = data
          .map((t) =>
          PispiTransactionModel.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    isLoadingTransactions.value = false;
  }

  // =========================================================================
  // NOTIFICATIONS
  // =========================================================================

  Future<void> chargerNotificationsNonLues() async {
    final compteDefaut = _storage.getCompteDefaut();
    if (compteDefaut == null) return;

    final result = await _api.getNonLuesPispi(compteDefaut);

    if (result['success'] == true) {
      notificationsNonLues.value = result['total'] as int? ?? 0;
    }
  }

  // =========================================================================
  // HELPERS PRIVÉS
  // =========================================================================

  void _afficherErreur(String message) {
    Get.snackbar(
      'Erreur',
      message,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void _afficherDialogConfirmationOtp(String cle) {
    final otpController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer votre alias',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Un code a été envoyé par PI-SPI sur votre téléphone. Saisissez-le pour activer votre alias MBNO.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('ANNULER'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value
                ? null
                : () => confirmerAlias(cle, otpController.text),
            child: isLoading.value
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('CONFIRMER'),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }
}