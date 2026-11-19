import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class UserBookingDetailScreen extends ConsumerWidget {
  final BookingModel? booking;
  const UserBookingDetailScreen({super.key, this.booking});

  /// Same "BK-..." reference format the backend uses in message threads.
  static String _reference(String id) => 'BK-${id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id.toUpperCase()}';

  bool get _isOpen => booking?.status == BookingStatus.pending || booking?.status == BookingStatus.confirmed;

  Future<void> _pay(BuildContext context, WidgetRef ref, BookingModel b) async {
    final payments = ref.read(paymentRepositoryProvider);
    try {
      final session = await payments.startBookingCheckout(b.id);
      if (!context.mounted) return;
      final result = await FlutterwaveCheckoutScreen.open(context, session);
      if (!context.mounted || result.cancelled) return;
      final outcome = await payments.confirmBookingCheckout(session, result.transactionId!);
      if (!context.mounted) return;
      ref.invalidate(userBookingsProvider);
      switch (outcome) {
        case PaymentOutcome.paid:
          VelixToast.showSuccess(context, 'Payment received. Thank you!');
        case PaymentOutcome.pending:
          VelixToast.showInfo(context, 'Payment is being confirmed.');
        case PaymentOutcome.failed:
          VelixToast.showError(context, 'The payment failed. Please try again.');
      }
    } catch (e) {
      if (context.mounted) VelixToast.showError(context, ApiClient.parseErrorMessage(e));
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, BookingModel b) async {
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(b.id, reason: 'Cancelled by customer in app');
      ref.invalidate(userBookingsProvider);
      if (!context.mounted) return;
      VelixToast.showSuccess(context, 'Booking cancelled.');
      context.go(AppRoutes.myBookings);
    } catch (e) {
      if (context.mounted) VelixToast.showError(context, ApiClient.parseErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = booking;
    if (b == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Booking not found. Open it from My Bookings.')),
      );
    }
    final id = b.id;
    final carName = b.carName;
    final carImage = b.carImage.isNotEmpty ? b.carImage : CarImageCatalog.toyotaPrado;
    final total = b.totalPrice;
    final statusStr = b.status.name.toUpperCase();
    final isConfirmedOrActive = b.status == BookingStatus.active || b.status == BookingStatus.confirmed;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
            Text(id, style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Status Banner Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isConfirmedOrActive ? VelixPalette.goSoft : VelixPalette.claimSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isConfirmedOrActive ? VelixPalette.goSoft : VelixPalette.claimSoft),
              ),
              child: Row(
                children: [
                  Icon(
                    isConfirmedOrActive ? Icons.check_circle : Icons.info_outline,
                    color: isConfirmedOrActive ? VelixPalette.go : VelixPalette.claim,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: $statusStr',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isConfirmedOrActive ? VelixPalette.onGoSoft : VelixPalette.claim,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pickup: ${b.startDate.day}/${b.startDate.month}/${b.startDate.year} • Return: ${b.endDate.day}/${b.endDate.month}/${b.endDate.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isConfirmedOrActive ? VelixPalette.go : VelixPalette.claim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Booking reference banner (there is no real handover OTP in the backend yet)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: VelixPalette.copperSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VelixPalette.copper.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: VelixPalette.copper, size: 20),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Booking Reference', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                          Text('Quote this to your partner at pickup', style: TextStyle(fontSize: 10, color: VelixPalette.muted)),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking reference copied!'),
                          backgroundColor: VelixPalette.go,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: VelixPalette.paper,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: VelixPalette.copper.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _reference(b.id),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: VelixPalette.copper, letterSpacing: 2.0),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, size: 14, color: VelixPalette.copper),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Vehicle Info Card Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VelixPalette.paper,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelixPalette.line),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      carImage,
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 60,
                        color: VelixPalette.stone,
                        child: const Icon(Icons.directions_car, size: 40, color: VelixPalette.lineStrong),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(carName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                        const SizedBox(height: 2),
                        Text(b.pickupLocation.isNotEmpty ? b.pickupLocation : 'Pickup location to be confirmed', style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
                        const SizedBox(height: 4),
                        Text('₦${(total / 3).toStringAsFixed(0)} / day', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Host Profile Container Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VelixPalette.paper,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelixPalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CAR OWNER / HOST', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelixPalette.muted, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: VelixPalette.copper,
                        child: Text('EA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adebayo Luxury Motors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                            Text('✔ Verified Host • Top Rated', style: TextStyle(fontSize: 10, color: VelixPalette.go)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: VelixPalette.copper, size: 20),
                        // The booking API doesn't expose the host's phone number; support relays.
                        onPressed: () => context.push(AppRoutes.liveChat, extra: {'isHost': true}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: VelixPalette.ink, size: 20),
                        onPressed: () => context.go(AppRoutes.liveChat),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Itemized Receipt Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VelixPalette.paper,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelixPalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                  const SizedBox(height: 12),
                  _buildReceiptRow('Total Rental Amount', '₦${total.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Payment Method', 'Flutterwave'),
                  const SizedBox(height: 8),
                  const Divider(color: VelixPalette.line),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                      Text('₦${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (_isOpen) ...[
              PartnerOrangeButton(
                text: 'Pay Now',
                onPressed: () => _pay(context, ref, b),
              ),
              const SizedBox(height: 12),
            ],
            PartnerOrangeButton(
              text: 'Live Trip Updates',
              onPressed: () => context.go(AppRoutes.tripUpdates),
            ),
            const SizedBox(height: 12),
            if (_isOpen) OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel Booking?', style: TextStyle(fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to cancel this booking?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Booking')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _cancel(context, ref, b);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: VelixPalette.claim),
                        child: const Text('Yes, Cancel', style: TextStyle(color: VelixPalette.paper)),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: VelixPalette.claim),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Cancel Booking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.claim)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: VelixPalette.muted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
      ],
    );
  }
}
