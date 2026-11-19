import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _selectedCategory = 'All Saved';

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: VelixPalette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VelixPalette.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Filter Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
              const SizedBox(height: 16),
              ...['All Saved', 'SUVs', 'Sedans', 'Luxury', 'Economy'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return ListTile(
                  title: Text(cat, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: VelixPalette.ink)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: VelixPalette.copper) : null,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final allCars = vehiclesAsync.when(
      data: (list) => list,
      loading: () => <CarModel>[],
      error: (_, __) => <CarModel>[],
    );
    final allFavorites = allCars.where((c) => c.isFavorite).toList();

    final filteredCars = allFavorites.where((c) {
      if (_selectedCategory == 'SUVs') return c.category == 'SUV';
      if (_selectedCategory == 'Sedans') return c.category == 'Sedan';
      if (_selectedCategory == 'Luxury') return c.category == 'Luxury';
      if (_selectedCategory == 'Economy') return c.category == 'Economy';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: VelixPalette.paper,
      appBar: AppBar(
        backgroundColor: VelixPalette.paper,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.home),
        ),
        title: const Text(
          'Saved Cars',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Text('${allFavorites.length} Cars', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VelixPalette.stone,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: VelixPalette.ink, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryFilter('All Saved'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('SUVs'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Sedans'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Luxury'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Economy'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (filteredCars.isNotEmpty) ...[
              // Dynamic 2-Column Saved Cars Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final car = filteredCars[index];
                  return _buildDynamicSavedCard(car);
                },
              ),
            ] else ...[
              // Dashed Empty State Placeholder Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: VelixPalette.stone,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: VelixPalette.lineStrong, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.favorite_border_rounded, size: 48, color: VelixPalette.copper),
                    const SizedBox(height: 10),
                    Text(
                      ref.watch(userAuthProvider).user == null
                          ? 'Sign in to access Saved Cars'
                          : 'No saved cars yet',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ref.watch(userAuthProvider).user == null
                          ? 'Create a free account or sign in to save and compare your favorite vehicles.'
                          : 'Explore cars and tap the heart icon to save',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: VelixPalette.muted),
                    ),
                    const SizedBox(height: 14),
                    if (ref.watch(userAuthProvider).user == null)
                      ElevatedButton(
                        onPressed: () => context.go(AppRoutes.signIn),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelixPalette.copper,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Sign In / Register', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
                      )
                    else
                      OutlinedButton(
                        onPressed: () => context.go(AppRoutes.carListing),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: VelixPalette.copper),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Start Exploring', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        isPartner: false,
        onTap: (i) {
          const routes = [
            AppRoutes.home,
            AppRoutes.carListing,
            AppRoutes.myBookings,
            AppRoutes.favorites,
            AppRoutes.userProfile,
          ];
          if (i != 3) context.go(routes[i]);
        },
      ),
    );
  }

  Widget _buildCategoryFilter(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? VelixPalette.ink : VelixPalette.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? VelixPalette.ink : VelixPalette.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? VelixPalette.paper : VelixPalette.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSavedCard(CarModel car) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.carDetail, extra: car),
      child: Container(
        decoration: BoxDecoration(
          color: VelixPalette.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelixPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    car.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: VelixPalette.stone,
                      child: const Center(child: Icon(Icons.directions_car, size: 48, color: VelixPalette.lineStrong)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: VelixPalette.ink,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(car.category, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(vehicleRepositoryProvider).toggleFavorite(car.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${car.name} updated in favorites.')),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: VelixPalette.paper,
                      child: Icon(Icons.favorite, size: 14, color: VelixPalette.claim),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelixPalette.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(car.brand, style: const TextStyle(fontSize: 10, color: VelixPalette.muted)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 10, color: VelixPalette.copper),
                      const SizedBox(width: 2),
                      Expanded(child: Text(car.location, style: const TextStyle(fontSize: 9, color: VelixPalette.muted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 10, color: VelixPalette.brass),
                      const SizedBox(width: 2),
                      Text(car.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                      Text(' (${car.reviewsCount})', style: const TextStyle(fontSize: 9, color: VelixPalette.lineStrong)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${car.pricePerDay.toStringAsFixed(0)}/d',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: VelixPalette.copper,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Rent', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
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
