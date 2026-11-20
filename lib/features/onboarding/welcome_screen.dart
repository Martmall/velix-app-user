import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

/// Launch screen: shows the logo, waits for the saved session to be restored, then opens the
/// app signed in (home) or goes to onboarding for a new or signed-out visitor.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    _continue(minimumDelay: const Duration(seconds: 2));
  }

  Future<void> _continue({Duration minimumDelay = Duration.zero}) async {
    final notifier = ref.read(userAuthProvider.notifier);
    await Future.wait([Future<void>.delayed(minimumDelay), notifier.ready]);
    if (!mounted || _routed) return;
    _routed = true;
    final signedIn = ref.read(userAuthProvider).isAuthenticated;
    context.go(signedIn ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _continue(),
      child: const Scaffold(
        backgroundColor: VelixPalette.paper,
        body: SafeArea(
          child: Column(
            children: [
              Spacer(),
              // Center Branding
              Center(
                child: VelixLogoHeader(),
              ),
              Spacer(),
              // Bottom Footer Text
              Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'PREMIUM CAR RENTAL ACROSS NIGERIA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: VelixPalette.muted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
