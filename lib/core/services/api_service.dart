// =============================================================================
// lib/core/services/api_service.dart
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import 'package:my_finaapp/core/services/storage_service.dart';
import '../utils/app_constants.dart';
import '../routes/app_routes.dart';

class ApiService extends GetxService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LogInterceptor());
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifierRim(String rim) async {
    return _post('/auth/verifier-rim', {'rim': rim});
  }

  Future<Map<String, dynamic>> verifierOtp(String rim, String code) async {
    return _post('/auth/verifier-otp', {'rim': rim, 'code': code});
  }

  Future<Map<String, dynamic>> creerPin({
    required String rim,
    required String pin,
    required String deviceId,
    String? deviceName,
  }) async {
    return _post('/auth/creer-pin', {
      'rim': rim,
      'pin': pin,
      'device_id': deviceId,
      'device_name': deviceName,
    });
  }

  Future<Map<String, dynamic>> connexionPin({
    required String rim,
    required String pin,
    required String deviceId,
    String? deviceName,
  }) async {
    return _post('/auth/connexion-pin', {
      'rim': rim,
      'pin': pin,
      'device_id': deviceId,
      'device_name': deviceName,
    });
  }

  Future<Map<String, dynamic>> rimOublieEnvoyerOtp({
    required String numeroCompte,
    required String telephone,
  }) async {
    return _post('/auth/rim-oublie/envoyer-otp', {
      'numero_compte': numeroCompte,
      'telephone': telephone,
    });
  }

  Future<Map<String, dynamic>> rimOublieVerifierOtp({
    required String telephone,
    required String code,
  }) async {
    return _post('/auth/rim-oublie/verifier-otp', {
      'telephone': telephone,
      'code': code,
    });
  }

  Future<Map<String, dynamic>> toggleBiometrie(bool activer) async {
    return _post('/auth/biometrie', {'activer': activer});
  }

  Future<Map<String, dynamic>> changerCompteDefaut(String numeroCompte) async {
    return _post('/auth/compte-defaut', {'numero_compte': numeroCompte});
  }

  Future<void> deconnexion() async {
    await _post('/auth/deconnexion', {});
  }

  // ── Comptes ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfil() async {
    return _get('/profil');
  }

  Future<Map<String, dynamic>> getMesComptes() async {
    return _get('/comptes');
  }

  Future<Map<String, dynamic>> getSolde(String numeroCompte) async {
    return _get('/comptes/$numeroCompte/solde');
  }

  Future<Map<String, dynamic>> getHistorique(
      String numeroCompte, {
        int page = 1,
        int perPage = 20,
        String? dateDebut,
        String? dateFin,
        String? sens,
      }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (dateDebut != null) 'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
      if (sens != null) 'sens': sens,
    };
    return _get('/comptes/$numeroCompte/historique', queryParams: params);
  }

  Future<Map<String, dynamic>> getReleve(
      String numeroCompte, {
        required String dateDebut,
        required String dateFin,
      }) async {
    return _get('/comptes/$numeroCompte/releve', queryParams: {
      'date_debut': dateDebut,
      'date_fin': dateFin,
    });
  }

  // ── Transferts ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> rechercherBeneficiaire(String recherche) async {
    return _get('/transfert/rechercher-beneficiaire',
        queryParams: {'recherche': recherche});
  }

  Future<Map<String, dynamic>> demanderOtpTransfert({
    required String compteSource,
    required String compteDestination,
    required double montant,
  }) async {
    return _post('/transfert/demander-otp', {
      'compte_source': compteSource,
      'compte_destination': compteDestination,
      'montant': montant,
    });
  }

  Future<Map<String, dynamic>> transfertCompteACompte({
    required String compteSource,
    required String compteDestination,
    required double montant,
    required String otp,
    String? motif,
  }) async {
    return _post('/transfert/compte-a-compte', {
      'compte_source': compteSource,
      'compte_destination': compteDestination,
      'montant': montant,
      'otp': otp,
      if (motif != null) 'motif': motif,
    });
  }

  Future<Map<String, dynamic>> demandeDepotMomo({
    required String compteDestination,
    required double montant,
    required String telephoneMomo,
    required String operateur,
  }) async {
    return _post('/transfert/depot-momo', {
      'compte_destination': compteDestination,
      'montant': montant,
      'telephone_momo': telephoneMomo,
      'operateur': operateur,
    });
  }

  Future<Map<String, dynamic>> getPispiInfo() async {
    return _get('/transfert/pispi/info');
  }

  /// Vérifie si PI-SPI est configuré et disponible
  Future<Map<String, dynamic>> getPispiStatut() async {
    return _get('/pispi/statut');
  }

  // ── Alias ─────────────────────────────────────────────────────────────────

  /// Liste des alias PI-SPI du client connecté
  Future<Map<String, dynamic>> getMesAlias() async {
    return _get('/pispi/alias');
  }

  /// Créer un alias SHID ou MBNO
  /// [type] : 'SHID' ou 'MBNO'
  /// [numeroCompte] : numéro de compte FINADEV
  /// [telephone] : requis si type == 'MBNO'
  Future<Map<String, dynamic>> creerAliaspispi({
    required String numeroCompte,
    required String type,
    String? telephone,
  }) async {
    return _post('/pispi/alias', {
      'numero_compte': numeroCompte,
      'type': type,
      if (telephone != null) 'telephone': telephone,
    });
  }

  /// Confirmer un alias MBNO avec le code OTP reçu par SMS de PI
  Future<Map<String, dynamic>> confirmerAliasPispi({
    required String cle,
    required String otp,
  }) async {
    return _post('/pispi/alias/$cle/confirmer', {'otp': otp});
  }

  /// Supprimer un alias
  Future<Map<String, dynamic>> supprimerAliasPispi(String cle) async {
    return _delete('/pispi/alias/$cle');
  }

  // ── Participants ──────────────────────────────────────────────────────────

  /// Liste des institutions financières actives sur PI-SPI
  Future<Map<String, dynamic>> getParticipantsPispi() async {
    return _get('/pispi/participants');
  }

  // ── Transferts ────────────────────────────────────────────────────────────

  /// Étape 1 : Initier un transfert PI-SPI
  Future<Map<String, dynamic>> initierTransfertPispi({
    required String compteSource,
    required double montant,
    required double latitude,
    required double longitude,
    String? alias,
    String? iban,
    String? numeroCompteDestination,
    String? motif,
  }) async {
    return _post('/pispi/transfert/initier', {
      'compte_source': compteSource,
      'montant': montant,
      'latitude': latitude,
      'longitude': longitude,
      if (alias != null) 'alias': alias,
      if (iban != null) 'iban': iban,
      if (numeroCompteDestination != null)
        'numero_compte_destination': numeroCompteDestination,
      if (motif != null) 'motif': motif,
    });
  }

  /// Étape 2 : Confirmer le transfert après PIN/biométrie
  Future<Map<String, dynamic>> confirmerTransfertPispi({
    required String endToEndId,
    required String methodeConfirmation, // 'pin' ou 'biometry'
    required double montant,
    double? latitude,
    double? longitude,
    String? motif,
  }) async {
    return _post('/pispi/transfert/confirmer', {
      'end_to_end_id': endToEndId,
      'methode_confirmation': methodeConfirmation,
      'montant': montant,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (motif != null) 'motif': motif,
    });
  }

  /// Vérifier le statut final d'un transfert (polling)
  Future<Map<String, dynamic>> getStatutTransfertPispi(
      String endToEndId) async {
    return _get('/pispi/transfert/$endToEndId/statut');
  }

  /// Historique des transferts PI-SPI
  Future<Map<String, dynamic>> getHistoriquePispi({
    int page = 1,
    int limit = 20,
    String? sens,
  }) async {
    return _get('/pispi/transferts', queryParams: {
      'page': page,
      'limit': limit,
      if (sens != null) 'sens': sens,
    });
  }

  // ── Notifications PI-SPI ──────────────────────────────────────────────────

  /// Notifications PI-SPI d'un compte
  Future<Map<String, dynamic>> getNotificationsPispi(
      String compte, {
        int page = 1,
        int limit = 20,
      }) async {
    return _get('/pispi/notifications/$compte',
        queryParams: {'page': page, 'limit': limit});
  }

  /// Nombre de notifications non lues (badge)
  Future<Map<String, dynamic>> getNonLuesPispi(String compte) async {
    return _get('/pispi/notifications/$compte/non-lues');
  }

  /// Marquer une notification comme lue
  Future<Map<String, dynamic>> marquerLuePispi(String id) async {
    return _put('/pispi/notifications/$id/lue', {});
  }

  // =========================================================================
  // MÉTHODES PRIVÉES SUPPLÉMENTAIRES
  // Ajouter _put et _delete dans api_service.dart si pas encore présentes
  // =========================================================================

  Future<Map<String, dynamic>> _put(
      String path,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    try {
      final response = await _dio.delete(path);
      // 204 No Content
      if (response.statusCode == 204) {
        return {'success': true, 'data': null};
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // =========================================================================
  // MÉTHODES PRIVÉES
  // =========================================================================

  Future<Map<String, dynamic>> _get(
      String path, {
        Map<String, dynamic>? queryParams,
      }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _post(
      String path,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': false, 'message': 'Erreur serveur (${e.response!.statusCode})'};
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return {'success': false, 'message': 'Connexion trop lente. Vérifiez votre réseau.'};
    }
    return {'success': false, 'message': 'Pas de connexion internet.'};
  }
}

// ── Intercepteur Auth ─────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // ✅ Lire directement depuis StorageService (même instance)
      final storage = Get.find<StorageService>();
      final token = await storage.getToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ TOKEN ENVOYÉ: ${token.substring(0, 10)}...');
      } else {
        debugPrint('❌ TOKEN MANQUANT');
      }
    } catch (e) {
      debugPrint('❌ Erreur lecture token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          Get.offAllNamed(AppRoutes.LOCK_SCREEN,
              arguments: {'expired': true});
        } catch (_) {}
      });
    }
    handler.next(err);
  }
}

// ── Intercepteur Log (dev seulement) ─────────────────────────────────────────
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✗ ${err.response?.statusCode} ${err.requestOptions.path}');
    handler.next(err);
  }
}