import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class CarReturnedSuccessScreen extends StatelessWidget {
  const CarReturnedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Success Circle Icon Badge
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
                'Car Returned Successfully',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Thank you for choosing Velix',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 28),
              // Return Summary Dashed Container Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Return Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                    SizedBox(height: 14),
                    Text('Vehicle', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    SizedBox(height: 2),
                    Text('Toyota Prado 2023', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                    SizedBox(height: 12),
                    Text('Rental Duration', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    SizedBox(height: 2),
                    Text('3 Days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                    SizedBox(height: 12),
                    Text('Return Time', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    SizedBox(height: 2),
                    Text('9:05 AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Soft Peach Banner Container Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'We hope you enjoyed your ride! A confirmation has been sent to your email.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),
              PartnerOrangeButton(
                text: 'Rate Your Experience',
                onPressed: () => context.go(AppRoutes.leaveReview),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Go to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
