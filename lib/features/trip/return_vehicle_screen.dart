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

    // Completing a rental is the partner's action (they inspect the car and confirm in their
    // app). Here we only check whether they have done so yet.
    setState(() => _isLoading = true);
    ref.invalidate(userBookingsProvider);
    try {
      final trip = ref.read(currentTripProvider);
      final latest = trip == null ? null : await ref.read(bookingRepositoryProvider).getBookingById(trip.id);
      if (!mounted) return;
      if (latest == null || latest.status == BookingStatus.completed) {
        context.go(AppRoutes.carReturnedSuccess);
      } else {
        VelixToast.showInfo(context, 'Your partner hasn\'t confirmed the return yet. Hand over the keys and they\'ll complete it in their app.');
      }
    } catch (e) {
      if (mounted) VelixToast.showError(context, ApiClient.parseErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelixPalette.stone,
      appBar: AppBar(
        backgroundColor: VelixPalette.stone,
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
                context.go(AppRoutes.tripUpdates);
              }
            },
          ),
        ),
        title: const Text(
          'Return Vehicle',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink),
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
                color: VelixPalette.paper,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VelixPalette.line),
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
                      color: VelixPalette.copperSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: VelixPalette.amberSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_car, size: 32, color: VelixPalette.ink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Return Code',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the return code provided by the vendor to complete your trip',
                    style: TextStyle(fontSize: 13, color: VelixPalette.muted, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  // 6 PIN Input Boxes with crisp text rendering
                  OtpPinInput(
                    length: 6,
                    fillColor: VelixPalette.paper,
                    textColor: VelixPalette.ink,
                    borderColor: VelixPalette.line,
                    activeBorderColor: VelixPalette.copper,
                    onCompleted: (val) {
                      setState(() => _returnCode = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Inspection Note Box Container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VelixPalette.stone,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VelixPalette.line),
                    ),
                    child: const Text(
                      'Please ensure the vehicle is returned to the designed location and the vendor has inspected it before entering the code.',
                      style: TextStyle(fontSize: 12, color: VelixPalette.muted, height: 1.4),
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
