import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/operation_model.dart';
import '../../releve/controllers/releve_controller.dart';

class HistoriqueController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading       = false.obs;
  final isLoadingMore   = false.obs;
  final operations      = <OperationModel>[].obs;
  final filtreActif     = 'TOUS'.obs; // TOUS | CREDIT | DEBIT
  final numeroCompte    = ''.obs;

  // Pagination
  int _page         = 1;
  bool _hasMore     = true;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Récupérer le numéro de compte depuis les arguments
    numeroCompte.value = Get.arguments?['compte'] ?? '';
    if (numeroCompte.value.isNotEmpty) {
      chargerHistorique();
    }

    // Pagination infinie
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        chargerPlus();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // =========================================================================
  // CHARGEMENT
  // =========================================================================

  Future<void> chargerHistorique({bool reset = true}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
      operations.clear();
    }

    isLoading.value = true;

    final result = await _api.getHistorique(
      numeroCompte.value,
      page: _page,
      perPage: 20,
      sens: filtreActif.value == 'TOUS' ? null : filtreActif.value,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      final data   = result['data'] as List? ?? [];
      final newOps = data.map((o) => OperationModel.fromJson(o)).toList();
      operations.addAll(newOps);

      final pagination = result['pagination'];
      _hasMore = pagination?['has_next'] == true;
    }
  }

  Future<void> chargerPlus() async {
    if (!_hasMore || isLoadingMore.value) return;
    _page++;
    isLoadingMore.value = true;
    await chargerHistorique(reset: false);
    isLoadingMore.value = false;
  }

  Future<void> rafraichir() async {
    await chargerHistorique();
  }

  void changerFiltre(String filtre) {
    if (filtreActif.value == filtre) return;
    filtreActif.value = filtre;
    chargerHistorique();
  }
}

// Binding
class CompteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoriqueController>(() => HistoriqueController());
    Get.lazyPut<ReleveController>(() => ReleveController());
  }
}