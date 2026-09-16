abstract class AppRoutes {
  // Auth flow
  static const SPLASH         = '/splash';
  static const ONBOARDING     = '/onboarding';
  static const ENTER_RIM      = '/auth/enter-rim';
  static const RIM_OUBLIE     = '/auth/rim-oublie';
  static const VERIFY_OTP     = '/auth/verify-otp';
  static const CREATE_PIN     = '/auth/create-pin';
  static const LOCK_SCREEN    = '/lock-screen';      // Écran de veille QR
  static const BIOMETRIE      = '/auth/biometrie';

  // Main app
  static const HOME           = '/home';
  static const PROFIL         = '/profil';
  static const COMPTES        = '/comptes';
  static const HISTORIQUE     = '/historique';
  static const RELEVE         = '/releve';

  // Transferts
  static const TRANSFERT      = '/transfert';
  static const DEPOT_MOMO     = '/depot-momo';
  static const PISPI          = '/pispi';

  // Notifications
  static const NOTIFICATIONS  = '/notifications';
}