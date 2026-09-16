import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../controllers/home_controller.dart';
import '../../../core/models/compte_model.dart';
import '../../../core/models/operation_model.dart';
import 'dart:async';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: ctrl.rafraichir,
        child: CustomScrollView(
          slivers: [
            // ── AppBar custom ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _HomeAppBar(ctrl: ctrl)),

            // ── Card Solde (swipeable entre comptes) ───────────────────────
            SliverToBoxAdapter(
              child: _SoldeCardSection(ctrl: ctrl),
            ),

            // ── Tabs : POUR VOUS / PAYER / SERVICES ───────────────────────
            SliverToBoxAdapter(
              child: _QuickActionsSection(ctrl: ctrl),
            ),

            // ── Bannières communication ────────────────────────────────────
            SliverToBoxAdapter(
              child: _BannersSection(),
            ),

            // ── Transactions récentes ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _TransactionsSection(ctrl: ctrl),
            ),

            // Espace bottom nav
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ────────────────────────────────────────────
      bottomNavigationBar: _HomeBottomNav(ctrl: ctrl),

      // ── FAB central QR ────────────────────────────────────────────────────
      floatingActionButton: _QrFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}


// ── AppBar Home ────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  final HomeController ctrl;
  const _HomeAppBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              // Avatar profil
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.PROFIL),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 22),
                ),
              ),

              const SizedBox(width: 12),

              // Salutation + nom
              Expanded(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _salutation(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'DMSans',
                      ),
                    ),
                    Text(
                      ctrl.nomComplet.value.isEmpty
                          ? 'MY FINAAPP'
                          : _prenomSeul(ctrl.nomComplet.value),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'DMSans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),
              ),

              // Logo centré
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('F',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      )),
                ),
              ),

              const SizedBox(width: 12),

              // Cloche notification
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 22),
                  ),
                  // Badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _salutation() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 👋';
    if (h < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 👋';
  }

  String _prenomSeul(String nomComplet) {
    final parts = nomComplet.trim().split(' ');
    return parts.isNotEmpty ? parts.first : nomComplet;
  }
}


