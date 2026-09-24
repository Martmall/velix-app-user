import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class SetUpScreen extends ConsumerStatefulWidget {
  const SetUpScreen({super.key});

  @override
  ConsumerState<SetUpScreen> createState() => _SetUpScreenState();
}

class _SetUpScreenState extends ConsumerState<SetUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _licenseController;
  late final TextEditingController _emergencyController;
  String _selectedCity = 'Lagos';
  String? _avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userAuthProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _licenseController = TextEditingController(text: user?.licenseNumber ?? '');
    _emergencyController = TextEditingController(text: user?.phone ?? '');
    _avatarUrl = user?.avatarUrl;
  }

  Future<void> _pickAvatar() async {
    final url = await ImagePickerModal.show(
      context: context,
      title: 'Upload Profile Photo',
      category: 'avatar',
    );
    if (url != null && mounted) {
      setState(() => _avatarUrl = url);
      await ref.read(userAuthProvider.notifier).updateAvatar(url);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final fullName = _nameController.text.trim();
      final license = _licenseController.text.trim();
      final phone = _emergencyController.text.trim();
      final currentUser = ref.read(userAuthProvider).user;

      await ref.read(userAuthProvider.notifier).updateProfile(
        fullName: fullName,
        email: currentUser?.email ?? '',
        phone: phone.isNotEmpty ? phone : (currentUser?.phone ?? ''),
        licenseNumber: license,
        avatarUrl: _avatarUrl,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        context.go(AppRoutes.identityVerification);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0C1830), size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.createAccount);
            }
          },
        ),
        title: const Text(
          'Account Setup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Camera Avatar Badge Upload
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFFFDF0E9),
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? Text(
                              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC84C00),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickAvatar,
                child: const Text(
                  'Tap to Upload Profile Photo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                ),
              ),
              const SizedBox(height: 24),
              // Elevated Container Card
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
                    const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                      decoration: _buildInputDecoration('Enter full name'),
                      validator: (val) => val == null || val.isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Preferred City', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      decoration: _buildInputDecoration('Select City'),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14, fontWeight: FontWeight.bold),
                      items: ['Lagos', 'Abuja', 'Port Harcourt', 'Ibadan']
                          .map((city) => DropdownMenuItem(value: city, child: Text('📍 $city')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCity = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Driver's License Number", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _licenseController,
                      style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                      decoration: _buildInputDecoration('DL-90821-XYZ'),
                      validator: (val) => val == null || val.isEmpty ? 'License number required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Emergency Contact Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emergencyController,
                      style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                      decoration: _buildInputDecoration('+234 801 234 5678'),
                    ),
                    const SizedBox(height: 28),
                    PartnerOrangeButton(
                      text: 'Complete Setup',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF4F6F9),
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
    );
  }
}
