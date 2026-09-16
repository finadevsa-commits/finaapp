 import 'package:get/get.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/screens/biometrie_screen.dart';
import '../../features/auth/screens/create_pin_screen.dart';
import '../../features/auth/screens/enter_rim_screen.dart';
import '../../features/auth/screens/rim_oublie_screen.dart';
import '../../features/auth/screens/verify_otp_screen.dart';
import '../../features/depot_momo/screens/depot_momo_screen.dart';
import '../../features/historique/controllers/historique_controller.dart';
import '../../features/historique/screens/historique_screen.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/lock/bindings/lock_binding.dart';
import '../../features/lock/screens/lock_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/pispi/screens/pispi_screen.dart';
import '../../features/releve/screens/releve_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/transfert/bindings/transfert_binding.dart';
import '../../features/transfert/screens/transfert_screen.dart';
import '../../features/pispi/bindings/pispi_binding.dart';
import 'app_routes.dart';
// import les screens et bindings...

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
      //binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ENTER_RIM,
      page: () => const EnterRimScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.RIM_OUBLIE,
      page: () => const RimOublieScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VERIFY_OTP,
      page: () => const VerifyOtpScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.CREATE_PIN,
      page: () => const CreatePinScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.LOCK_SCREEN,
      page: () => const LockScreen(),
      binding: LockBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.BIOMETRIE,
      page: () => const BiometrieScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.HISTORIQUE,
      page: () => const HistoriqueScreen(),
      binding: CompteBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.RELEVE,
      page: () => const ReleveScreen(),
      binding: CompteBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.TRANSFERT,
      page: () => const TransfertScreen(),
      binding: TransfertBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.DEPOT_MOMO,
      page: () => const DepotMomoScreen(),
      binding: TransfertBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PISPI,
      page: () => const PispiScreen(),
      binding: PispiBinding(),  // ← cette ligne manque
      transition: Transition.rightToLeft,
    ),
  ];
}