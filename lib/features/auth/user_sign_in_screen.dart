import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class UserSignInScreen extends ConsumerStatefulWidget {
  const UserSignInScreen({super.key});

  @override
  ConsumerState<UserSignInScreen> createState() => _UserSignInScreenState();
}

class _UserSignInScreenState extends ConsumerState<UserSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final enabled = await BiometricAuthService.isBiometricEnabled();
    final enrolledEmail = await BiometricAuthService.getEnrolledUserEmail();
    if (mounted) {
      setState(() {
        _biometricsEnabled = enabled && enrolledEmail != null && enrolledEmail.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final notifier = ref.read(userAuthProvider.notifier);
    final ok = await notifier.signIn(email, _passwordController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    final state = ref.read(userAuthProvider);
    if (ok) {
      VelixToast.showSuccess(context, 'Welcome back, ${state.user?.fullName ?? ''}!');
      context.go(AppRoutes.home);
      return;
    }
    final error = state.error ?? 'Invalid email or password.';
    VelixToast.showError(context, error);
    // Registered but never confirmed the emailed code: send a fresh one and go confirm it.
    if (error.toLowerCase().contains('verify your email')) {
      await notifier.resendVerificationEmail(email);
      if (mounted) context.go(AppRoutes.otpVerification, extra: email);
    }
  }

  Future<void> _socialSignIn(String provider) async {
    if (provider.toLowerCase() != 'google') {
      VelixToast.showInfo(context, 'Apple sign-in isn\'t available yet. Please use Google or email.');
      return;
    }
    setState(() => _isLoading = true);
    final ok = await ref.read(userAuthProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      VelixToast.showError(context, ref.read(userAuthProvider).error ?? 'Google sign-in failed.');
    }
  }

  Future<void> _handleBiometricSignIn() async {
    final isEnabled = await BiometricAuthService.isBiometricEnabled();
    final enrolledEmail = await BiometricAuthService.getEnrolledUserEmail();
    final enrolledName = await BiometricAuthService.getEnrolledUserName();

    if (!mounted) return;

    if (!isEnabled || enrolledEmail == null || enrolledEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometric login is not enabled on this device. Please sign in with your email & password first and toggle on Biometrics in Settings.',
          ),
          backgroundColor: Color(0xFFC84C00),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final success = await BiometricAuthService.authenticate(
      context: context,
      title: 'Biometric Sign In',
      localizedReason: 'Scan fingerprint to verify account: $enrolledEmail',
      actionName: 'Sign In as ${enrolledName ?? "User"}',
    );

    if (!success || !mounted) return;

    // Biometrics only unlock a session already stored on this device; they never stand in for
    // the password. No stored (or a revoked) session means a normal sign-in is needed.
    await ref.read(userAuthProvider.notifier).refreshUser();
    if (!mounted) return;
    final user = ref.read(userAuthProvider).user;
    if (user != null && user.email.toLowerCase() == enrolledEmail.toLowerCase()) {
      context.go(AppRoutes.home);
    } else {
      VelixToast.showInfo(context, 'Your session has expired. Please sign in with your password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const VelixLogoHeader(),
                const SizedBox(height: 28),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1830),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign In To Your Account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                // Elevated White Container Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C1830),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF4F6F9),
                          prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF6B7280), size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C1830),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF4F6F9),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF6B7280),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5),
                          ),
                        ),
                        validator: (val) => val == null || val.length < 6 ? 'Password required' : null,
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'or continue with',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Social Buttons Row (redirects to Create Account)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _socialSignIn('Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'G ',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                  Text(
                                    'Google',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _socialSignIn('Apple'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C1830),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.apple, color: Colors.white, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Apple',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      PartnerOrangeButton(
                        text: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                      if (_biometricsEnabled) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _handleBiometricSignIn,
                          icon: const Icon(Icons.fingerprint_rounded, color: Color(0xFFC84C00), size: 22),
                          label: const Text(
                            'Sign In with Biometrics / Fingerprint',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Not registered yet? ',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.createAccount),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                color: Color(0xFFC84C00),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
