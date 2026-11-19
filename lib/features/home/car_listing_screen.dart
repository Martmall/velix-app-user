import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class CarListingScreen extends ConsumerStatefulWidget {
  const CarListingScreen({super.key});

  @override
  ConsumerState<CarListingScreen> createState() => _CarListingScreenState();
}

class _CarListingScreenState extends ConsumerState<CarListingScreen> {
  String _selectedSort = 'Sort By ∨';

  void _showFilterSheet(BuildContext context) {
    String filterTransmission = 'All';
    String filterType = 'All';
    RangeValues priceRange = const RangeValues(25000, 150000);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VelixPalette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Vehicles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            filterTransmission = 'All';
                            filterType = 'All';
                            priceRange = const RangeValues(25000, 150000);
                          });
                        },
                        child: const Text('Reset', style: TextStyle(color: VelixPalette.copper, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Vehicle Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'SUV', 'Sedan', 'Luxury'].map((t) {
                      final isSelected = filterType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        selectedColor: VelixPalette.copper,
                        labelStyle: TextStyle(color: isSelected ? VelixPalette.paper : VelixPalette.muted, fontWeight: FontWeight.bold),
                        onSelected: (_) => setModalState(() => filterType = t),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Transmission', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Automatic', 'Manual'].map((tr) {
                      final isSelected = filterTransmission == tr;
                      return ChoiceChip(
                        label: Text(tr),
                        selected: isSelected,
                        selectedColor: VelixPalette.copper,
                        labelStyle: TextStyle(color: isSelected ? VelixPalette.paper : VelixPalette.muted, fontWeight: FontWeight.bold),
                        onSelected: (_) => setModalState(() => filterTransmission = tr),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price Range / Day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                      Text('₦${priceRange.start.round()} - ₦${priceRange.end.round()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                    ],
                  ),
                  RangeSlider(
                    values: priceRange,
                    min: 15000,
                    max: 250000,
                    divisions: 47,
                    activeColor: VelixPalette.copper,
                    onChanged: (vals) => setModalState(() => priceRange = vals),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelixPalette.copper,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedSort = filterType != 'All' ? filterType : 'Filtered';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Applied filters: $filterType • $filterTransmission • ₦${priceRange.start.round()} - ₦${priceRange.end.round()}')),
                        );
                      },
                      child: const Text('Apply Filters', style: TextStyle(color: VelixPalette.paper, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelixPalette.paper,
      appBar: AppBar(
        backgroundColor: VelixPalette.paper,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.home),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: VelixPalette.stone,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.location_on, color: VelixPalette.copper, size: 16),
              SizedBox(width: 6),
              Text(
                'Lagos, Ikeja',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink),
              ),
              Spacer(),
              Text(
                'Jun 12-18',
                style: TextStyle(fontSize: 10, color: VelixPalette.muted),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VelixPalette.copper,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: VelixPalette.paper, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort & Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Sort By ∨', _selectedSort == 'Sort By ∨'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Price ∨', _selectedSort == 'Price ∨'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Transmission ∨', _selectedSort == 'Transmission ∨'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Seats ∨', _selectedSort == 'Seats ∨'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                final vehiclesAsync = ref.watch(vehicleListProvider);
                final cars = vehiclesAsync.when(
                  data: (list) => list,
                  loading: () => <CarModel>[],
                  error: (_, __) => <CarModel>[],
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '${cars.length} ',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.copper),
                            children: const [
                              TextSpan(text: 'Cars Available', style: TextStyle(color: VelixPalette.ink)),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.swap_vert, size: 16, color: VelixPalette.muted),
                            SizedBox(width: 4),
                            Text('Recommended', style: TextStyle(fontSize: 12, color: VelixPalette.muted)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...cars.map((car) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildVehicleListingCard(car),
                    )),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        isPartner: false,
        onTap: (i) {
          const routes = [
            AppRoutes.home,
            AppRoutes.carListing,
            AppRoutes.myBookings,
            AppRoutes.favorites,
            AppRoutes.userProfile,
          ];
          if (i != 1) context.go(routes[i]);
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSort = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? VelixPalette.copper : VelixPalette.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? VelixPalette.copper : VelixPalette.line),
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

  Widget _buildVehicleListingCard(CarModel car) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.carDetail, extra: car),
      child: Container(
        decoration: BoxDecoration(
          color: VelixPalette.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: VelixPalette.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Area with Real Vehicle Photo
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 135,
                    width: double.infinity,
                    color: VelixPalette.stone,
                    child: Image.network(
                      car.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.directions_car, size: 80, color: VelixPalette.lineStrong),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: car.isAvailable ? VelixPalette.goSoft : VelixPalette.claimSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: car.isAvailable ? VelixPalette.go : VelixPalette.claim,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          car.isAvailable ? 'Available' : 'Booked',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: car.isAvailable ? VelixPalette.go : VelixPalette.claim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(vehicleRepositoryProvider).toggleFavorite(car.id);
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: VelixPalette.paper,
                      child: Icon(
                        car.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: VelixPalette.claim,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          car.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '₦${car.pricePerDay.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.copper),
                          children: const [
                            TextSpan(text: '\nper day', style: TextStyle(fontSize: 10, color: VelixPalette.muted)),
                          ],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  Text('${car.category} • ${car.brand}', style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: VelixPalette.brass),
                      const SizedBox(width: 4),
                      Text(car.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                      Text(' (${car.reviewsCount})', style: const TextStyle(fontSize: 11, color: VelixPalette.lineStrong)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 14, color: VelixPalette.copper),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          car.location,
                          style: const TextStyle(fontSize: 11, color: VelixPalette.muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Spec Chips
                  Row(
                    children: [
                      _buildSpecChip('⚙ ${car.transmission}'),
                      const SizedBox(width: 6),
                      _buildSpecChip('👥 ${car.seats} Seats'),
                      const SizedBox(width: 6),
                      _buildSpecChip('⛽ ${car.fuelType}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go(AppRoutes.carDetail, extra: car),
                          icon: const Text('Book Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
                          label: const Icon(Icons.arrow_forward, size: 16, color: VelixPalette.paper),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VelixPalette.copper,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: VelixPalette.stone,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.more_horiz, color: VelixPalette.muted, size: 20),
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

  Widget _buildSpecChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: VelixPalette.stone,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
    );
  }
}
