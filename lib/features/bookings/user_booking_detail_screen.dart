import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class UserBookingDetailScreen extends StatelessWidget {
  final BookingModel? booking;
  const UserBookingDetailScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final id = b?.id ?? 'BK-VNG-00124';
    final carName = b?.carName ?? 'Toyota Prado 2023';
    final carImage = (b?.carImage != null && b!.carImage.isNotEmpty)
        ? b.carImage
        : CarImageCatalog.toyotaPrado;
    final total = b?.totalPrice ?? 150000.0;
    final statusStr = b?.status.name.toUpperCase() ?? 'CONFIRMED';
    final isConfirmedOrActive = b?.status == BookingStatus.active || b?.status == BookingStatus.confirmed || b == null;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
            Text(id, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
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
                color: isConfirmedOrActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isConfirmedOrActive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  Icon(
                    isConfirmedOrActive ? Icons.check_circle : Icons.info_outline,
                    color: isConfirmedOrActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
                            color: isConfirmedOrActive ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b != null
                              ? 'Pickup: ${b.startDate.day}/${b.startDate.month}/${b.startDate.year} • Return: ${b.endDate.day}/${b.endDate.month}/${b.endDate.year}'
                              : 'Trip ongoing. Scheduled return: Apr 10, 2026',
                          style: TextStyle(
                            fontSize: 11,
                            color: isConfirmedOrActive ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Pickup Release Code OTP Banner Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFFC84C00), size: 20),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Handover Pickup OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                          Text('Show to partner at vehicle pickup', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Handover OTP code copied to clipboard!'),
                          backgroundColor: Color(0xFF10B981),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            (b?.id.isNotEmpty == true) ? (b!.id.hashCode.abs().toString().padLeft(6, '0').substring(0, 6)) : '884219',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFC84C00), letterSpacing: 2.0),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, size: 14, color: Color(0xFFC84C00)),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.directions_car, size: 40, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(carName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                        const SizedBox(height: 2),
                        Text(b?.pickupLocation.isNotEmpty == true ? b!.pickupLocation : 'Lagos • Nigeria', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        const SizedBox(height: 4),
                        Text('₦${(total / 3).toStringAsFixed(0)} / day', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CAR OWNER / HOST', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFC84C00),
                        child: Text('EA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adebayo Luxury Motors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                            Text('✔ Verified Host • Top Rated', style: TextStyle(fontSize: 10, color: Color(0xFF10B981))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: Color(0xFFC84C00), size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling Host (+234 803 123 4567)...')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF0C1830), size: 20),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                  const SizedBox(height: 12),
                  _buildReceiptRow('Total Rental Amount', '₦${total.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Payment Method', b?.paymentMethod.isNotEmpty == true ? b!.paymentMethod : 'Card Payment'),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                      Text('₦${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PartnerOrangeButton(
              text: 'Live Trip Updates',
              onPressed: () => context.go(AppRoutes.tripUpdates),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel Booking?', style: TextStyle(fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to cancel this booking? Cancellation within 24 hours of pickup is 100% refundable.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Booking')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Booking $id has been cancelled.')),
                          );
                          context.go(AppRoutes.myBookings);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                        child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Cancel Booking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
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
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
      ],
    );
  }
}
