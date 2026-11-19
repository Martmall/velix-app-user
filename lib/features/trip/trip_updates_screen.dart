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
      backgroundColor: VelixPalette.stone,
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
                context.go(AppRoutes.myBookings);
              }
            },
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
            Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: VelixPalette.copper),
                SizedBox(width: 4),
                Text('Trip in Progress', style: TextStyle(fontSize: 10, color: VelixPalette.muted)),
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
              color: VelixPalette.stone,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: VelixPalette.ink, size: 18),
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
                color: VelixPalette.paper,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelixPalette.line),
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
                        color: VelixPalette.stone,
                        child: const Center(
                          child: Icon(Icons.directions_car, size: 90, color: VelixPalette.lineStrong),
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
                                Text(trip?.carName ?? 'No active trip', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: VelixPalette.stone,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description_outlined, size: 10, color: VelixPalette.muted),
                                      const SizedBox(width: 4),
                                      Text(trip == null ? '-' : 'BK-${trip.id.substring(trip.id.length > 6 ? trip.id.length - 6 : 0).toUpperCase()}', style: const TextStyle(fontSize: 10, color: VelixPalette.muted)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(trip == null ? '-' : '₦${trip.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                                const Text('total', style: TextStyle(fontSize: 9, color: VelixPalette.muted)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Date Row Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: VelixPalette.stone,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: VelixPalette.line),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PICKUP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VelixPalette.lineStrong)),
                                  Text(trip == null ? '-' : fmt.format(trip.startDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 10, color: VelixPalette.copper),
                                      const SizedBox(width: 2),
                                      Text(place, style: const TextStyle(fontSize: 9, color: VelixPalette.muted)),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: VelixPalette.copperSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(trip == null ? '-' : '${trip.days} days', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('RETURN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VelixPalette.lineStrong)),
                                  Text(trip == null ? '-' : fmt.format(trip.endDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 10, color: VelixPalette.copper),
                                      const SizedBox(width: 2),
                                      Text(place, style: const TextStyle(fontSize: 9, color: VelixPalette.muted)),
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
                            Text('Rental Progress', style: TextStyle(fontSize: 11, color: VelixPalette.muted)),
                            Text('Day 2 of 3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.go)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: 0.66,
                          backgroundColor: VelixPalette.line,
                          color: VelixPalette.go,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 16),
                        // Select Issue Type Dashed Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: VelixPalette.paper,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: VelixPalette.lineStrong, style: BorderStyle.solid),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Issue Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.muted)),
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
                            color: VelixPalette.stone,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: VelixPalette.lineStrong, style: BorderStyle.solid),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13, color: VelixPalette.ink),
                            decoration: const InputDecoration(
                              hintText: 'Describe your update or issues in detail...',
                              hintStyle: TextStyle(color: VelixPalette.lineStrong, fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Evidence Upload Dropzone Box
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: VelixPalette.paper,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: VelixPalette.lineStrong, style: BorderStyle.solid),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.file_upload_outlined, size: 28, color: VelixPalette.muted),
                              SizedBox(height: 6),
                              Text('Upload evidence (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.muted)),
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
              icon: const Icon(Icons.key, size: 18, color: VelixPalette.paper),
              label: const Text('Digital Key & Unlock', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: VelixPalette.ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            // Dashed Return Vehicle Button
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.returnVehicle),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: VelixPalette.paper,
                side: const BorderSide(color: VelixPalette.lineStrong, style: BorderStyle.solid),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Return Vehicle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.muted)),
            ),
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
          color: isSelected ? VelixPalette.copperSoft : VelixPalette.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? VelixPalette.copper : VelixPalette.line),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? VelixPalette.copper : VelixPalette.muted,
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
