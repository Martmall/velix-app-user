import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/routes.dart';

class DevPreviewScreen extends StatefulWidget {
  const DevPreviewScreen({super.key});

  @override
  State<DevPreviewScreen> createState() => _DevPreviewScreenState();
}

class _DevPreviewScreenState extends State<DevPreviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  String _selectedCategory = 'ALL';

  final List<Map<String, dynamic>> _sections = [
    {
      'id': 'AUTH',
      'category': '1. ONBOARDING & AUTHENTICATION',
      'icon': Icons.security,
      'screens': [
        {'title': '01. Welcome Screen', 'route': AppRoutes.welcome, 'icon': Icons.handshake_outlined},
        {'title': '02. Onboarding Screen', 'route': AppRoutes.onboarding, 'icon': Icons.swipe},
        {'title': '03. Sign In Page', 'route': AppRoutes.signIn, 'icon': Icons.login},
        {'title': '04. Create Account', 'route': AppRoutes.createAccount, 'icon': Icons.person_add},
        {'title': '05. OTP Verification Page', 'route': AppRoutes.otpVerification, 'icon': Icons.pin},
        {'title': '06. Set Up Page', 'route': AppRoutes.setUp, 'icon': Icons.badge},
        {'title': '07. Identity Verification (KYC)', 'route': AppRoutes.identityVerification, 'icon': Icons.verified_user},
      ]
    },
    {
      'id': 'BOOKING',
      'category': '2. HOME DISCOVERY & VEHICLE BOOKING',
      'icon': Icons.explore,
      'screens': [
        {'title': '08. Home Dashboard', 'route': AppRoutes.home, 'icon': Icons.dashboard},
        {'title': '09. Car Categories Page', 'route': AppRoutes.carCategories, 'icon': Icons.grid_view},
        {'title': '10. Car Listing Page', 'route': AppRoutes.carListing, 'icon': Icons.directions_car},
        {'title': '11. Favorites & Wishlists', 'route': AppRoutes.favorites, 'icon': Icons.favorite},
        {'title': '12. Car Detail Page', 'route': AppRoutes.carDetail, 'icon': Icons.info_outline},
        {'title': '13. Booking Flow - Date & Location', 'route': AppRoutes.bookingDateLocation, 'icon': Icons.calendar_month},
        {'title': '14. Booking Flow - Add-ons & Summary', 'route': AppRoutes.bookingSummary, 'icon': Icons.receipt_long},
        {'title': '15a. Payment Screen (Card)', 'route': AppRoutes.paymentCard, 'icon': Icons.credit_card},
        {'title': '15b. Payment Screen (Bank Transfer)', 'route': AppRoutes.paymentBank, 'icon': Icons.account_balance},
        {'title': '15c. Payment Screen (Wallet)', 'route': AppRoutes.paymentWallet, 'icon': Icons.account_balance_wallet},
        {'title': '16. OTP Payment Confirmation', 'route': AppRoutes.paymentOtp, 'icon': Icons.shield},
        {'title': '17. Booking Confirmation', 'route': AppRoutes.bookingConfirmation, 'icon': Icons.check_circle_outline},
        {'title': '17b. Booking Detail View', 'route': AppRoutes.bookingDetail, 'icon': Icons.article_outlined},
      ]
    },
    {
      'id': 'TRIP',
      'category': '3. TRIP UPDATES & KEYLESS REMOTE ACCESS',
      'icon': Icons.key_outlined,
      'screens': [
        {'title': '18. Trip Updates & Live Map', 'route': AppRoutes.tripUpdates, 'icon': Icons.map},
        {'title': '19. My Bookings', 'route': AppRoutes.myBookings, 'icon': Icons.bookmark_border},
        {'title': '20. Vehicle Access (Keyless Remote)', 'route': AppRoutes.vehicleAccess, 'icon': Icons.lock_open},
        {'title': '21. Vehicle Secured Page', 'route': AppRoutes.vehicleSecured, 'icon': Icons.verified},
        {'title': '22. Return Vehicle Checklist', 'route': AppRoutes.returnVehicle, 'icon': Icons.assignment_return},
        {'title': '23. Car Returned Successfully', 'route': AppRoutes.carReturnedSuccess, 'icon': Icons.task_alt},
        {'title': '24. Leave a Review', 'route': AppRoutes.leaveReview, 'icon': Icons.rate_review},
      ]
    },
    {
      'id': 'PROFILE',
      'category': '4. PROFILE, SUPPORT & MESSAGING',
      'icon': Icons.person_outline,
      'screens': [
        {'title': '25. User Profile & Settings', 'route': AppRoutes.userProfile, 'icon': Icons.person},
        {'title': '27. Notification Center', 'route': AppRoutes.notificationCenter, 'icon': Icons.notifications},
        {'title': '28. Live Chat Support', 'route': AppRoutes.liveChat, 'icon': Icons.chat},
        {'title': '29. Help & Support FAQs', 'route': AppRoutes.helpSupport, 'icon': Icons.help_outline},
        {'title': '30. Submit Support Ticket', 'route': AppRoutes.submitTicket, 'icon': Icons.confirmation_number_outlined},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1830),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1830),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Velix User App — Developer Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: const Text(
                '32 Screens Verified',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter / Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filter = val.toLowerCase()),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search 32 screens by name or route...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
            ),
          ),
          // Category Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All Screens'),
                const SizedBox(width: 8),
                _buildFilterChip('AUTH', '1. Auth & KYC'),
                const SizedBox(width: 8),
                _buildFilterChip('BOOKING', '2. Discovery & Booking'),
                const SizedBox(width: 8),
                _buildFilterChip('TRIP', '3. Trip & Keyless'),
                const SizedBox(width: 8),
                _buildFilterChip('PROFILE', '4. Profile & Support'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _sections.length,
              itemBuilder: (context, sectionIdx) {
                final section = _sections[sectionIdx];
                final sectionId = section['id'] as String;

                if (_selectedCategory != 'ALL' && _selectedCategory != sectionId) {
                  return const SizedBox.shrink();
                }

                final List<Map<String, dynamic>> rawScreens = section['screens'];
                final filteredScreens = rawScreens.where((s) {
                  final title = (s['title'] as String).toLowerCase();
                  final route = (s['route'] as String).toLowerCase();
                  return title.contains(_filter) || route.contains(_filter);
                }).toList();

                if (filteredScreens.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Row(
                        children: [
                          Icon(section['icon'] as IconData, size: 18, color: const Color(0xFFC84C00)),
                          const SizedBox(width: 8),
                          Text(
                            section['category'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC84C00),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${filteredScreens.length} Screens',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    ...filteredScreens.map((item) {
                      return Card(
                        color: const Color(0xFF1E293B),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(item['icon'] as IconData, color: Colors.white70, size: 20),
                          title: Text(
                            item['title'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          subtitle: Text(
                            item['route'] as String,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFC84C00), size: 14),
                          onTap: () => context.go(item['route'] as String),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = _selectedCategory == id;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFC84C00),
      backgroundColor: const Color(0xFF1E293B),
      onSelected: (_) => setState(() => _selectedCategory = id),
    );
  }
}
