import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class TripUpdatesScreen extends ConsumerStatefulWidget {
  const TripUpdatesScreen({super.key});

  @override
  ConsumerState<TripUpdatesScreen> createState() => _TripUpdatesScreenState();
}

class _TripUpdatesScreenState extends ConsumerState<TripUpdatesScreen> {
  String? _selectedIssue;
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  void _sendUpdate() async {
    final issue = _selectedIssue ?? 'Trip Update';
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description for your update.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(supportRepositoryProvider).createSupportTicket(
            subject: 'Trip Incident Report: $issue',
            category: 'Vehicle Condition & Damage',
            description: desc,
          );
      if (!mounted) return;
      _descriptionController.clear();
      VelixToast.showSuccess(context, 'Report sent to Velix support. We\'ll reply in Help & Support.');
    } catch (e) {
      if (mounted) VelixToast.showError(context, ApiClient.parseErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(currentTripProvider);
    final fmt = DateFormat('MMM dd, yyyy');
    final place = trip?.pickupLocation.isNotEmpty == true ? trip!.pickupLocation : '-';
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
                context.go(AppRoutes.myBookings);
              }
            },
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
            Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: Color(0xFFC84C00)),
                SizedBox(width: 4),
                Text('Trip in Progress', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              ],
            ),
          ],
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
            child: const Icon(Icons.tune, color: Color(0xFF0C1830), size: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Active Vehicle Card Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      trip?.carImage.isNotEmpty == true ? trip!.carImage : CarImageCatalog.toyotaPrado,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 170,
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: Icon(Icons.directions_car, size: 90, color: Color(0xFF9CA3AF)),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trip?.carName ?? 'No active trip', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description_outlined, size: 10, color: Color(0xFF6B7280)),
                                      const SizedBox(width: 4),
                                      Text(trip == null ? '-' : 'BK-${trip.id.substring(trip.id.length > 6 ? trip.id.length - 6 : 0).toUpperCase()}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(trip == null ? '-' : '₦${trip.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                                const Text('total', style: TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Date Row Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PICKUP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                                  Text(trip == null ? '-' : fmt.format(trip.startDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 10, color: Color(0xFFC84C00)),
                                      const SizedBox(width: 2),
                                      Text(place, style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF0E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(trip == null ? '-' : '${trip.days} days', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('RETURN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                                  Text(trip == null ? '-' : fmt.format(trip.endDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 10, color: Color(0xFFC84C00)),
                                      const SizedBox(width: 2),
                                      Text(place, style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rental Progress', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                            Text('Day 2 of 3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: 0.66,
                          backgroundColor: const Color(0xFFE5E7EB),
                          color: const Color(0xFF10B981),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 16),
                        // Select Issue Type Dashed Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Issue Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                              const SizedBox(height: 10),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 2.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                children: [
                                  _buildIssueChip('🚗  Car Issue'),
                                  _buildIssueChip('🕒  Delay'),
                                  _buildIssueChip('⚠️  Accident'),
                                  _buildIssueChip('❗️  Other'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Textarea Dashed Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0C1830)),
                            decoration: const InputDecoration(
                              hintText: 'Describe your update or issues in detail...',
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Evidence Upload Dropzone Box
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.file_upload_outlined, size: 28, color: Color(0xFF6B7280)),
                              SizedBox(height: 6),
                              Text('Upload evidence (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        PartnerOrangeButton(
                          text: 'Send Update',
                          isLoading: _isLoading,
                          onPressed: _sendUpdate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Keyless Access Button
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.vehicleAccess),
              icon: const Icon(Icons.key, size: 18, color: Colors.white),
              label: const Text('Digital Key & Unlock', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF0C1830),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            // Dashed Return Vehicle Button
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.returnVehicle),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD1D5DB), style: BorderStyle.solid),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Return Vehicle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
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
            _buildNavItem(Icons.calendar_month, 'Bookings', true, () => context.go(AppRoutes.myBookings)),
            _buildNavItem(Icons.search, 'Search', false, () => context.go(AppRoutes.carListing)),
            _buildNavItem(Icons.home_filled, 'Home', false, () => context.go(AppRoutes.home)),
            _buildNavItem(Icons.favorite_border, 'Saved', false, () => context.go(AppRoutes.favorites)),
            _buildNavItem(Icons.person_outline, 'Profile', false, () => context.go(AppRoutes.userProfile)),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueChip(String label) {
    final isSelected = _selectedIssue == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedIssue = label),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF0E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFC84C00) : const Color(0xFF374151),
            ),
          ),
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
