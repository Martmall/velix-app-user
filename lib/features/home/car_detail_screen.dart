import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class CarDetailScreen extends ConsumerStatefulWidget {
  final CarModel? car;

  const CarDetailScreen({super.key, this.car});

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  int _selectedGalleryIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.car?.isFavorite ?? false;
  }

  String? _extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url.trim());
    return match?.group(1);
  }

  void _showReviewsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VelixPalette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                controller: controller,
                children: [
                  const SizedBox(height: 12),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Verified Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: VelixPalette.ink,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: VelixPalette.brass, size: 18),
                          SizedBox(width: 4),
                          Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(' (126 reviews)', style: TextStyle(color: VelixPalette.muted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReviewCard('Adeola O.', '2 days ago', 'Car was in immaculate condition! Pickup in Lekki was seamless and host was very professional.', '14'),
                  const SizedBox(height: 12),
                  _buildReviewCard('Chinedu E.', '1 week ago', 'AC was chilling, engine responsive and clean interior. Will definitely book again for my next trip!', '9'),
                  const SizedBox(height: 12),
                  _buildReviewCard('Fatima S.', '2 weeks ago', 'Smooth ride all through Abuja. Highly recommended host!', '6'),
                  const SizedBox(height: 12),
                  _buildReviewCard('Babatunde R.', '3 weeks ago', 'Top tier service. Everything worked as advertised.', '4'),
                  const SizedBox(height: 24),
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
    final draft = ref.watch(bookingDraftProvider);
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final car = widget.car ?? draft.selectedCar;
    if (car == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: vehiclesAsync.isLoading
              ? const CircularProgressIndicator()
              : const Text('This vehicle is no longer available.'),
        ),
      );
    }

    final gallery = car.galleryImages.isNotEmpty
        ? car.galleryImages
        : CarImageCatalog.getGalleryForCar(car.name, category: car.category);

    final currentImage = gallery.isNotEmpty && _selectedGalleryIndex < gallery.length
        ? gallery[_selectedGalleryIndex]
        : car.imageUrl;

    return Scaffold(
      backgroundColor: VelixPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Vehicle Banner & Controls
                    Stack(
                      children: [
                        Container(
                          height: 260,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: VelixPalette.stone,
                          ),
                          child: Image.network(
                            currentImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: VelixPalette.stone,
                              child: const Center(
                                child: Icon(Icons.directions_car_filled, size: 100, color: VelixPalette.lineStrong),
                              ),
                            ),
                          ),
                        ),
                        // Dark Gradient Overlay for readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.45),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: CircleAvatar(
                            backgroundColor: VelixPalette.paper,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: VelixPalette.ink),
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.carListing);
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: VelixPalette.paper,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.share, size: 16, color: VelixPalette.ink),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Vehicle link for ${car.name} copied to clipboard!')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor: VelixPalette.paper,
                                radius: 18,
                                child: IconButton(
                                  icon: Icon(
                                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                    color: VelixPalette.claim,
                                  ),
                                  onPressed: () {
                                    final user = ref.read(userAuthProvider).user;
                                    if (user == null) {
                                      AuthGateModal.show(
                                        context: context,
                                        title: 'Sign In to Save Favorites',
                                        message: 'Create an account or sign in to save ${car.name} to your wishlist.',
                                        onSignIn: () => context.go(AppRoutes.signIn),
                                        onRegister: () => context.go(AppRoutes.createAccount),
                                      );
                                      return;
                                    }
                                    setState(() => _isFavorite = !_isFavorite);
                                    ref.read(vehicleRepositoryProvider).toggleFavorite(car.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_isFavorite ? 'Added to Saved Cars!' : 'Removed from Saved Cars.'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Category Badge
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: VelixPalette.copper,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              car.category.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelixPalette.paper),
                            ),
                          ),
                        ),
                        // Photo Count Badge
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.photo_library, color: VelixPalette.paper, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${_selectedGalleryIndex + 1}/${gallery.length}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.paper),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Multi-Angle Thumbnail Gallery Strip
                    if (gallery.length > 1) ...[
                      Container(
                        height: 72,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: VelixPalette.stone,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: gallery.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, idx) {
                            final isSelected = _selectedGalleryIndex == idx;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedGalleryIndex = idx),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? VelixPalette.copper : VelixPalette.line,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    gallery[idx],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.directions_car, size: 20, color: VelixPalette.lineStrong),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  car.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: car.isAvailable ? VelixPalette.goSoft : VelixPalette.claimSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  car.isAvailable ? 'Available' : 'Booked',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: car.isAvailable ? VelixPalette.go : VelixPalette.claim,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: VelixPalette.brass),
                              const SizedBox(width: 4),
                              Text(car.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                              Text(' (${car.reviewsCount} reviews) • ', style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
                              const Icon(Icons.location_on, size: 14, color: VelixPalette.copper),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  car.location,
                                  style: const TextStyle(fontSize: 11, color: VelixPalette.muted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text.rich(
                            TextSpan(
                              text: '₦${car.pricePerDay.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: VelixPalette.copper),
                              children: const [
                                TextSpan(text: ' /per day', style: TextStyle(fontSize: 13, color: VelixPalette.muted)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Spec Badges Row with Material Icons (No Emojis)
                          Row(
                            children: [
                              _buildSpecBadge(car.transmission, icon: Icons.settings_outlined),
                              const SizedBox(width: 6),
                              _buildSpecBadge(car.fuelType, icon: Icons.local_gas_station_outlined),
                              const SizedBox(width: 6),
                              _buildSpecBadge('${car.seats} Seats', icon: Icons.people_outline),
                              const SizedBox(width: 6),
                              _buildSpecBadge('45k km', icon: Icons.speed_outlined),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Car Host Section Card with Working Live Chat
                          const Text('Car Host', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: VelixPalette.stone,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: VelixPalette.line),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: car.partnerAvatar.isNotEmpty
                                      ? NetworkImage(car.partnerAvatar)
                                      : null,
                                  backgroundColor: VelixPalette.copper,
                                  child: car.partnerAvatar.isEmpty
                                      ? Text(
                                          car.partnerName.isNotEmpty ? car.partnerName[0] : 'V',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            car.partnerName,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, size: 14, color: VelixPalette.copper),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      const Text('Verified Fleet Partner • ★ 4.98', style: TextStyle(fontSize: 10, color: VelixPalette.muted)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go(
                                      AppRoutes.liveChat,
                                      extra: {
                                        'hostName': car.partnerName.isNotEmpty ? car.partnerName : 'Car Host',
                                        'carName': car.name,
                                        'partnerAvatar': car.partnerAvatar,
                                        'isHost': true,
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: VelixPalette.copperSoft,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: VelixPalette.copperSoft),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.chat_bubble, color: VelixPalette.copper, size: 16),
                                        SizedBox(width: 6),
                                        Text('Live Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Vehicle Specifications Grid
                          const Text('Specifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.8,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: [
                              _buildSpecTile(Icons.speed, 'Top Speed', '240 km/h'),
                              _buildSpecTile(Icons.local_gas_station, 'Fuel Economy', '9.4 L/100km'),
                              _buildSpecTile(Icons.settings, 'Transmission', car.transmission),
                              _buildSpecTile(Icons.airline_seat_recline_normal, 'Seating', '${car.seats} Adult Seats'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Vehicle Features & Amenities
                          const Text('Features & Amenities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (car.features.isNotEmpty
                                    ? car.features
                                    : ['Bluetooth', 'GPS Navigation', 'Rear Camera', 'Air Conditioning', 'Leather Seats'])
                                .map((feature) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: VelixPalette.stone,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, size: 14, color: VelixPalette.go),
                                    const SizedBox(width: 6),
                                    Text(feature, style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          if (car.videoUrl != null && car.videoUrl!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: VelixPalette.claim.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.play_circle_fill, color: VelixPalette.claim, size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text('Vehicle Video Tour', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: VelixPalette.nightPaper,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: Text(
                                      '${car.name} Video Tour',
                                      style: const TextStyle(color: VelixPalette.paper, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            'https://img.youtube.com/vi/${_extractYoutubeId(car.videoUrl!) ?? ""}/hqdefault.jpg',
                                            errorBuilder: (_, __, ___) => Container(
                                              height: 120,
                                              color: Colors.black26,
                                              child: const Center(child: Icon(Icons.play_circle, color: VelixPalette.paper, size: 48)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Watch live video on YouTube: ${car.videoUrl}',
                                          style: const TextStyle(color: VelixPalette.lineStrong, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Close', style: TextStyle(color: VelixPalette.copper)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://img.youtube.com/vi/${_extractYoutubeId(car.videoUrl!) ?? ""}/hqdefault.jpg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: VelixPalette.claim,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: VelixPalette.claim.withValues(alpha: 0.5),
                                              blurRadius: 16,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.play_arrow, color: VelixPalette.paper, size: 30),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 14,
                                      right: 14,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.videocam, color: VelixPalette.paper, size: 14),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Watch ${car.name} Video Preview',
                                              style: const TextStyle(color: VelixPalette.paper, fontSize: 12, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (car.unavailableDates.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: VelixPalette.amberSoft,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: VelixPalette.amberSoft),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_busy, color: VelixPalette.onAmberSoft, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Notice: ${car.unavailableDates.length} booked dates reserved on calendar.',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.onAmberSoft),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Reviews Header with view all
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Customer Reviews', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                              GestureDetector(
                                onTap: () => _showReviewsModal(context),
                                child: const Text(
                                  'View all 126 reviews',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.copper),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildReviewCard('Adeola O.', '2 days ago', 'Car was in immaculate condition! Pickup in Lekki was seamless and host was very professional.', '14'),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: VelixPalette.paper,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Price', style: TextStyle(fontSize: 10, color: VelixPalette.muted)),
                      Text.rich(
                        TextSpan(
                          text: '₦${car.pricePerDay.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                          children: const [
                            TextSpan(text: ' /day', style: TextStyle(fontSize: 11, color: VelixPalette.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final user = ref.read(userAuthProvider).user;
                      if (user == null) {
                        AuthGateModal.show(
                          context: context,
                          title: 'Sign In to Book Vehicle',
                          message: 'Create an account or sign in to complete your reservation for ${car.name}, manage trip documents, and access instant customer support.',
                          onSignIn: () => context.go(AppRoutes.signIn),
                          onRegister: () => context.go(AppRoutes.createAccount),
                        );
                        return;
                      }
                      ref.read(bookingDraftProvider.notifier).selectCar(car);
                      context.go(AppRoutes.bookingDateLocation);
                    },
                    icon: const Text('Book Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
                    label: const Icon(Icons.arrow_forward, size: 16, color: VelixPalette.paper),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelixPalette.copper,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecBadge(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: VelixPalette.stone,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: VelixPalette.muted),
            const SizedBox(width: 4),
          ],
          Text(label, style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
        ],
      ),
    );
  }

  Widget _buildSpecTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: VelixPalette.stone,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VelixPalette.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: VelixPalette.copper, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: VelixPalette.muted)),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildReviewCard(String name, String date, String comment, String helpful) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VelixPalette.stone,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VelixPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 14, backgroundColor: Color(0xFFDB2777), child: Text('AO', style: TextStyle(fontSize: 9, color: VelixPalette.paper))),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                      Text(date, style: const TextStyle(fontSize: 10, color: VelixPalette.muted)),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (_) => const Icon(Icons.star, size: 10, color: VelixPalette.brass)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 11, color: VelixPalette.muted, height: 1.4)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.thumb_up_alt_outlined, size: 12, color: VelixPalette.muted),
              const SizedBox(width: 4),
              Text('Helpful ($helpful)', style: const TextStyle(fontSize: 10, color: VelixPalette.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
