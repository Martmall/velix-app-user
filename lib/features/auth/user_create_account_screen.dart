import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class UserCreateAccountScreen extends ConsumerStatefulWidget {
  const UserCreateAccountScreen({super.key});

  @override
  ConsumerState<UserCreateAccountScreen> createState() => _UserCreateAccountScreenState();
}

class _UserCreateAccountScreenState extends ConsumerState<UserCreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCustomerRole = true;
  bool _obscurePassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;
  CountryCode _selectedCountry = CountryCode.defaultCountry;

  Future<void> _pickCountryCode() async {
    final picked = await CountryCodePickerModal.show(
      context: context,
      selectedCountry: _selectedCountry,
    );
    if (picked != null) {
      setState(() => _selectedCountry = picked);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeTerms) {
        VelixToast.showInfo(
          context,
          'Please accept the Terms of Service & Privacy Policy to continue.',
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final rawPhone = _phoneController.text.trim();
        final formattedPhone = rawPhone.startsWith('+')
            ? rawPhone
            : '${_selectedCountry.dialCode} $rawPhone';

        final role = _isCustomerRole ? UserRole.user : UserRole.partner;
        final user = await ref.read(authRepositoryProvider).registerUser(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: formattedPhone,
          password: _passwordController.text,
          role: role,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          final roleTitle = _isCustomerRole ? 'Customer Account' : 'Partner Host Account';
          VelixToast.showSuccess(
            context,
            '$roleTitle created for ${user.fullName}! Please verify your phone.',
          );
          context.go(AppRoutes.otpVerification, extra: formattedPhone);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          final message = e.toString().replaceAll('Exception:', '').trim();
          VelixToast.showError(
            context,
            message.isNotEmpty ? message : 'Registration failed. Please check your details.',
          );
        }
      }
    }
  }

  Future<void> _socialSignUp(String provider) async {
    final user = await SocialAuthModal.show(
      context: context,
      provider: provider,
      isPartner: !_isCustomerRole,
    );

    if (user != null && mounted) {
      VelixToast.showSuccess(
        context,
        'Welcome, ${user.fullName}! Connected with $provider.',
      );
      context.go(AppRoutes.otpVerification, extra: user.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);
    final roleToggleBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.onboarding),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.brightness_2_outlined, color: textColor),
            onPressed: () {
              ref.read(appThemeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const VelixLogoHeader(),
                const SizedBox(height: 20),
                Text(
                  _isCustomerRole ? 'Create Customer Account' : 'Create Partner Host Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isCustomerRole
                      ? "Join Nigeria's premium car rental platform"
                      : "List your vehicles and earn daily with Velix Fleet",
                  style: TextStyle(fontSize: 13, color: subtextColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Main Container Card
                Container(
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Social Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _socialSignUp('Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: borderColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: isDark ? const Color(0xFF1F2430) : Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('G ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
                                  Text('Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _socialSignUp('Apple'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : const Color(0xFF0C1830),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.apple, color: isDark ? Colors.black : Colors.white, size: 20),
                                  const SizedBox(width: 6),
                                  Text('Apple', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: Divider(color: borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or continue with details', style: TextStyle(color: subtextColor, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: borderColor)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Role Segmented Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: roleToggleBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCustomerRole = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isCustomerRole ? const Color(0xFFC84C00) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_outline, size: 16, color: _isCustomerRole ? Colors.white : subtextColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        "I'm a Customer",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _isCustomerRole ? Colors.white : subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCustomerRole = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !_isCustomerRole ? const Color(0xFFC84C00) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.directions_car_outlined, size: 16, color: !_isCustomerRole ? Colors.white : subtextColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        "I Own a Car",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: !_isCustomerRole ? Colors.white : subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _buildInputDecoration('Enter your full name', inputBg, borderColor, subtextColor),
                        validator: (val) => val == null || val.isEmpty ? 'Full name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _buildInputDecoration('you@example.com', inputBg, borderColor, subtextColor),
                        validator: (val) => val == null || val.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 14),
                      Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickCountryCode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Text(_selectedCountry.flag, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedCountry.dialCode,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.keyboard_arrow_down, size: 16, color: subtextColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _buildInputDecoration('0801 234 5678', inputBg, borderColor, subtextColor),
                              validator: (val) => val == null || val.isEmpty ? 'Phone number required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _buildInputDecoration('Min. 8 characters', inputBg, borderColor, subtextColor).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: subtextColor,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) => val == null || val.length < 8 ? 'Password must be at least 8 chars' : null,
                      ),
                      const SizedBox(height: 16),
                      // Terms Checkbox Row
                      GestureDetector(
                        onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeTerms,
                                activeColor: const Color(0xFFC84C00),
                                checkColor: Colors.white,
                                side: BorderSide(color: subtextColor, width: 1.8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'I agree to Velix ',
                                  style: TextStyle(fontSize: 12, color: subtextColor),
                                  children: const [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(color: Color(0xFFC84C00), fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(color: Color(0xFFC84C00), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      PartnerOrangeButton(
                        text: _isCustomerRole ? 'Create Customer Account' : 'Register Host Account',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(color: subtextColor, fontSize: 13)),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.signIn),
                            child: const Text('Login', style: TextStyle(color: Color(0xFFC84C00), fontWeight: FontWeight.bold, fontSize: 13)),
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

  InputDecoration _buildInputDecoration(String hint, Color fillBg, Color borderColor, Color hintColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      filled: true,
      fillColor: fillBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5),
      ),
    );
  }
}
