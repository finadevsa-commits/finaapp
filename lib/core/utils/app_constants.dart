class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────────────────────
  static const String baseUrl       = 'http://test.bdrpaiementtest.local/api/fina-app';
  static const int    connectTimeout = 15000; // ms
  static const int    receiveTimeout = 30000; // ms

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String keyToken          = 'fina_token';
  static const String keyRim            = 'fina_rim';
  static const String keyNomComplet     = 'fina_nom';
  static const String keyCompteDefaut   = 'fina_compte_defaut';
  static const String keyBiometrie      = 'fina_biometrie';
  static const String keyOnboardingDone = 'fina_onboarding_done';
  static const String keyDeviceId       = 'fina_device_id';
  static const String keyDernierLogin   = 'fina_dernier_login';

  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName    = 'MY FINAAPP';
  static const String appVersion = '1.0.0';
  static const String currency   = 'FCFA';
}