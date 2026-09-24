import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/routes.dart';

class CarCategoriesScreen extends StatefulWidget {
  const CarCategoriesScreen({super.key});

  @override
  State<CarCategoriesScreen> createState() => _CarCategoriesScreenState();
}

class _CarCategoriesScreenState extends State<CarCategoriesScreen> {
  String _selectedBrand = 'Toyota';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0C1830), size: 16),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
        ),
        title: const Text(
          'Browse by Category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Color(0xFF0C1830), size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Logos Horizontal Scroll Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBrandTile('Toyota', _selectedBrand == 'Toyota'),
                  const SizedBox(width: 14),
                  _buildBrandTile('Mercedes', _selectedBrand == 'Mercedes'),
                  const SizedBox(width: 14),
                  _buildBrandTile('BMW', _selectedBrand == 'BMW'),
                  const SizedBox(width: 14),
                  _buildBrandTile('Lexus', _selectedBrand == 'Lexus'),
                  const SizedBox(width: 14),
                  _buildBrandTile('Honda', _selectedBrand == 'Honda'),
                  const SizedBox(width: 14),
                  _buildBrandTile('Hyundai', _selectedBrand == 'Hyundai'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.carListing),
                  child: const Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 2-Column Category Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _buildCategoryCard(
                  title: 'Economy Cars',
                  count: '14 Cars Available',
                  icon: Icons.directions_car,
                  bgColor: const Color(0xFF0C1830),
                  textColor: Colors.white,
                  btnBg: Colors.white.withValues(alpha: 0.1),
                ),
                _buildCategoryCard(
                  title: 'SUVs & 4x4',
                  count: '18 Cars Available',
                  icon: Icons.airport_shuttle,
                  bgColor: const Color(0xFF0C1830),
                  textColor: Colors.white,
                  btnBg: Colors.white.withValues(alpha: 0.1),
                ),
                _buildCategoryCard(
                  title: 'Luxury Cars',
                  count: '9 Cars Available',
                  icon: Icons.star,
                  bgColor: const Color(0xFFC84C00), // Solid Terracotta Featured Card
                  textColor: Colors.white,
                  badge: '✦ FEATURED',
                  btnBg: Colors.white.withValues(alpha: 0.2),
                ),
                _buildCategoryCard(
                  title: 'Sports Cars',
                  count: '7 Cars Available',
                  icon: Icons.speed,
                  bgColor: const Color(0xFF0C1830),
                  textColor: Colors.white,
                  btnBg: Colors.white.withValues(alpha: 0.1),
                ),
                _buildCategoryCard(
                  title: 'Family Vans',
                  count: '12 Cars Available',
                  icon: Icons.directions_bus_outlined,
                  bgColor: Colors.white,
                  textColor: const Color(0xFF0C1830),
                  isBordered: true,
                  btnBg: const Color(0xFFFDF0E9),
                  iconColor: const Color(0xFFC84C00),
                ),
                _buildCategoryCard(
                  title: 'Executive',
                  count: '11 Cars Available',
                  icon: Icons.business_center,
                  bgColor: const Color(0xFF0C1830),
                  textColor: Colors.white,
                  btnBg: Colors.white.withValues(alpha: 0.1),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Color(0xFF0C1830),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.calendar_month_outlined, 'Bookings', false, () => context.go(AppRoutes.myBookings)),
            _buildNavItem(Icons.grid_view_rounded, 'Browse', true, () => context.go(AppRoutes.carCategories)),
            _buildNavItem(Icons.home_filled, 'Home', false, () => context.go(AppRoutes.home)),
            _buildNavItem(Icons.favorite_border, 'Saved', false, () => context.go(AppRoutes.favorites)),
            _buildNavItem(Icons.person_outline, 'Profile', false, () => context.go(AppRoutes.userProfile)),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandTile(String name, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedBrand = name),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFF3F4F6),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.directions_car_filled,
                color: isSelected ? const Color(0xFFC84C00) : const Color(0xFF6B7280),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFC84C00) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    Color? iconColor,
    String? badge,
    bool isBordered = false,
    required Color btnBg,
  }) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.carListing),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: isBordered ? Border.all(color: const Color(0xFFE5E7EB)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: btnBg,
                      child: Icon(Icons.arrow_forward, size: 12, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(count, style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFC84C00) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
        ],
      ),
    );
  }
}
