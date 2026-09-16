import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/operation_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';

class DepotMomoController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  final isLoading      = false.obs;
  final errorMessage   = ''.obs;
  final operateurSelec = 'MTN'.obs;
  final step           = 1.obs; // 1=formulaire, 2=succès
  final reference      = ''.obs;
  final instructions   = ''.obs;

  final montantCtrl   = TextEditingController();
  final telMomoCtrl   = TextEditingController();
  final compteDestCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    compteDestCtrl.text = Get.arguments?['compte'] ?? _storage.getCompteDefaut() ?? '';
  }

  @override
  void onClose() {
    montantCtrl.dispose();
    telMomoCtrl.dispose();
    compteDestCtrl.dispose();
    super.onClose();
  }

  Future<void> soumettreDepot() async {
    final montant = double.tryParse(montantCtrl.text.replaceAll(' ', ''));
    if (montant == null || montant < 500) {
      errorMessage.value = 'Montant minimum : 500 FCFA';
      return;
    }
    if (telMomoCtrl.text.length < 8) {
      errorMessage.value = 'Numéro MoMo invalide.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _api.demandeDepotMomo(
      compteDestination: compteDestCtrl.text,
      montant: montant,
      telephoneMomo: telMomoCtrl.text,
      operateur: operateurSelec.value,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      reference.value    = result['data']['reference'] ?? '';
      instructions.value = result['data']['instructions'] ?? '';
      step.value = 2;
    } else {
      errorMessage.value = result['message'] ?? 'Erreur lors de la demande.';
    }
  }
}