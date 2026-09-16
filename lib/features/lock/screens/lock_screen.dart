import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/storage_service.dart';
import '../controllers/lock_controller.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LockController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Fond décoratif ──────────────────────────────────────────────
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 200, left: -80,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),

          // ── Contenu principal ────────────────────────────────────────────
          Column(
            children: [
              // Header (fond bleu)
              _LockHeader(ctrl: ctrl),

              // Zone du milieu scrollable (QR + bottom sheet)
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // QR Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _QrCard(ctrl: ctrl),
                      ),

                      const SizedBox(height: 8),

                      // Version
                      Text(
                        'Version: 1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.35),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bottom Sheet blanc
                      _LockBottomSheet(ctrl: ctrl),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Overlay session expirée ──────────────────────────────────────
          GetBuilder<LockController>(
            builder: (c) {
              if (!c.sessionExpiree.value) return const SizedBox.shrink();
              return _SessionExpireeOverlay(ctrl: c);
            },
          ),
        ],
      ),
    );
  }
}


// ── Header ────────────────────────────────────────────────────────────────────
class _LockHeader extends StatelessWidget {
  final LockController ctrl;
  const _LockHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            // Logo
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('F', style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                )),
              ),
            ),
            const SizedBox(width: 12),

            // Nom + compte
            Expanded(
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctrl.nomComplet.value.isEmpty
                        ? 'MY FINAAPP'
                        : ctrl.nomComplet.value,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700, fontFamily: 'DMSans',
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ctrl.compteDefaut.value.isEmpty
                        ? 'FINADEV SA'
                        : ctrl.compteDefaut.value,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 11,
                    ),
                  ),
                ],
              )),
            ),

            // Cloche
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}


// ── QR Card ───────────────────────────────────────────────────────────────────
class _QrCard extends StatelessWidget {
  final LockController ctrl;
  const _QrCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final rim   = Get.find<StorageService>().getRim() ?? 'FINADEV';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          // QR
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: QrImageView(
              data: 'FINADEV:$rim',
              version: QrVersions.auto,
              size: size.width * 0.48,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          // Bouton Scanner
          SizedBox(
            width: 150, height: 36,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
              label: const Text('Scanner QR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Solde masqué
          Obx(() => GestureDetector(
            onTap: ctrl.toggleSolde,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ctrl.soldeVisible.value ? '125 800 FCFA' : '****** FCFA',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w700, fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  ctrl.soldeVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.7), size: 20,
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}


// ── Bottom Sheet ──────────────────────────────────────────────────────────────
class _LockBottomSheet extends StatelessWidget {
  final LockController ctrl;
  const _LockBottomSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 14),

          // Dernier login
          Obx(() {
            final login = ctrl.dernierLogin.value;
            if (login.isEmpty) return const SizedBox(height: 4);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Dernière connexion : $login',
                style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary,
                ),
              ),
            );
          }),

          // Champ PIN local
          _LocalPinField(ctrl: ctrl),

          const SizedBox(height: 12),

          // Erreur
          Obx(() {
            final msg = ctrl.errorMessage.value;
            if (msg.isEmpty) return const SizedBox(height: 4);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ErrorBanner(message: msg),
            );
          }),

          // Bouton SE CONNECTER
          Obx(() => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: ctrl.isLoading.value ? null : ctrl.submitPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: ctrl.isLoading.value
                  ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
                  : const Text('SE CONNECTER',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    letterSpacing: 1.2, fontFamily: 'DMSans',
                  )),
            ),
          )),

          const SizedBox(height: 14),

          // Biométrie + Changer de compte
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => ctrl.biometrieActive.value
                  ? GestureDetector(
                onTap: ctrl.connexionBiometrie,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.fingerprint_rounded,
                      color: AppColors.primary, size: 28),
                ),
              )
                  : const SizedBox(width: 48)),

              TextButton.icon(
                onPressed: ctrl.changerDeCompte,
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text('Changer de Compte'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                  ),
                ),
              ),
            ],
          ),

          // Espace pour le clavier
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOut);
  }
}


// ── Champ PIN local ───────────────────────────────────────────────────────────
class _LocalPinField extends StatefulWidget {
  final LockController ctrl;
  const _LocalPinField({required this.ctrl});

  @override
  State<_LocalPinField> createState() => _LocalPinFieldState();
}

class _LocalPinFieldState extends State<_LocalPinField> {
  late final TextEditingController _pinCtrl;

  @override
  void initState() {
    super.initState();
    _pinCtrl = TextEditingController();
    widget.ctrl.setPinController(_pinCtrl);
  }

  @override
  void dispose() {
    widget.ctrl.clearPinController();
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: _pinCtrl,
      length: 4,
      keyboardType: TextInputType.number,
      obscureText: true,
      autofocus: false,
      onCompleted: (pin) => widget.ctrl.connexionPin(pin),
      onChanged: (_) => widget.ctrl.clearError(),
      defaultPinTheme: PinTheme(
        width: 68, height: 68,
        textStyle: const TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.background,
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 68, height: 68,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2.5),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withOpacity(0.04),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 68, height: 68,
        textStyle: const TextStyle(fontSize: 26, color: Colors.white),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}


// ── Overlay Session Expirée ───────────────────────────────────────────────────
class _SessionExpireeOverlay extends StatelessWidget {
  final LockController ctrl;
  const _SessionExpireeOverlay({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30,
            offset: Offset(0, -10),
          )],
        ),
        padding: EdgeInsets.fromLTRB(
          28, 28, 28,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.access_time_rounded,
                  color: AppColors.warning, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Expiration de session',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  fontFamily: 'DMSans',
                )),
            const SizedBox(height: 8),
            const Text(
              'Session terminée. Connectez-vous\npour utiliser l\'application.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // 1. On cache l'overlay
                  ctrl.sessionExpiree.value = false;

                  // 2. On donne le focus après une courte animation (300ms)
                  Future.delayed(const Duration(milliseconds: 300), () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'SE CONNECTER',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOut),
    );
  }
}