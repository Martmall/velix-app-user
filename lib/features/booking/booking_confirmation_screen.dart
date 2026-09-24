import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    final car = draft.selectedCar;
    final bookingId = draft.lastBookingId != null && draft.lastBookingId!.isNotEmpty
        ? '#${draft.lastBookingId!.toUpperCase()}'
        : '#VLX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final location = draft.pickupLocation.isNotEmpty ? draft.pickupLocation : 'Lagos, Nigeria';
    final paymentMethod = draft.paymentMethod.isNotEmpty ? draft.paymentMethod : 'Velix Pay';
    final amount = draft.breakdown.grandTotal > 0 ? draft.breakdown.grandTotal : 125000.0;
    final carName = car?.name ?? 'Premium Rental Vehicle';

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),
              // Glowing Green Checkmark Circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.45),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 52, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Your $carName is reserved. Digital key has been provisioned to your device.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.4),
                ),
              ),
              const SizedBox(height: 32),
              // Booking Detail Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  children: [
                    _buildItem('Booking Reference ID', bookingId),
                    const Divider(color: Color(0xFF1E293B), height: 24),
                    _buildItem('Pickup Location', location),
                    const Divider(color: Color(0xFF1E293B), height: 24),
                    _buildItem('Payment Method', paymentMethod),
                    const Divider(color: Color(0xFF1E293B), height: 24),
                    _buildItem('Amount Paid', '₦${amount.toStringAsFixed(0)}', isHighlight: true),
                  ],
                ),
              ),
              const Spacer(),
              // Vibrant Blue Primary Button
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.tripUpdates),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Track Trip & Keyless Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              // Outlined Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E293B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Back to Home Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF10B981) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
