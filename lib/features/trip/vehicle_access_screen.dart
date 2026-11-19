import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class VehicleAccessScreen extends ConsumerStatefulWidget {
  const VehicleAccessScreen({super.key});

  @override
  ConsumerState<VehicleAccessScreen> createState() => _VehicleAccessScreenState();
}

class _VehicleAccessScreenState extends ConsumerState<VehicleAccessScreen> {
  final List<TextEditingController> _pinControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final bool _isLoading = false;

  void _verifyCode() async {
    final enteredPin = _pinControllers.map((c) => c.text).join();
    if (enteredPin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the digital keyless access code.')),
      );
      return;
    }

    // No vehicle has a connected keyless lock yet, so no code can unlock one. Don't pretend.
    VelixToast.showInfo(context, 'Keyless unlock isn\'t available for this vehicle yet. Please collect the keys from your partner at pickup.');
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
          'Vehicle Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink),
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
                color: VelixPalette.stone.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VelixPalette.lineStrong, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Center Key Icon Badge
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: VelixPalette.copperSoft,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: VelixPalette.amberSoft.withValues(alpha: 0.4),
                      child: const Icon(Icons.key, size: 36, color: VelixPalette.ink),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Pickup Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the 6-digit code sent to you to confirm your identity and unlock your vehicle',
                    style: TextStyle(fontSize: 13, color: VelixPalette.muted, height: 1.4),
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
                      const Text('Resend Code ', style: TextStyle(fontSize: 12, color: VelixPalette.muted)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: VelixPalette.line,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('00:59', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.muted)),
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelixPalette.ink),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: VelixPalette.paper,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: isFirst ? VelixPalette.copper : VelixPalette.line, width: isFirst ? 1.5 : 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: isFirst ? VelixPalette.copper : VelixPalette.line, width: isFirst ? 1.5 : 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: VelixPalette.copper, width: 2),
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
