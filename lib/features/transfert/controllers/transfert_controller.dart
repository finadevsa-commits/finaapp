import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/operation_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';

class TransfertController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  final isLoading        = false.obs;
  final isSearching      = false.obs;
  final errorMessage     = ''.obs;
  final step             = 1.obs; // 1=recherche, 2=montant+otp, 3=succès

  // Données bénéficiaire
  final beneficiaireRim      = ''.obs;
  final beneficiaireNom      = ''.obs;
  final beneficiaireInitiales = ''.obs;
  final beneficiaireComptes  = <Map<String, dynamic>>[].obs;
  final compteDestSelected   = ''.obs;

  // Montant + motif
  final montantCtrl = TextEditingController();
  final motifCtrl   = TextEditingController();
  final otpCtrl     = TextEditingController();

  // Compte source
  final compteSource = ''.obs;
  final otpEnvoye    = false.obs;
  final telephoneMasque = ''.obs;

  // Résultat
  final reference = ''.obs;
  final montantTransfere = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    compteSource.value = _storage.getCompteDefaut() ?? '';
  }

  @override
  void onClose() {
    montantCtrl.dispose();
    motifCtrl.dispose();
    otpCtrl.dispose();
    super.onClose();
  }

  Future<void> rechercherBeneficiaire(String recherche) async {
    if (recherche.trim().isEmpty) return;

    isSearching.value = true;
    errorMessage.value = '';

    final result = await _api.rechercherBeneficiaire(recherche.trim());
    isSearching.value = false;

    if (result['success'] == true) {
      final data = result['data'];
      beneficiaireRim.value       = data['rim'] ?? '';
      beneficiaireNom.value       = data['nom_complet'] ?? '';
      beneficiaireInitiales.value = data['initiales'] ?? '??';
      final comptes = data['comptes'] as List? ?? [];
      beneficiaireComptes.value =
          comptes.map((c) => c as Map<String, dynamic>).toList();
      if (comptes.isNotEmpty) {
        compteDestSelected.value = comptes.first['numero_compte'] ?? '';
      }
    } else {
      errorMessage.value = result['message'] ?? 'Bénéficiaire introuvable.';
    }
  }

  Future<void> demanderOtp() async {
    final montant = double.tryParse(montantCtrl.text.replaceAll(' ', ''));
    if (montant == null || montant < 100) {
      errorMessage.value = 'Montant minimum : 100 FCFA';
      return;
    }
    if (compteDestSelected.value.isEmpty) {
      errorMessage.value = 'Sélectionnez un compte destinataire.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _api.demanderOtpTransfert(
      compteSource: compteSource.value,
      compteDestination: compteDestSelected.value,
      montant: montant,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      telephoneMasque.value = result['telephone_masque'] ?? '';
      otpEnvoye.value = true;
      step.value = 2;
    } else {
      errorMessage.value = result['message'] ?? 'Erreur lors de l\'envoi OTP.';
    }
  }

  Future<void> executerTransfert() async {
    if (otpCtrl.text.length != 6) {
      errorMessage.value = 'Saisissez le code à 6 chiffres.';
      return;
    }

    final montant = double.tryParse(montantCtrl.text.replaceAll(' ', ''));
    if (montant == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _api.transfertCompteACompte(
      compteSource: compteSource.value,
      compteDestination: compteDestSelected.value,
      montant: montant,
      otp: otpCtrl.text,
      motif: motifCtrl.text.isEmpty ? null : motifCtrl.text,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      reference.value         = result['data']['reference'] ?? '';
      montantTransfere.value  = (result['data']['montant'] ?? 0).toDouble();
      step.value = 3;
    } else {
      errorMessage.value = result['message'] ?? 'Transfert échoué.';
    }
  }

  void reset() {
    step.value = 1;
    beneficiaireRim.value = '';
    beneficiaireNom.value = '';
    beneficiaireComptes.clear();
    montantCtrl.clear();
    motifCtrl.clear();
    otpCtrl.clear();
    otpEnvoye.value = false;
    errorMessage.value = '';
  }
}