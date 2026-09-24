import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  int _selectedTab = 0; // 0: Active, 1: Completed, 2: Cancelled

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    final bookingsAsync = ref.watch(userBookingsProvider);
    final allBookings = bookingsAsync.valueOrNull ?? [];

    final activeBookings = allBookings.where((b) =>
        b.status == BookingStatus.active ||
        b.status == BookingStatus.confirmed ||
        b.status == BookingStatus.pending).toList();

    final completedBookings = allBookings.where((b) =>
        b.status == BookingStatus.completed).toList();

    final cancelledBookings = allBookings.where((b) =>
        b.status == BookingStatus.cancelled).toList();

    List<BookingModel> displayedBookings;
    if (_selectedTab == 0) {
      displayedBookings = activeBookings;
    } else if (_selectedTab == 1) {
      displayedBookings = completedBookings;
    } else {
      displayedBookings = cancelledBookings;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.home),
        ),
        title: Text(
          'My Bookings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status Filter Tabs Row
          Container(
            color: cardBg,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                _buildFilterTab(0, 'Active', activeBookings.length.toString(), isDark),
                const SizedBox(width: 16),
                _buildFilterTab(1, 'Completed', completedBookings.length.toString(), isDark),
                const SizedBox(width: 16),
                _buildFilterTab(2, 'Cancelled', cancelledBookings.length.toString(), isDark),
              ],
            ),
          ),
          Expanded(
            child: displayedBookings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.calendar_today_outlined, size: 36, color: Color(0xFFC84C00)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _selectedTab == 0
                                ? 'No Active Bookings'
                                : (_selectedTab == 1 ? 'No Completed Trips' : 'No Cancelled Bookings'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTab == 0
                                ? 'You do not have any ongoing vehicle reservations. Choose a premium car and hit the road!'
                                : 'Your trip history for this section will appear here once finalized.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: subtextColor, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () => context.go(AppRoutes.carListing),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC84C00),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Explore Cars', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: displayedBookings.length,
                    itemBuilder: (context, index) {
                      final booking = displayedBookings[index];
                      return _buildBookingCard(booking, isDark, cardBg, textColor, subtextColor, borderColor);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        isPartner: false,
        onTap: (i) {
          const routes = [
            AppRoutes.home,
            AppRoutes.carListing,
            AppRoutes.myBookings,
            AppRoutes.favorites,
            AppRoutes.userProfile,
          ];
          if (i != 2) context.go(routes[i]);
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BookingModel booking,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.bookingDetail, extra: booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          if (booking.carImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                booking.carImage,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                  child: Center(
                    child: Icon(Icons.directions_car, size: 60, color: subtextColor),
                  ),
                ),
              ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.carName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.id,
                              style: TextStyle(fontSize: 10, color: subtextColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₦${booking.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                        ),
                        Text('total', style: TextStyle(fontSize: 9, color: subtextColor)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PICKUP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: subtextColor)),
                          Text(
                            '${booking.startDate.day}/${booking.startDate.month}/${booking.startDate.year}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${booking.endDate.difference(booking.startDate).inDays} days',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('RETURN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: subtextColor)),
                          Text(
                            '${booking.endDate.day}/${booking.endDate.month}/${booking.endDate.year}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildFilterTab(int index, String label, String count, bool isDark) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFC84C00) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFC84C00) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 9,
              backgroundColor: isSelected
                  ? const Color(0xFFC84C00)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