// ── Section Solde + Comptes ────────────────────────────────────────────────────
class _SoldeCardSection extends StatelessWidget {
  final HomeController ctrl;
  const _SoldeCardSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceDark,
      child: Column(
        children: [
          // Swipe entre comptes
          Obx(() {
            if (ctrl.isLoadingProfil.value) {
              return _SoldeCardSkeleton();
            }

            if (ctrl.comptes.isEmpty) {
              return _SoldeCardVide();
            }

            return Column(
              children: [
                SizedBox(
                  height: 190,
                  child: PageView.builder(
                    itemCount: ctrl.comptes.length,
                    onPageChanged: ctrl.changerCompte,
                    padEnds: true,
                    controller: PageController(viewportFraction: 0.88),
                    itemBuilder: (context, index) {
                      return _SoldeCard(
                        compte: ctrl.comptes[index],
                        ctrl: ctrl,
                        isActive: index == ctrl.currentCompteIndex.value,
                      );
                    },
                  ),
                ),

                // Dots indicateur comptes
                if (ctrl.comptes.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(ctrl.comptes.length, (i) {
                        final isActive = i == ctrl.currentCompteIndex.value;
                        return AnimatedContainer(
                          duration: 300.ms,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accent
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            );
          }),

          // Courbe blanche
          Container(
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoldeCard extends StatelessWidget {
  final CompteModel compte;
  final HomeController ctrl;
  final bool isActive;

  const _SoldeCard({
    required this.compte,
    required this.ctrl,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.95,
      duration: 300.ms,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type compte + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    compte.typeCompte,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
                // Œil toggle solde
                GestureDetector(
                  onTap: ctrl.toggleSolde,
                  child: Obx(() => Icon(
                    ctrl.soldeVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  )),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Numéro de compte
            Text(
              compte.numeroCompte,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                letterSpacing: 1,
                fontFamily: 'DMSans',
              ),
            ),

            const SizedBox(height: 6),

            // Solde
            Obx(() => Text(
              ctrl.soldeVisible.value
                  ? compte.soldeFormate
                  : '******* FCFA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                fontFamily: 'DMSans',
              ),
            )),

            const Spacer(),

            // Actions rapides bas de carte
            Row(
              children: [
                _CardAction(
                  icon: Icons.add_rounded,
                  label: 'Dépôt',
                  onTap: () => Get.toNamed(AppRoutes.DEPOT_MOMO,
                      arguments: {'compte': compte.numeroCompte}),
                ),
                _CardDivider(),
                _CardAction(
                  icon: Icons.remove_rounded,
                  label: 'Retrait',
                  onTap: () {},
                ),
                _CardDivider(),
                _CardAction(
                  icon: Icons.receipt_long_outlined,
                  label: 'Relevés',
                  onTap: () => Get.toNamed(AppRoutes.RELEVE,
                      arguments: {'compte': compte.numeroCompte}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

class _SoldeCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHigh,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _SoldeCardVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          'Aucun compte disponible',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      ),
    );
  }
}

class _ActionTileImage extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _ActionTileImage({
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image au lieu de l'icône
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),

            // Badge "Bientôt"
            if (isComingSoon)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Bientôt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// ── Section Actions Rapides ────────────────────────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  final HomeController ctrl;
  const _QuickActionsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label section
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'POUR VOUS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
                fontFamily: 'DMSans',
              ),
            ),
          ),

          // Grille 2x2
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              _ActionTile(
                icon: Icons.send_rounded,
                label: 'Envoyer\nde l\'argent',
                color: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.TRANSFERT),
              ),
              _ActionTile(
                icon: Icons.account_balance_rounded,
                label: 'Services\nBancaires',
                color: AppColors.surfaceDark,
                onTap: () => Get.toNamed(AppRoutes.COMPTES),
              ),
              _ActionTile(
                icon: Icons.phone_android_rounded,
                label: 'Dépôt\nMoMo',
                color: const Color(0xFF16A34A),
                onTap: () => Get.toNamed(AppRoutes.DEPOT_MOMO),
              ),
              _ActionTile(
                icon: Icons.receipt_outlined,
                label: 'Relevé\nde compte',
                color: const Color(0xFF2563EB),
                onTap: () => Get.toNamed(AppRoutes.RELEVE),
              ),
              _ActionTileImage(
                imagePath: 'assets/icons/pi_octogone.png',
                label: 'PI-SPI\nInternational',
                onTap: () => Get.toNamed(AppRoutes.PISPI),
                isComingSoon: true,
              ),
              _ActionTile(
                icon: Icons.history_rounded,
                label: 'Historique\nOpérations',
                color: const Color(0xFF7C3AED),
                onTap: () => Get.toNamed(AppRoutes.HISTORIQUE),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),

            // Badge "Bientôt"
            if (isComingSoon)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Bientôt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// ── Section Bannières ──────────────────────────────────────────────────────────
class _BannersSection extends StatefulWidget {
  const _BannersSection();

  @override
  State<_BannersSection> createState() => _BannersSectionState();
}

class _BannersSectionState extends State<_BannersSection> {
  final PageController _pageController = PageController(
    viewportFraction: 0.88,
  );
  int _currentIndex = 0;
  Timer? _timer;

  final List<_BannerData> banners = const [
    _BannerData(
      title: 'Transfert International\nsans frais avec PI-SPI',
      subtitle: 'Disponible bientôt',
      color: Color(0xFF0F2D45),
      accentColor: Color(0xFFC8962A),
      icon: Icons.language_rounded,
    ),
    _BannerData(
      title: 'Déposez depuis\nMTN MoMo ou Moov',
      subtitle: 'Simple et rapide',
      color: Color(0xFF7B1514),
      accentColor: Colors.white,
      icon: Icons.phone_android_rounded,
    ),
    _BannerData(
      title: 'Votre relevé\nen quelques secondes',
      subtitle: 'Téléchargez en PDF',
      color: Color(0xFF1A6B3C),
      accentColor: Colors.white,
      icon: Icons.receipt_long_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        children: [
          // PageView bannières
          SizedBox(
            height: 110,
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _BannerCard(data: banners[index]),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Dots indicateurs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}


// ── Données bannière ───────────────────────────────────────────────────────────
class _BannerData {
  final String title;
  final String subtitle;
  final Color color;
  final Color accentColor;
  final IconData icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.accentColor,
    required this.icon,
  });
}


// ── Card bannière ──────────────────────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: data.accentColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    data.subtitle,
                    style: TextStyle(
                      color: data.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Icône
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              color: data.accentColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}



// ── Section Transactions Récentes ─────────────────────────────────────────────
class _TransactionsSection extends StatelessWidget {
  final HomeController ctrl;
  const _TransactionsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'DMSans',
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.HISTORIQUE),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Liste
          Obx(() {
            if (ctrl.isLoadingHistorique.value) {
              return Column(
                children: List.generate(
                  3,
                      (_) => _TransactionSkeleton(),
                ),
              );
            }

            if (ctrl.derniersOps.isEmpty) {
              return _TransactionVide();
            }

            return Column(
              children: ctrl.derniersOps
                  .asMap()
                  .entries
                  .map((e) => _TransactionTile(
                op: e.value,
                index: e.key,
              ))
                  .toList(),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _TransactionTile extends StatelessWidget {
  final OperationModel op;
  final int index;

  const _TransactionTile({required this.op, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône sens opération
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: op.isCredit
                  ? AppColors.credit.withOpacity(0.1)
                  : AppColors.debit.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              op.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: op.isCredit ? AppColors.credit : AppColors.debit,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  op.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'DMSans',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  op.date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Montant
          Text(
            '${op.isCredit ? '+' : '-'} ${op.montantFormate}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: op.isCredit ? AppColors.credit : AppColors.debit,
              fontFamily: 'DMSans',
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 80).ms).fadeIn().slideX(begin: 0.1);
  }
}

class _TransactionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHigh,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _TransactionVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                color: AppColors.textHint, size: 36),
            const SizedBox(height: 8),
            Text(
              'Aucune transaction récente',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Bottom Navigation Bar ──────────────────────────────────────────────────────
class _HomeBottomNav extends StatelessWidget {
  final HomeController ctrl;
  const _HomeBottomNav({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.surface,
      elevation: 12,
      child: SizedBox(
        height: 60,
        child: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              isActive: ctrl.currentNavIndex.value == 0,
              onTap: () => ctrl.onNavTap(0),
            ),
            _NavItem(
              icon: Icons.send_rounded,
              label: 'Envoyer',
              isActive: ctrl.currentNavIndex.value == 1,
              onTap: () => ctrl.onNavTap(1),
            ),
            // Espace pour le FAB
            const SizedBox(width: 56),
            _NavItem(
              icon: Icons.card_giftcard_rounded,
              label: 'Offres',
              isActive: ctrl.currentNavIndex.value == 3,
              onTap: () => ctrl.onNavTap(3),
            ),
            _NavItem(
              icon: Icons.more_horiz_rounded,
              label: 'Plus',
              isActive: ctrl.currentNavIndex.value == 4,
              onTap: () => ctrl.onNavTap(4),
            ),
          ],
        )),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── FAB QR central ────────────────────────────────────────────────────────────
class _QrFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.LOCK_SCREEN),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}