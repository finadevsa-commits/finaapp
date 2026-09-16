import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Gérez votre\nargent facilement',
      subtitle:
      'Consultez votre solde, suivez vos transactions et gérez tous vos comptes FINADEV en un seul endroit.',
      illustrationWidget: _OnboardingIllustration1(),
      bgColor: const Color(0xFF0F2D45),
    ),
    _OnboardingData(
      title: 'Transférez\nsans frais',
      subtitle:
      'Envoyez de l\'argent entre comptes FINADEV instantanément. Déposez depuis MTN MoMo ou Moov Money.',
      illustrationWidget: _OnboardingIllustration2(),
      bgColor: const Color(0xFF7B1514),
    ),
    _OnboardingData(
      title: 'Sécurisé &\nconfidentiel',
      subtitle:
      'PIN à 4 chiffres, authentification biométrique et OTP SMS pour protéger chaque transaction.',
      illustrationWidget: _OnboardingIllustration3(),
      bgColor: const Color(0xFF1A4A6B),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Get.find<StorageService>().setOnboardingDone();
    Get.offAllNamed(AppRoutes.ENTER_RIM);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _OnboardingPage(data: _pages[index], size: size);
            },
          ),

          // Boutons en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OnboardingBottomBar(
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _nextPage,
              onSkip: _finish,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String subtitle;
  final Widget illustrationWidget;
  final Color bgColor;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.illustrationWidget,
    required this.bgColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Size size;

  const _OnboardingPage({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Zone illustration (haut — fond coloré avec courbe)
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Container(
              height: size.height * 0.52,
              width: double.infinity,
              color: data.bgColor,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: data.illustrationWidget,
                ),
              ),
            ),
          ),

          // Zone texte (bas — fond blanc)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      height: 1.2,
                      fontFamily: 'DMSans',
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.6,
                      fontFamily: 'DMSans',
                    ),
                  ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _OnboardingBottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots indicateur
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Bouton SUIVANT / COMMENCER
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                isLast ? 'COMMENCER' : 'SUIVANT',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bouton PASSER (sauf sur la dernière page)
          if (!isLast)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'PASSER',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 1,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Clipper pour la courbe en bas de la zone illustration
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BottomCurveClipper old) => false;
}


// =============================================================================
// ILLUSTRATIONS ONBOARDING (SVG-style dessinées en Flutter)
// À remplacer par de vraies illustrations Lottie ou SVG plus tard
// =============================================================================

class _OnboardingIllustration1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de fond
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          // Phone mockup
          Container(
            width: 130,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Header card solde
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solde',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 8)),
                        const Text('***** FCFA',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Mini transactions
                  ...List.generate(
                    3,
                        (i) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      height: 20,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? AppColors.credit.withOpacity(0.1)
                            : AppColors.debit.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Container(
                              width: 40,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              i == 0 ? '+5 000' : '-2 500',
                              style: TextStyle(
                                fontSize: 7,
                                color: i == 0
                                    ? AppColors.credit
                                    : AppColors.debit,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
        ],
      ),
    );
  }
}

class _OnboardingIllustration2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          // Deux phones avec flèche de transfert
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniPhone(
                color: Colors.white,
                textColor: const Color(0xFF7B1514),
                label: 'Vous',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '0 FCFA\nde frais',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              _MiniPhone(
                color: Colors.white,
                textColor: const Color(0xFF7B1514),
                label: 'Bénéf.',
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).scale(
            begin: const Offset(0.8, 0.8),
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
        ],
      ),
    );
  }
}

class _OnboardingIllustration3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône cadenas
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF1A4A6B),
                  size: 44,
                ),
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 20),
              // Row des méthodes sécurité
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SecurityBadge(icon: Icons.pin_rounded, label: 'PIN'),
                  const SizedBox(width: 12),
                  _SecurityBadge(
                      icon: Icons.fingerprint_rounded, label: 'Biométrie'),
                  const SizedBox(width: 12),
                  _SecurityBadge(icon: Icons.sms_rounded, label: 'OTP SMS'),
                ],
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPhone extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String label;

  const _MiniPhone({
    required this.color,
    required this.textColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 95,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SecurityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}