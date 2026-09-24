import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class PaymentOtpScreen extends ConsumerStatefulWidget {
  const PaymentOtpScreen({super.key});

  @override
  ConsumerState<PaymentOtpScreen> createState() => _PaymentOtpScreenState();
}

class _PaymentOtpScreenState extends ConsumerState<PaymentOtpScreen> {
  bool _isProcessing = false;

  void _confirmPayment() async {
    setState(() => _isProcessing = true);
    final user = ref.read(userAuthProvider).user;
    final createdBooking = await ref.read(bookingDraftProvider.notifier).confirmAndPay(user: user);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (createdBooking != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment authorized and booking created successfully!'),
            backgroundColor: Color(0xFF0C1830),
          ),
        );
      }
      context.go(AppRoutes.bookingConfirmation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final grandTotal = draft.breakdown.grandTotal;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '3D Secure Payment Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Blue Shield Circular Badge
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A4A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.shield_outlined, size: 48, color: Color(0xFF3B82F6)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Authorize ₦${grandTotal.toStringAsFixed(0)} Charge',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Enter the 4-digit security PIN sent by your bank to authorize this payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.4),
                ),
              ),
              const SizedBox(height: 40),
              // 4 PIN Boxes matching dark style
              OtpPinInput(
                length: 4,
                fillColor: const Color(0xFF131B2A),
                textColor: Colors.white,
                borderColor: const Color(0xFF1E293B),
                activeBorderColor: const Color(0xFF3B82F6),
                onCompleted: (code) {
                  _confirmPayment();
                },
              ),
              const SizedBox(height: 48),
              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF3B82F6)),
                    SizedBox(height: 16),
                    Text(
                      'Processing Transaction securely with Bank...',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm & Authorize Payment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
