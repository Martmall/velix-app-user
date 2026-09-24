import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        title: const Text(
          'Booking Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Green Checkmark Celebration Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 70, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Confirmed! 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your reservation for Toyota Prado 2023 has been successfully confirmed. Booking Ref: VLX-90821-NG',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // Summary Card Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          CarImageCatalog.toyotaPrado,
                          width: 70,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 50,
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(Icons.directions_car, size: 32, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Toyota Prado 2023', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                            SizedBox(height: 2),
                            Text('2022 • SUV • Automatic', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),
                  _buildDetailRow('Rental Period', 'Apr 07 - Apr 10, 2026 (3 days)'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Pickup Location', 'Ikeja, Lagos'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Total Amount Paid', '₦137,000'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Payment Method', 'VISA Card (•••• 4523)'),
                ],
              ),
            ),
            const SizedBox(height: 36),
            PartnerOrangeButton(
              text: 'View Booking Details',
              onPressed: () => context.go(AppRoutes.bookingDetail),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.home),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Back to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
      ],
    );
  }
}
