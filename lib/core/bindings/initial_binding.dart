import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Ces services sont permanent: true → jamais détruits
    // AsyncInit pour StorageService
    Get.putAsync<StorageService>(
          () async {
        final service = StorageService();
        await service.init();
        return service;
      },
      permanent: true,
    );

    Get.put<ApiService>(
      ApiService(),
      permanent: true,
    );
  }
}




// =============================================================================
// lib/features/splash/splash_screen.dart — _navigate() corrigé
// Remplacer la méthode _navigate() existante
// =============================================================================

// Le problème venait aussi du fait que _navigate() appelait Get.find()
// trop tôt avant que putAsync() termine.
// Voici la version corrigée avec await sur le service :

/*
Future<void> _navigate() async {
  await Future.delayed(const Duration(milliseconds: 2800));

  // Attendre que StorageService soit prêt (cas putAsync)
  final storage = await Get.putAsync<StorageService>(
    () async {
      final s = StorageService();
      await s.init();
      return s;
    },
    permanent: true,
  ).catchError((_) => Get.find<StorageService>());

  if (!storage.isOnboardingDone()) {
    Get.offAllNamed(AppRoutes.ONBOARDING);
    return;
  }

  final hasToken = await storage.hasToken();
  if (hasToken) {
    Get.offAllNamed(AppRoutes.LOCK_SCREEN);
  } else {
    Get.offAllNamed(AppRoutes.ENTER_RIM);
  }
}
*/

// OU plus simple — utiliser cette version dans _navigate() :
/*
Future<void> _navigate() async {
  await Future.delayed(const Duration(milliseconds: 2800));

  StorageService storage;
  try {
    storage = Get.find<StorageService>();
  } catch (_) {
    // Service pas encore prêt, réessayer
    await Future.delayed(const Duration(milliseconds: 500));
    storage = Get.find<StorageService>();
  }

  if (!storage.isOnboardingDone()) {
    Get.offAllNamed(AppRoutes.ONBOARDING);
    return;
  }

  final hasToken = await storage.hasToken();
  if (hasToken) {
    Get.offAllNamed(AppRoutes.LOCK_SCREEN);
  } else {
    Get.offAllNamed(AppRoutes.ENTER_RIM);
  }
}
*/