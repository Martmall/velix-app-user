import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class ReturnVehicleScreen extends ConsumerStatefulWidget {
  const ReturnVehicleScreen({super.key});

  @override
  ConsumerState<ReturnVehicleScreen> createState() => _ReturnVehicleScreenState();
}

class _ReturnVehicleScreenState extends ConsumerState<ReturnVehicleScreen> {
  String _returnCode = '';
  bool _isLoading = false;

  void _confirmReturn() async {
    if (_returnCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit return code provided by the host.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final draft = ref.read(bookingDraftProvider);
    final bookingId = draft.lastBookingId ?? 'active_booking';

    try {
      await ref.read(bookingRepositoryProvider).updateBookingStatus(bookingId, BookingStatus.completed);
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.carReturnedSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
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
                context.go(AppRoutes.tripUpdates);
              }
            },
          ),
        ),
        title: const Text(
          'Return Vehicle',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // White Container Card Box
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Center Car Icon Badge
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDF0E9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDE68A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_car, size: 32, color: Color(0xFF0C1830)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Return Code',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the return code provided by the vendor to complete your trip',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  // 6 PIN Input Boxes with crisp text rendering
                  OtpPinInput(
                    length: 6,
                    fillColor: Colors.white,
                    textColor: const Color(0xFF0C1830),
                    borderColor: const Color(0xFFE5E7EB),
                    activeBorderColor: const Color(0xFFC84C00),
                    onCompleted: (val) {
                      setState(() => _returnCode = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Inspection Note Box Container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Text(
                      'Please ensure the vehicle is returned to the designed location and the vendor has inspected it before entering the code.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 36),
            PartnerOrangeButton(
              text: 'Confirm Return',
              isLoading: _isLoading,
              onPressed: _confirmReturn,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
