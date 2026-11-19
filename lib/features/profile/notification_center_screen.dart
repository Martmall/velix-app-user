import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

import 'package:velix_core/theme/velix_palette.dart';
class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  String _selectedCategory = 'All';
  bool _hasUnread = false;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);
    final bookings = bookingsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: VelixPalette.paper,
      appBar: AppBar(
        backgroundColor: VelixPalette.paper,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: VelixPalette.stone,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: VelixPalette.ink, size: 16),
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
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink),
        ),
        actions: [
          if (bookings.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _hasUnread = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read.')),
                );
              },
              child: const Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: bookings.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: VelixPalette.stone,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none, size: 40, color: VelixPalette.lineStrong),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No notifications yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When you make a booking, complete payments, or receive trip updates, notifications will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: VelixPalette.muted, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.carListing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelixPalette.copper,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Browse Cars', style: TextStyle(color: VelixPalette.paper, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Bookings'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Payments'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('RECENT UPDATES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelixPalette.muted, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ...bookings.map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildNotificationItem(
                        icon: Icons.directions_car,
                        iconBg: VelixPalette.copperSoft,
                        iconColor: VelixPalette.copper,
                        title: 'Booking #${b.id}: ${b.carName}',
                        subtitle: 'Status: ${b.status.name.toUpperCase()} • Total: ₦${b.totalPrice.toStringAsFixed(0)}',
                        time: 'Active',
                        isUnread: _hasUnread,
                        onTap: () => context.go(AppRoutes.myBookings),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: VelixPalette.ink,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.calendar_month_outlined, 'Bookings', false, () => context.go(AppRoutes.myBookings)),
            _buildNavItem(Icons.search, 'Search', false, () => context.go(AppRoutes.carListing)),
            _buildNavItem(Icons.home_filled, 'Home', false, () => context.go(AppRoutes.home)),
            _buildNavItem(Icons.notifications, 'Alerts', true, () => context.go(AppRoutes.notificationCenter)),
            _buildNavItem(Icons.person_outline, 'Profile', false, () => context.go(AppRoutes.userProfile)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: VelixPalette.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelixPalette.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                      Row(
                        children: [
                          Text(time, style: const TextStyle(fontSize: 10, color: VelixPalette.lineStrong)),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            const CircleAvatar(radius: 3.5, backgroundColor: VelixPalette.copper),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: VelixPalette.muted, height: 1.4)),
                ],
              ),
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
              color: isActive ? VelixPalette.copper : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: VelixPalette.paper, size: 18),
          ),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
        ],
      ),
    );
  }
}
