import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otp = '';
  bool _isLoading = false;
  int _secondsRemaining = 45;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        _startTimer();
      }
    });
  }

  void _verify() {
    if (_otp.length == 4) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          context.go(AppRoutes.setUp);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('OTP Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go(AppRoutes.signIn),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.cardDark,
                child: Icon(Icons.mark_email_read_outlined, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text('Verification Code', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              const Text(
                'We sent a 4-digit verification code to your phone number +1 234 *** **89',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 36),
              OtpPinInput(
                length: 4,
                onCompleted: (val) {
                  setState(() => _otp = val);
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsRemaining > 0
                        ? 'Resend code in 0:${_secondsRemaining.toString().padLeft(2, '0')}'
                        : "Didn't receive code? ",
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  if (_secondsRemaining == 0)
                    GestureDetector(
                      onTap: () {
                        setState(() => _secondsRemaining = 45);
                        _startTimer();
                      },
                      child: const Text('Resend', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
