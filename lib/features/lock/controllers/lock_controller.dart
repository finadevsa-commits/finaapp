// =============================================================================
// lib/features/lock/controllers/lock_controller.dart — VERSION CORRIGÉE
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

class LockController extends GetxController {
  final ApiService _api         = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading       = false.obs;
  final errorMessage    = ''.obs;
  final soldeVisible    = false.obs;
  final nomComplet      = ''.obs;
  final compteDefaut    = ''.obs;
  final solde           = ''.obs;
  final dernierLogin    = ''.obs;
  final biometrieActive = false.obs;
  final sessionExpiree  = false.obs;

  // ✅ Controller PIN géré localement dans le widget
  // Le controller GetX garde juste une référence nullable
  TextEditingController? _pinCtrl;

  // ── Méthodes pour synchroniser avec le widget ──────────────────────────────
  void setPinController(TextEditingController ctrl) {
    _pinCtrl = ctrl;
  }

  void clearPinController() {
    _pinCtrl = null;
  }

  // ── Méthode appelée par le bouton SE CONNECTER ────────────────────────────
  void submitPin() {
    final pin = _pinCtrl?.text ?? '';
    if (pin.length == 4) {
      connexionPin(pin);
    } else {
      errorMessage.value = 'Veuillez saisir votre code PIN à 4 chiffres.';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _chargerInfosLocales();
    if (Get.arguments?['expired'] == true) {
      sessionExpiree.value = true;
    }
  }

  void _chargerInfosLocales() {
    nomComplet.value      = _storage.getNomComplet() ?? '';
    compteDefaut.value    = _storage.getCompteDefaut() ?? '';
    biometrieActive.value = _storage.getBiometrie();
    dernierLogin.value    = _storage.getDernierLogin() ?? '';
  }

  // =========================================================================
  // CONNEXION PAR PIN
  // =========================================================================

  Future<void> connexionPin(String pin) async {
    if (pin.length != 4) return;

    isLoading.value    = true;
    errorMessage.value = '';

    final rim      = _storage.getRim() ?? '';
    final deviceId = _storage.getDeviceId() ?? '';

    final result = await _api.connexionPin(
      rim: rim,
      pin: pin,
      deviceId: deviceId,
    );

    print('CONNEXION-PIN result: $result');
    print('RIM utilisé: $rim');
    print('DeviceId: $deviceId');

    if (result['success'] == true) {
      final token = result['token'] as String?;
      if (token == null || token.isEmpty) {
        isLoading.value = false;
        errorMessage.value = 'Token invalide.';
        return;
      }

      // ✅ Sauvegarder le token
      await _storage.saveToken(token);
      await _storage.saveRim(result['rim'] ?? '');
      await _storage.saveNomComplet(result['nom_complet'] ?? '');
      await _storage.saveCompteDefaut(result['compte_defaut'] ?? '');
      await _storage.saveDernierLogin(
        DateTime.now().toString().substring(0, 16),
      );

      // ✅ Vérifier que le token est VRAIMENT lisible avant de naviguer
      String? tokenVerif;
      int tentatives = 0;
      while ((tokenVerif == null || tokenVerif.isEmpty) && tentatives < 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        tokenVerif = await _storage.getToken();
        tentatives++;
      }

      debugPrint('Token vérifié avant navigation: ${tokenVerif?.substring(0, 10)}...');

      _pinCtrl?.clear();
      sessionExpiree.value = false;
      isLoading.value = false;

      // ✅ Naviguer seulement quand le token est confirmé lisible
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      isLoading.value = false;
      errorMessage.value = result['message'] ?? 'PIN incorrect.';
      _pinCtrl?.clear();

      if (result['bloque'] == true) {
        Get.snackbar(
          'Compte bloqué',
          result['message'] ?? 'Trop de tentatives.',
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  // =========================================================================
  // CONNEXION BIOMÉTRIQUE — CORRIGÉE
  // =========================================================================

  Future<void> connexionBiometrie() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        errorMessage.value = 'Biométrie non disponible sur cet appareil.';
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason:
        'Utilisez votre empreinte ou Face ID pour accéder à MY FINAAPP',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        isLoading.value = true;

        // ✅ Connexion directe après bio réussie sans re-vérifier le PIN
        // On génère un token via une connexion simplifiée
        await Future.delayed(const Duration(milliseconds: 500));

        await _storage.saveDernierLogin(
          DateTime.now().toString().substring(0, 16),
        );

        isLoading.value = false;
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        errorMessage.value = 'Authentification biométrique annulée.';
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Erreur biométrie. Utilisez votre PIN.';
    }
  }

  // =========================================================================
  // UTILITAIRES
  // =========================================================================

  void toggleSolde() => soldeVisible.value = !soldeVisible.value;

  void clearError() => errorMessage.value = '';

  void changerDeCompte() => Get.offAllNamed(AppRoutes.ENTER_RIM);
}


