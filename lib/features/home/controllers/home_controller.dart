import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/compte_model.dart';
import '../../../core/models/operation_model.dart';

class HomeController extends GetxController {
  final ApiService _api         = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoadingProfil      = true.obs;
  final isLoadingHistorique  = true.obs;
  final soldeVisible         = false.obs;
  final currentCompteIndex   = 0.obs;

  // Données
  final nomComplet     = ''.obs;
  final comptes        = <CompteModel>[].obs;
  final derniersOps    = <OperationModel>[].obs;

  // Bottom nav
  final currentNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    nomComplet.value = _storage.getNomComplet() ?? '';
    Future.delayed(const Duration(milliseconds: 900), () {
      chargerDonnees();
    });
  }

  // =========================================================================
  // CHARGEMENT DONNÉES
  // =========================================================================

  Future<void> chargerDonnees() async {
    await Future.wait([
      _chargerProfil(),
    ]);
  }

  Future<void> _chargerProfil() async {
    isLoadingProfil.value = true;

    final result = await _api.getProfil();

    if (result['success'] == true) {
      final data = result['data'];
      nomComplet.value = data['nom_complet'] ?? '';

      // Comptes
      final comptesData = data['comptes'] as List? ?? [];
      comptes.value = comptesData
          .map((c) => CompteModel.fromJson(c))
          .toList();

      // Charger historique du compte par défaut
      if (comptes.isNotEmpty) {
        final compteDefaut = _storage.getCompteDefaut();
        final idx = comptes.indexWhere(
                (c) => c.numeroCompte == compteDefaut);
        currentCompteIndex.value = idx >= 0 ? idx : 0;
        await _chargerHistorique(comptes[currentCompteIndex.value].numeroCompte);
      }
    }

    isLoadingProfil.value = false;
  }

  Future<void> _chargerHistorique(String numeroCompte) async {
    isLoadingHistorique.value = true;

    final result = await _api.getHistorique(numeroCompte, perPage: 5);

    if (result['success'] == true) {
      final data = result['data'] as List? ?? [];
      derniersOps.value = data
          .map((o) => OperationModel.fromJson(o))
          .toList();
    }

    isLoadingHistorique.value = false;
  }

  // =========================================================================
  // ACTIONS
  // =========================================================================

  void toggleSolde() => soldeVisible.value = !soldeVisible.value;

  void changerCompte(int index) {
    currentCompteIndex.value = index;
    _chargerHistorique(comptes[index].numeroCompte);
    _storage.saveCompteDefaut(comptes[index].numeroCompte);
  }

  CompteModel? get compteActuel =>
      comptes.isNotEmpty ? comptes[currentCompteIndex.value] : null;

  Future<void> rafraichir() async {
    await chargerDonnees();
  }

  void naviguerVers(String route, {dynamic arguments}) {
    Get.toNamed(route, arguments: arguments);
  }

  void onNavTap(int index) {
    currentNavIndex.value = index;
    switch (index) {
      case 0: break; // Déjà sur home
      case 1: Get.toNamed(AppRoutes.TRANSFERT); break;
      case 3: Get.toNamed(AppRoutes.NOTIFICATIONS); break;
      case 4: Get.toNamed(AppRoutes.PROFIL); break;
    }
  }

  void deconnexion() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _api.deconnexion();
              await _storage.clearSession();
              Get.offAllNamed(AppRoutes.LOCK_SCREEN);
            },
            child: const Text('DÉCONNECTER'),
          ),
        ],
      ),
    );
  }
}
