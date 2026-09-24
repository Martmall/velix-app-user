import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  String _selectedLanguage = 'English (EN)';
  bool _isBiometricEnabled = false;
  String? _biometricEmail;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final enabled = await BiometricAuthService.isBiometricEnabled();
    final email = await BiometricAuthService.getEnrolledUserEmail();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = enabled;
        _biometricEmail = email;
      });
    }
  }

  Future<void> _handleToggleBiometrics(bool enable) async {
    final currentUser = _currentUser;
    if (enable) {
      final success = await BiometricAuthService.authenticate(
        context: context,
        title: 'Register Fingerprint & Biometrics',
        localizedReason: 'Scan your fingerprint to register and lock your Velix account to this device',
        actionName: 'Register',
      );
      if (success && mounted) {
        await BiometricAuthService.registerBiometrics(
          email: currentUser.email,
          fullName: currentUser.fullName,
          role: 'user',
        );
        setState(() {
          _isBiometricEnabled = true;
          _biometricEmail = currentUser.email;
        });
        if (mounted) {
          VelixToast.showSuccess(
            context,
            'Fingerprint registered & locked to ${currentUser.email}!',
            title: 'Biometrics Active',
          );
        }
      }
    } else {
      await BiometricAuthService.disableBiometrics();
      setState(() {
        _isBiometricEnabled = false;
        _biometricEmail = null;
      });
      if (mounted) {
        VelixToast.showSuccess(context, 'Biometric login disabled on this device.');
      }
    }
  }

  UserModel get _currentUser {
    return ref.watch(userAuthProvider).user ??
        UserModel(
          id: 'usr_new',
          fullName: 'New Velix User',
          email: 'user@velix.ng',
          phone: '+234 800 000 0000',
          role: UserRole.user,
          isVerified: false,
        );
  }

  Future<void> _changeAvatar() async {
    final newUrl = await ImagePickerModal.show(
      context: context,
      title: 'Update Profile Photo',
      category: 'avatar',
    );

    if (newUrl != null && mounted) {
      await ref.read(userAuthProvider.notifier).updateAvatar(newUrl);
      if (mounted) {
        VelixToast.showSuccess(context, 'Profile photo updated successfully!');
      }
    }
  }

  void _showEditProfileModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = _currentUser;
    final nameCtrl = TextEditingController(text: currentUser.fullName);
    final phoneCtrl = TextEditingController(text: currentUser.phone);
    final emailCtrl = TextEditingController(text: currentUser.email);
    final licenseCtrl = TextEditingController(text: currentUser.licenseNumber ?? '');

    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF0C1830);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Personal Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: labelColor)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  hintText: 'e.g. Oluwaseun Temilola',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: labelColor)),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  hintText: 'e.g. yourname@gmail.com',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: labelColor)),
              const SizedBox(height: 6),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  hintText: 'e.g. +234 801 234 5678',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Text('Driver License / NIN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: labelColor)),
              const SizedBox(height: 6),
              TextField(
                controller: licenseCtrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  hintText: 'e.g. NIN-89210-LA',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(userAuthProvider.notifier).updateProfile(
                      fullName: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      licenseNumber: licenseCtrl.text.trim(),
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Profile details saved successfully!'),
                          backgroundColor: Color(0xFF0C1830),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC84C00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);

    final currentLang = ref.read(appLanguageProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.70,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 12),
                ...AppLanguage.values.map((lang) {
                  final isSelected = currentLang == lang;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    leading: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      lang.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFC84C00) : textColor,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFFC84C00))
                        : null,
                    onTap: () {
                      ref.read(appLanguageProvider.notifier).state = lang;
                      setState(() => _selectedLanguage = lang.label);
                      Navigator.pop(ctx);
                      VelixToast.showSuccess(context, 'Language switched to ${lang.label}');
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0C1830),
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your Velix account?',
          style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(userAuthProvider.notifier).signOut();
              if (mounted) {
                VelixToast.showSuccess(context, 'Signed out successfully.');
                context.go(AppRoutes.onboarding);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final statBoxBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final iconBtnBg = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.home),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _showEditProfileModal,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBtnBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.edit_outlined, color: textColor, size: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Container Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _changeAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: isDark ? const Color(0xFF332014) : const Color(0xFFFDF0E9),
                              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                                  ? Text(
                                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC84C00),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cardBg, width: 1.5),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 2),
                            Text(user.email, style: TextStyle(fontSize: 12, color: subtextColor)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Color(0xFFC84C00)),
                                const SizedBox(width: 2),
                                Text('Lagos, Nigeria', style: TextStyle(fontSize: 11, color: subtextColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isVerified
                              ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                              : (isDark ? const Color(0xFF78350F) : const Color(0xFFFFFBEB)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: user.isVerified
                                ? (isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0))
                                : (isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              user.isVerified ? Icons.shield_outlined : Icons.info_outline,
                              size: 12,
                              color: user.isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.isVerified ? 'KYC Verified' : 'Unverified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: user.isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (user.licenseNumber != null && user.licenseNumber!.isNotEmpty)
                              ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9))
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (user.licenseNumber != null && user.licenseNumber!.isNotEmpty)
                                ? const Color(0xFFFDBA74)
                                : borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 12,
                              color: (user.licenseNumber != null && user.licenseNumber!.isNotEmpty)
                                  ? const Color(0xFFC84C00)
                                  : subtextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (user.licenseNumber != null && user.licenseNumber!.isNotEmpty)
                                  ? 'License Uploaded'
                                  : 'No License',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: (user.licenseNumber != null && user.licenseNumber!.isNotEmpty)
                                    ? const Color(0xFFC84C00)
                                    : subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats Container Box
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: statBoxBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('0', 'TRIPS', textColor, subtextColor),
                        Container(height: 24, width: 1, color: borderColor),
                        _buildStatItem('New', 'RATING', textColor, subtextColor),
                        Container(height: 24, width: 1, color: borderColor),
                        _buildStatItem(
                          user.createdAt != null ? user.createdAt!.year.toString() : '2026',
                          'MEMBER SINCE',
                          textColor,
                          subtextColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            // Account Options Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.calendar_month,
                    iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                    iconColor: const Color(0xFF3B82F6),
                    title: 'My Bookings',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () => context.go(AppRoutes.myBookings),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildOptionTile(
                    icon: Icons.favorite,
                    iconBg: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    title: 'Saved Cars',
                    subtitle: 'Your Favorites',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () => context.go(AppRoutes.favorites),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildOptionTile(
                    icon: Icons.credit_card,
                    iconBg: isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFFA855F7),
                    title: 'Payment Methods',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () => context.go(AppRoutes.wallet),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildOptionTile(
                    icon: Icons.account_balance_wallet,
                    iconBg: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    title: 'Wallet Balance',
                    subtitle: '₦${user.walletBalance.toStringAsFixed(0)} available',
                    badge: '₦${user.walletBalance.toStringAsFixed(0)}',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () => context.go(AppRoutes.wallet),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            // Preferences Options Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.notifications,
                    iconBg: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                    iconColor: const Color(0xFFC84C00),
                    title: 'Notifications',
                    countBadge: null,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () => context.go(AppRoutes.notificationCenter),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildOptionTile(
                    icon: Icons.language,
                    iconBg: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF6366F1),
                    title: 'Language',
                    subtitle: _selectedLanguage,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: _showLanguageModal,
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildOptionTile(
                    icon: Icons.directions_car_filled_outlined,
                    iconBg: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Switch to Fleet Partner Mode',
                    subtitle: 'Manage and list your vehicles',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Switched to Partner Mode. Access Partner App at port 8081.'),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0C1830),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: dividerColor),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconBtnBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                            color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF4B5563),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dark Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                              Text(isDark ? 'Dark theme active' : 'Light theme active', style: TextStyle(fontSize: 10, color: subtextColor)),
                            ],
                          ),
                        ),
                        Switch(
                          value: ref.watch(appThemeModeProvider) == ThemeMode.dark,
                          activeTrackColor: const Color(0xFFC84C00),
                          activeThumbColor: Colors.white,
                          onChanged: (val) {
                            ref.read(appThemeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('SECURITY & BIOMETRICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            // Security & Biometric Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.fingerprint_rounded, color: Color(0xFFC84C00), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Biometric & Fingerprint Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                              Text(
                                _isBiometricEnabled
                                    ? 'Locked to: ${_biometricEmail ?? user.email} (Active)'
                                    : 'Toggle ON to register and enable fingerprint login',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _isBiometricEnabled ? const Color(0xFF10B981) : subtextColor,
                                  fontWeight: _isBiometricEnabled ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isBiometricEnabled,
                          activeTrackColor: const Color(0xFFC84C00),
                          activeThumbColor: Colors.white,
                          onChanged: _handleToggleBiometrics,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            // Support Options Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: _buildOptionTile(
                icon: Icons.headset_mic,
                iconBg: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                iconColor: const Color(0xFFC84C00),
                title: 'Help & Support',
                subtitle: 'FAQs, chat, tickets',
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () => context.go(AppRoutes.helpSupport),
              ),
            ),
            const SizedBox(height: 16),
            // Log Out Button Container
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                onTap: _confirmLogout,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                ),
                title: const Text('Log Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        isPartner: false,
        onTap: (i) {
          const routes = [
            AppRoutes.home,
            AppRoutes.carListing,
            AppRoutes.myBookings,
            AppRoutes.favorites,
            AppRoutes.userProfile,
          ];
          if (i != 4) context.go(routes[i]);
        },
      ),
    );
  }

  Widget _buildStatItem(String val, String label, Color textColor, Color subtextColor) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: subtextColor)),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? badge,
    String? countBadge,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 10, color: subtextColor)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ),
          if (countBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFC84C00),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(countBadge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor),
        ],
      ),
    );
  }
}
