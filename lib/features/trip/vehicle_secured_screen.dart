import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class VehicleSecuredScreen extends StatelessWidget {
  const VehicleSecuredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 80, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Granted!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your vehicle is now unlocked',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const Spacer(flex: 3),
              const Text(
                'Enjoy your ride with',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              // Velix Logo Header
              const VelixLogoHeader(),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.tripUpdates),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFFC84C00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Proceed to Trip Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
