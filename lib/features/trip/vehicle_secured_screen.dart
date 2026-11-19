import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class VehicleSecuredScreen extends StatelessWidget {
  const VehicleSecuredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelixPalette.stone,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Success Circle Icon Badge
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: VelixPalette.goSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 80, color: VelixPalette.go),
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Granted!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VelixPalette.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your vehicle is now unlocked',
                style: TextStyle(fontSize: 14, color: VelixPalette.muted),
              ),
              const Spacer(flex: 3),
              const Text(
                'Enjoy your ride with',
                style: TextStyle(fontSize: 12, color: VelixPalette.muted),
              ),
              const SizedBox(height: 12),
              // Velix Logo Header
              const VelixLogoHeader(),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.tripUpdates),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: VelixPalette.copper,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Proceed to Trip Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
