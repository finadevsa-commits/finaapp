// =============================================================================
// lib/core/services/storage_service.dart
// =============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class StorageService extends GetxService {
  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Sécurisé (PIN, token) ─────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyToken, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: AppConstants.keyToken);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.keyToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Préférences (non sensibles) ───────────────────────────────────────────

  Future<void> saveRim(String rim) async {
    await _prefs.setString(AppConstants.keyRim, rim);
  }

  String? getRim() => _prefs.getString(AppConstants.keyRim);

  Future<void> saveNomComplet(String nom) async {
    await _prefs.setString(AppConstants.keyNomComplet, nom);
  }

  String? getNomComplet() => _prefs.getString(AppConstants.keyNomComplet);

  Future<void> saveCompteDefaut(String numeroCompte) async {
    await _prefs.setString(AppConstants.keyCompteDefaut, numeroCompte);
  }

  String? getCompteDefaut() => _prefs.getString(AppConstants.keyCompteDefaut);

  Future<void> saveBiometrie(bool active) async {
    await _prefs.setBool(AppConstants.keyBiometrie, active);
  }

  bool getBiometrie() => _prefs.getBool(AppConstants.keyBiometrie) ?? false;

  Future<void> setOnboardingDone() async {
    await _prefs.setBool(AppConstants.keyOnboardingDone, true);
  }

  bool isOnboardingDone() =>
      _prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

  Future<void> saveDernierLogin(String dateTime) async {
    await _prefs.setString(AppConstants.keyDernierLogin, dateTime);
  }

  String? getDernierLogin() => _prefs.getString(AppConstants.keyDernierLogin);

  // ── Nettoyage session ─────────────────────────────────────────────────────

  Future<void> clearSession() async {
    await deleteToken();
    // Garder rim + onboarding pour éviter de re-passer l'onboarding
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }

  // ── Device ID ─────────────────────────────────────────────────────────────

  Future<void> saveDeviceId(String deviceId) async {
    await _prefs.setString(AppConstants.keyDeviceId, deviceId);
  }

  String? getDeviceId() => _prefs.getString(AppConstants.keyDeviceId);
}