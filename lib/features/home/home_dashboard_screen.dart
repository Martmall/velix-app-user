import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  String _selectedCategory = 'All';
  late final PageController _bannerPageController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'badge': 'LIMITED OFFER',
      'title': 'First ride? Get ',
      'highlight': '₦5,000 OFF',
      'code': 'VELO5K',
      'buttonText': 'Claim Now',
      'gradient': [const Color(0xFF0C1830), const Color(0xFF1E293B)],
      'accent': const Color(0xFFC84C00),
      'icon': Icons.local_fire_department,
      'image': CarImageCatalog.limitedOfferBanner,
    },
    {
      'badge': 'WEEKEND SPECIAL',
      'title': 'Explore in luxury with ',
      'highlight': '20% OFF SUVs',
      'code': 'SUVSAVE',
      'buttonText': 'Rent SUV',
      'gradient': [const Color(0xFF7C2D12), const Color(0xFFC84C00)],
      'accent': const Color(0xFFF59E0B),
      'icon': Icons.directions_car,
      'image': CarImageCatalog.weekendEscapeBanner,
    },
    {
      'badge': 'CHAUFFEUR VIP',
      'title': 'Executive Comfort & ',
      'highlight': 'Verified Drivers',
      'code': 'VIPRIDE',
      'buttonText': 'Book Chauffeur',
      'gradient': [const Color(0xFF1E1B4B), const Color(0xFF312E81)],
      'accent': const Color(0xFF818CF8),
      'icon': Icons.shield,
      'image': CarImageCatalog.luxuryChauffeurBanner,
    },
    {
      'badge': 'AIRPORT TRANSFERS',
      'title': 'Guaranteed on-time ',
      'highlight': 'Lagos & Abuja Pickups',
      'code': 'AIRPORT',
      'buttonText': 'Book Transfer',
      'gradient': [const Color(0xFF064E3B), const Color(0xFF047857)],
      'accent': const Color(0xFF34D399),
      'icon': Icons.flight_land,
      'image': CarImageCatalog.featuredHeroBanner,
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _startBannerAutoPlay();
  }

  void _startBannerAutoPlay() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _promoBanners.length;
        _bannerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(userAuthProvider);
    final user = auth.user;
    final firstName = (user?.fullName.isNotEmpty == true) ? user!.fullName.split(' ').first : 'Explorer';
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final allCars = vehiclesAsync.when(
      data: (cars) => cars,
      loading: () => <CarModel>[],
      error: (_, __) => <CarModel>[],
    );

    final filteredCars = allCars.where((c) {
      if (_selectedCategory == 'SUVs') return c.category == 'SUV';
      if (_selectedCategory == 'Sedans') return c.category == 'Sedan';
      if (_selectedCategory == 'Luxury') return c.category == 'Luxury';
      if (_selectedCategory == 'Electric') return c.fuelType == 'Electric';
      return true;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: VelixAppHeader(
        title: user != null ? 'Good Day, $firstName' : 'Welcome, Guest',
        subtitle: user != null ? 'Velix Ride Experience' : 'Explore Luxury & Premium Rides',
        userName: user?.fullName ?? 'Guest Explorer',
        userEmail: user?.email ?? 'Tap to sign in / register',
        avatarUrl: user?.avatarUrl,
        isVerified: user?.isVerified ?? false,
        hasUnreadNotifications: false,
        onNotificationTap: () {
          if (user == null) {
            AuthGateModal.show(
              context: context,
              title: 'Sign In for Notifications',
              message: 'Sign in to receive trip alerts, rental status updates and exclusive promo deals.',
              onSignIn: () => context.go(AppRoutes.signIn),
              onRegister: () => context.go(AppRoutes.createAccount),
            );
            return;
          }
          context.go(AppRoutes.notificationCenter);
        },
        onProfileTap: () {
          if (user == null) {
            AuthGateModal.show(
              context: context,
              title: 'Sign In to Your Account',
              message: 'Sign in to view your profile, manage documents, and configure your preferences.',
              onSignIn: () => context.go(AppRoutes.signIn),
              onRegister: () => context.go(AppRoutes.createAccount),
            );
            return;
          }
          context.go(AppRoutes.userProfile);
        },
        onSupportTap: () => context.go(AppRoutes.helpSupport),
        onThemeToggle: () {
          final mode = ref.read(appThemeModeProvider);
          ref.read(appThemeModeProvider.notifier).state =
              mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        },
        onLogoutTap: () async {
          if (user != null) {
            await ref.read(userAuthProvider.notifier).signOut();
            if (!mounted) return;
            VelixToast.showSuccess(this.context, 'Signed out successfully.');
          }
          this.context.go(AppRoutes.onboarding);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user == null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C1830), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open_rounded, color: Color(0xFFC84C00), size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guest Explorer Mode',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Sign in to book vehicles, save favorites, and access your wallet.',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.signIn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC84C00),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
            // Location Search Bar
            GestureDetector(
              onTap: () => context.go(AppRoutes.carListing),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFC84C00), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Lekki Phase 1, Lagos',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC84C00),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All', isDark: isDark, textColor: textColor, subtextColor: subtextColor, borderColor: borderColor, icon: Icons.grid_view_rounded),
                  const SizedBox(width: 8),
                  _buildCategoryChip('SUVs', isDark: isDark, textColor: textColor, subtextColor: subtextColor, borderColor: borderColor, imageUrl: CarImageCatalog.mercedesGLE),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Sedans', isDark: isDark, textColor: textColor, subtextColor: subtextColor, borderColor: borderColor, imageUrl: CarImageCatalog.toyotaCamry),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Luxury', isDark: isDark, textColor: textColor, subtextColor: subtextColor, borderColor: borderColor, imageUrl: CarImageCatalog.rangeRoverVelar),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Electric', isDark: isDark, textColor: textColor, subtextColor: subtextColor, borderColor: borderColor, imageUrl: CarImageCatalog.teslaModel3),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.carCategories),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF332014) : const Color(0xFFFDF0E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Text('Categories', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 9, color: Color(0xFFC84C00)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Dynamic Promotional Slideshow Carousel
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: _bannerPageController,
                onPageChanged: (index) {
                  setState(() => _currentBannerIndex = index);
                },
                itemCount: _promoBanners.length,
                itemBuilder: (ctx, index) {
                  final banner = _promoBanners[index];
                  final gradientColors = banner['gradient'] as List<Color>;
                  final accentColor = banner['accent'] as Color;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors.map((c) => c.withValues(alpha: 0.85)).toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(banner['image'] as String),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.65),
                          BlendMode.darken,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  banner['badge'] as String,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  text: banner['title'] as String,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                  children: [
                                    TextSpan(
                                      text: banner['highlight'] as String,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Code: ${banner['code']}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            VelixToast.showSuccess(context, 'Promo code ${banner['code']} activated!');
                            context.go(AppRoutes.carListing);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC84C00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 0,
                          ),
                          child: Text(
                            banner['buttonText'] as String,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Slideshow Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_promoBanners.length, (idx) {
                final isSelected = _currentBannerIndex == idx;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected ? 18 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFC84C00) : (isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),

            // Featured Deals Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Featured Deals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Color(0xFFEF4444), size: 12),
                          SizedBox(width: 2),
                          Text('HOT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.carListing),
                  child: const Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Hero Featured Car
            if (allCars.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  final heroCar = allCars.firstWhere(
                    (c) => c.name.contains('GLE') || c.brand.contains('Mercedes'),
                    orElse: () => allCars.first,
                  );
                  context.go(AppRoutes.carDetail, extra: heroCar);
                },
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: const DecorationImage(
                      image: NetworkImage(CarImageCatalog.featuredHeroBanner),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.85)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC84C00),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('20% OFF', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(allCars.first.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('${allCars.first.category} • ${allCars.first.transmission}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₦${allCars.first.pricePerDay.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const Text('/day', style: TextStyle(fontSize: 9, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Recommended for You Section Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Recommended for ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const Text('You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.carListing),
                  child: const Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Compact Vehicle Grid (Eliminating Stark White Area)
            GridView.builder(
              itemCount: filteredCars.length > 4 ? 4 : filteredCars.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.76,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) => _buildVehicleGridCard(
                filteredCars[index],
                isDark: isDark,
                cardBg: cardBg,
                textColor: textColor,
                subtextColor: subtextColor,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        isPartner: false,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.carListing);
              break;
            case 2:
              if (user == null) {
                AuthGateModal.show(
                  context: context,
                  title: 'Sign In to View Bookings',
                  message: 'Sign in or create an account to view your active rentals, reservation history, and return verifications.',
                  onSignIn: () => context.go(AppRoutes.signIn),
                  onRegister: () => context.go(AppRoutes.createAccount),
                );
                return;
              }
              context.go(AppRoutes.myBookings);
              break;
            case 3:
              context.go(AppRoutes.favorites);
              break;
            case 4:
              if (user == null) {
                AuthGateModal.show(
                  context: context,
                  title: 'Sign In to Access Profile',
                  message: 'Sign in to access your profile settings, payment methods, wallet, and security preferences.',
                  onSignIn: () => context.go(AppRoutes.signIn),
                  onRegister: () => context.go(AppRoutes.createAccount),
                );
                return;
              }
              context.go(AppRoutes.userProfile);
              break;
          }
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    String label, {
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    IconData? icon,
    String? imageUrl,
  }) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC84C00)
              : (isDark ? const Color(0xFF161922) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFC84C00) : borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imageUrl,
                  width: 20,
                  height: 16,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.directions_car,
                    size: 14,
                    color: isSelected ? Colors.white : const Color(0xFFC84C00),
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFFC84C00),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleGridCard(
    CarModel car, {
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.carDetail, extra: car),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 96,
                    width: double.infinity,
                    color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6),
                    child: Image.network(
                      car.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.directions_car, size: 36, color: subtextColor),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1830).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      car.category.toUpperCase(),
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      final currentUser = ref.read(userAuthProvider).user;
                      if (currentUser == null) {
                        AuthGateModal.show(
                          context: context,
                          title: 'Sign In to Save Favorites',
                          message: 'Create an account or sign in to save ${car.name} to your wishlist.',
                          onSignIn: () => context.go(AppRoutes.signIn),
                          onRegister: () => context.go(AppRoutes.createAccount),
                        );
                        return;
                      }
                      ref.read(vehicleRepositoryProvider).toggleFavorite(car.id);
                    },
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: cardBg.withValues(alpha: 0.9),
                      child: Icon(
                        car.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 13,
                        color: const Color(0xFFC84C00),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    car.name,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${car.transmission} • ${car.fuelType}',
                    style: TextStyle(fontSize: 9, color: subtextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 11, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(car.rating.toStringAsFixed(1), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                      Text(' (${car.reviewsCount})', style: TextStyle(fontSize: 8, color: subtextColor)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '₦${(car.pricePerDay / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                          children: [
                            TextSpan(text: '/day', style: TextStyle(fontSize: 8, color: subtextColor)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC84C00),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Book', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
