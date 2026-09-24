import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

/// Representation of the 5 distinct clean cars and color themes for the onboarding experience.
class OnboardingCarSlide {
  final String carName;
  final String colorTag;
  final Color accentColor;
  final String assetPath;
  final String fallbackUrl;

  const OnboardingCarSlide({
    required this.carName,
    required this.colorTag,
    required this.accentColor,
    required this.assetPath,
    required this.fallbackUrl,
  });
}

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  static const List<OnboardingCarSlide> _carSlides = [
    // 1. Sunset Orange / Terracotta Bronze (Signature Velix Brand Color)
    OnboardingCarSlide(
      carName: 'Range Rover Velar',
      colorTag: 'Sunset Orange',
      accentColor: Color(0xFFE05A00),
      assetPath: 'assets/images/range_rover_sunset.jpg',
      fallbackUrl: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1600&q=90',
    ),
    // 2. Obsidian Midnight Black (Executive Luxury)
    OnboardingCarSlide(
      carName: 'Mercedes-Benz GLE',
      colorTag: 'Obsidian Black',
      accentColor: Color(0xFF1E293B),
      assetPath: 'assets/images/mercedes_luxury.jpg',
      fallbackUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1600&q=90',
    ),
    // 3. Arctic Pearl White (Pristine Luxury)
    OnboardingCarSlide(
      carName: 'Lexus RX 350',
      colorTag: 'Pearl White',
      accentColor: Color(0xFFF8FAFC),
      assetPath: 'assets/images/lexus_suv.jpg',
      fallbackUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1600&q=90',
    ),
    // 4. Electric Sapphire Blue (Modern Electric Tech)
    OnboardingCarSlide(
      carName: 'Tesla Model 3',
      colorTag: 'Electric Blue',
      accentColor: Color(0xFF0284C7),
      assetPath: 'assets/images/tesla_electric.jpg',
      fallbackUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1600&q=90',
    ),
    // 5. Ruby Crimson Red (Exotic Sport Performance)
    OnboardingCarSlide(
      carName: 'Porsche 911 Carrera',
      colorTag: 'Crimson Red',
      accentColor: Color(0xFFDC2626),
      assetPath: 'assets/images/sports_exotic.jpg',
      fallbackUrl: 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1600&q=90',
    ),
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache all 5 clean car images in GPU memory for instantaneous, zero-delay switching
    for (final slide in _carSlides) {
      precacheImage(AssetImage(slide.assetPath), context).catchError((_) {
        if (mounted) {
          precacheImage(NetworkImage(slide.fallbackUrl), context);
        }
      });
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3800), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _carSlides.length;
        });
      }
    });
  }

  void _onSelectSlide(int index) {
    setState(() {
      _currentIndex = index;
    });
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCar = _carSlides[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        children: [
          // 5-Car High-Definition Background Slideshow with Smooth Crossfade & Ken-Burns Motion
          Positioned.fill(
            child: _FiveCarCinematicBackground(
              slide: currentCar,
              slideIndex: _currentIndex,
            ),
          ),

          // Top Gradient Scrim for crisp branding and header contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top Header: Logo + 5 Distinct Car Color Indicators
          Positioned(
            top: 48,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/icons/app_logo.png',
                    height: 38,
                    errorBuilder: (context, error, stackTrace) => const VelixLogoHeader(),
                  ),
                ),
                const SizedBox(height: 10),
                // 5 Color Segment Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_carSlides.length, (index) {
                    final isSelected = index == _currentIndex;
                    final slide = _carSlides[index];
                    return GestureDetector(
                      onTap: () => _onSelectSlide(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 5,
                        width: isSelected ? 30 : 10,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE05A00) : Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: slide.accentColor.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Lowered & Reduced Curved Terracotta / Orange Arch Container so Cars are fully showcased
          Positioned(
            left: -120,
            right: -120,
            bottom: -190,
            height: 460,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE05A00),
                    Color(0xFFC84C00),
                    Color(0xFFB84000),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                  BoxShadow(
                    color: const Color(0xFFC84C00).withValues(alpha: 0.35),
                    blurRadius: 45,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(140.0, 24.0, 140.0, 180.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Velix',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                    const Text(
                      'AUTO RENTAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // "Get Started" Action Button
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C1830),
                            ),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFF0C1830),
                            child: Icon(Icons.arrow_forward, size: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // "Already have an account? Login" Footer
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signIn),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ultra-smooth Ken-Burns dynamic background with crossfade transitions between the 5 cars.
class _FiveCarCinematicBackground extends StatefulWidget {
  final OnboardingCarSlide slide;
  final int slideIndex;

  const _FiveCarCinematicBackground({
    required this.slide,
    required this.slideIndex,
  });

  @override
  State<_FiveCarCinematicBackground> createState() => _FiveCarCinematicBackgroundState();
}

class _FiveCarCinematicBackgroundState extends State<_FiveCarCinematicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant _FiveCarCinematicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slideIndex != widget.slideIndex) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 900),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: AnimatedBuilder(
        key: ValueKey<int>(widget.slideIndex),
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox.expand(
              child: Image.asset(
                widget.slide.assetPath,
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.25), // Framed to showcase the vehicle body in the upper 70% viewport
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  widget.slide.fallbackUrl,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.25),
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF111827),
                    child: const Center(
                      child: Icon(Icons.directions_car, size: 90, color: Color(0xFFE05A00)),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
