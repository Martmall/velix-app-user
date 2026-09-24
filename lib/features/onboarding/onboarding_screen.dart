import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Find Your Perfect Drive',
      'subtitle': 'Sunset Orange • Luxury SUV',
      'description': 'Experience the open road in rugged refinement and unmatched comfort.',
      'asset': 'assets/images/range_rover_sunset.jpg',
      'fallback': 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85',
      'color': const Color(0xFFE05A00),
    },
    {
      'title': 'Executive Luxury & Class',
      'subtitle': 'Obsidian Black • Premium SUV',
      'description': 'Arrive in style with our chauffeured and self-drive executive fleet.',
      'asset': 'assets/images/mercedes_luxury.jpg',
      'fallback': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85',
      'color': const Color(0xFF334155),
    },
    {
      'title': 'Pristine Coastal Elegance',
      'subtitle': 'Pearl White • Modern Luxury',
      'description': 'Enjoy ultra-smooth rides with state-of-the-art climate and comfort control.',
      'asset': 'assets/images/lexus_suv.jpg',
      'fallback': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=85',
      'color': const Color(0xFF94A3B8),
    },
    {
      'title': 'Keyless Electric Future',
      'subtitle': 'Electric Sapphire • Smart Tech',
      'description': 'Instant phone-as-key digital unlock and zero-emission highway cruising.',
      'asset': 'assets/images/tesla_electric.jpg',
      'fallback': 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=85',
      'color': const Color(0xFF0284C7),
    },
    {
      'title': 'High Performance Exotics',
      'subtitle': 'Ruby Crimson • Sport Coupe',
      'description': 'Unleash track-level engineering and breathtaking acceleration on demand.',
      'asset': 'assets/images/sports_exotic.jpg',
      'fallback': 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=85',
      'color': const Color(0xFFDC2626),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signIn),
                    child: const Text('Skip', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 270,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: AppColors.cardDark,
                            border: Border.all(color: (page['color'] as Color).withValues(alpha: 0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: (page['color'] as Color).withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              page['asset'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.network(
                                page['fallback'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, size: 80, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: (page['color'] as Color).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            page['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: page['color'] as Color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (idx) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentPage == idx ? 28 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == idx ? (_pages[idx]['color'] as Color) : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: PrimaryButton(
                text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    context.go(AppRoutes.signIn);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
