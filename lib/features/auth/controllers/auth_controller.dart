import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading       = false.obs;
  final errorMessage    = ''.obs;
  final successMessage  = ''.obs;

  // Données en cours de flow
  final rimSaisi        = ''.obs;
  final telephoneMasque = ''.obs;
  final otpType         = 'CONNEXION'.obs; // CONNEXION | RECUPERATION_RIM

  // RIM oublié
  final rimRecupere     = ''.obs;
  final nomRecupere     = ''.obs;

  // PIN
  final pinStep         = 1.obs; // 1 = saisie, 2 = confirmation
  final pinSaisi        = ''.obs;

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearError() => errorMessage.value = '';

  Future<String> _getDeviceId() async {
    var cached = _storage.getDeviceId();
    if (cached != null) return cached;

    final info = DeviceInfoPlugin();
    String id;
    if (GetPlatform.isAndroid) {
      final android = await info.androidInfo;
      id = android.id;
    } else {
      final ios = await info.iosInfo;
      id = ios.identifierForVendor ?? 'ios-${DateTime.now().millisecondsSinceEpoch}';
    }
    await _storage.saveDeviceId(id);
    return id;
  }

  // =========================================================================
  // ÉTAPE 1 — Soumettre le RIM
  // =========================================================================

  Future<void> soumettrRim(String rim) async {
    if (rim.trim().isEmpty) {
      errorMessage.value = 'Veuillez saisir votre numéro membre (RIM).';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _api.verifierRim(rim.trim().toUpperCase());

    isLoading.value = false;

    if (result['success'] == true) {
      rimSaisi.value        = rim.trim().toUpperCase();
      telephoneMasque.value = result['telephone_masque'] ?? '';
      otpType.value         = 'CONNEXION';
      Get.toNamed(AppRoutes.VERIFY_OTP);
    } else {
      errorMessage.value = result['message'] ?? 'Une erreur est survenue.';
    }
  }

  // =========================================================================
  // ÉTAPE 2 — Vérifier OTP
  // =========================================================================

  Future<void> verifierOtp(String code) async {
    if (code.length != 6) {
      errorMessage.value = 'Veuillez saisir le code à 6 chiffres.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _api.verifierOtp(rimSaisi.value, code);
    isLoading.value = false;

    if (result['success'] == true) {
      final aPin = result['a_pin'] == true;

      // ✅ Sauvegarder le RIM dans le storage AVANT de naviguer
      await _storage.saveRim(rimSaisi.value);

      // ✅ Sauvegarder le prénom si disponible
      if (result['prenom'] != null) {
        await _storage.saveNomComplet(result['prenom']);
      }

      // ✅ Générer et sauvegarder le DeviceId si pas encore fait
      if (_storage.getDeviceId() == null || _storage.getDeviceId()!.isEmpty) {
        final deviceId = await _getDeviceId();
        await _storage.saveDeviceId(deviceId);
      }

      if (aPin) {
        Get.offAllNamed(AppRoutes.LOCK_SCREEN);
      } else {
        Get.toNamed(AppRoutes.CREATE_PIN);
      }
    } else {
      errorMessage.value = result['message'] ?? 'Code incorrect.';
    }
  }

  // =========================================================================
  // RENVOI OTP
  // =========================================================================

  Future<void> renvoyerOtp() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _api.verifierRim(rimSaisi.value);
    isLoading.value = false;

    if (result['success'] == true) {
      telephoneMasque.value = result['telephone_masque'] ?? '';
      successMessage.value = 'Nouveau code envoyé !';
      Future.delayed(3.seconds, () => successMessage.value = '');
    } else {
      errorMessage.value = result['message'] ?? 'Échec du renvoi.';
    }
  }

  // =========================================================================
  // ÉTAPE 3 — Créer PIN
  // =========================================================================

  Future<void> soumettrePin(String pin) async {
    if (pinStep.value == 1) {
      pinSaisi.value = pin;
      pinStep.value = 2;
      return;
    }

    if (pin != pinSaisi.value) {
      errorMessage.value = 'Les codes ne correspondent pas. Réessayez.';
      pinStep.value = 1;
      pinSaisi.value = '';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final deviceId   = await _getDeviceId();
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Mobile';
    try {
      if (GetPlatform.isAndroid) {
        final a = await deviceInfo.androidInfo;
        deviceName = '${a.brand} ${a.model}';
      } else if (GetPlatform.isIOS) {
        final i = await deviceInfo.iosInfo;
        deviceName = i.utsname.machine;
      }
    } catch (_) {}

    final result = await _api.creerPin(
      rim: rimSaisi.value,
      pin: pin,
      deviceId: deviceId,
      deviceName: deviceName,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      // ✅ Sauvegarder TOUT avant de naviguer
      await _storage.saveToken(result['token']);
      await _storage.saveRim(rimSaisi.value);  // ← important
      await _storage.saveNomComplet(result['nom_complet'] ?? '');
      await _storage.saveCompteDefaut(result['compte_defaut'] ?? '');
      await _storage.saveDeviceId(deviceId);   // ← important

      Get.offAllNamed(AppRoutes.BIOMETRIE);
    } else {
      errorMessage.value = result['message'] ?? 'Erreur lors de la création du PIN.';
      pinStep.value = 1;
      pinSaisi.value = '';
    }
  }

  // =========================================================================
  // RIM OUBLIÉ — Étape 1
  // =========================================================================

  Future<void> rimOublieEnvoyerOtp({
    required String numeroCompte,
    required String telephone,
  }) async {
    if (numeroCompte.trim().isEmpty || telephone.trim().isEmpty) {
      errorMessage.value = 'Veuillez remplir tous les champs.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _api.rimOublieEnvoyerOtp(
      numeroCompte: numeroCompte.trim(),
      telephone: telephone.trim(),
    );

    isLoading.value = false;

    if (result['success'] == true) {
      telephoneMasque.value = result['telephone_masque'] ?? '';
      otpType.value = 'RECUPERATION_RIM';
      Get.toNamed(AppRoutes.VERIFY_OTP,
          arguments: {'telephone': telephone.trim()});
    } else {
      errorMessage.value = result['message'] ?? 'Erreur lors de l\'envoi.';
    }
  }

  // =========================================================================
  // BIOMÉTRIE
  // =========================================================================

  Future<void> activerBiometrie() async {
    isLoading.value = true;
    final result = await _api.toggleBiometrie(true);
    isLoading.value = false;

    if (result['success'] == true) {
      await _storage.saveBiometrie(true);
    }
    Get.offAllNamed(AppRoutes.HOME);
  }

  void passerBiometrie() {
    Get.offAllNamed(AppRoutes.HOME);
  }

  // =========================================================================
  // HELPERS PRIVÉS
  // =========================================================================

  void _showRimRecupere() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Votre numéro membre',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Votre RIM est :',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              rimRecupere.value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7B1514),
                  letterSpacing: 4),
            ),
            const SizedBox(height: 8),
            Text('Bonjour ${nomRecupere.value}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              rimSaisi.value = rimRecupere.value;
            },
            child: const Text('SE CONNECTER AVEC CE RIM'),
          ),
        ],
      ),
    );
  }
}