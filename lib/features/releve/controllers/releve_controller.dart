import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/operation_model.dart';
import '../../../core/theme/app_colors.dart';

class ReleveController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading      = false.obs;
  final numeroCompte   = ''.obs;
  final dateDebut      = ''.obs;
  final dateFin        = ''.obs;
  final periodeActive  = ''.obs; // '7', '30', '90' ou ''

  // Résultats
  final soldeDebut    = 0.0.obs;
  final soldeFin      = 0.0.obs;
  final totalCredit   = 0.0.obs;
  final totalDebit    = 0.0.obs;
  final nbOperations  = 0.obs;
  final operations    = <OperationModel>[].obs;
  final releveCharge  = false.obs;

  @override
  void onInit() {
    super.onInit();
    numeroCompte.value = Get.arguments?['compte'] ?? '';
    // Pré-remplir avec ce mois
    final now = DateTime.now();
    dateDebut.value = '${now.year}-${now.month.toString().padLeft(2,'0')}-01';
    dateFin.value   = now.toString().substring(0, 10);
  }

  void selectionnerPeriode(int jours) {
    periodeActive.value = jours.toString();
    final fin   = DateTime.now();
    final debut = fin.subtract(Duration(days: jours));
    dateDebut.value = debut.toString().substring(0, 10);
    dateFin.value   = fin.toString().substring(0, 10);
  }

  Future<void> chargerReleve() async {
    if (numeroCompte.value.isEmpty || dateDebut.value.isEmpty || dateFin.value.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez sélectionner une période.',
          backgroundColor: AppColors.error, colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    isLoading.value = true;
    releveCharge.value = false;

    final result = await _api.getReleve(
      numeroCompte.value,
      dateDebut: dateDebut.value,
      dateFin: dateFin.value,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      final data = result['data'];
      soldeDebut.value   = (data['solde_debut'] ?? 0).toDouble();
      soldeFin.value     = (data['solde_fin'] ?? 0).toDouble();
      totalCredit.value  = (data['total_credit'] ?? 0).toDouble();
      totalDebit.value   = (data['total_debit'] ?? 0).toDouble();
      nbOperations.value = data['nb_operations'] ?? 0;

      final ops = data['operations'] as List? ?? [];
      operations.value = ops.map((o) => OperationModel.fromJson(o)).toList();
      releveCharge.value = true;
    } else {
      Get.snackbar('Erreur', result['message'] ?? 'Erreur lors du chargement.',
          backgroundColor: AppColors.error, colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  String formaterMontant(double montant) {
    return '${montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }
}