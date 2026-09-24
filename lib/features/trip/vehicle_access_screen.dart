import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class VehicleAccessScreen extends ConsumerStatefulWidget {
  const VehicleAccessScreen({super.key});

  @override
  ConsumerState<VehicleAccessScreen> createState() => _VehicleAccessScreenState();
}

class _VehicleAccessScreenState extends ConsumerState<VehicleAccessScreen> {
  final List<TextEditingController> _pinControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  void _verifyCode() async {
    final enteredPin = _pinControllers.map((c) => c.text).join();
    if (enteredPin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the digital keyless access code.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final draft = ref.read(bookingDraftProvider);
    final bookingId = draft.lastBookingId ?? 'active_booking';

    try {
      await ref.read(bookingRepositoryProvider).toggleKeylessRemote(bookingId, true);
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.vehicleSecured);
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
          'Vehicle Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Dashed Container Card Box
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Center Key Icon Badge
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: const Color(0xFFFDF0E9),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFFFCD34D).withValues(alpha: 0.4),
                      child: const Icon(Icons.key, size: 36, color: Color(0xFF0C1830)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Pickup Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the 6-digit code sent to you to confirm your identity and unlock your vehicle',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  // 6 PIN Input Boxes Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) => _buildPinBox(i)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Resend Code ', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('00:59', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 36),
            PartnerOrangeButton(
              text: 'Verify & Unlock',
              isLoading: _isLoading,
              onPressed: _verifyCode,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPinBox(int index) {
    final isFirst = index == 0;
    return SizedBox(
      width: 44,
      height: 54,
      child: TextField(
        controller: _pinControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: isFirst ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB), width: isFirst ? 1.5 : 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: isFirst ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB), width: isFirst ? 1.5 : 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFC84C00), width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }
}
