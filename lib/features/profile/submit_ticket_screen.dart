import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class SubmitTicketScreen extends ConsumerStatefulWidget {
  const SubmitTicketScreen({super.key});

  @override
  ConsumerState<SubmitTicketScreen> createState() => _SubmitTicketScreenState();
}

class _SubmitTicketScreenState extends ConsumerState<SubmitTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Booking & Scheduling';
  String? _attachmentUrl;
  bool _isLoading = false;

  final List<String> _categories = [
    'Booking & Scheduling',
    'Vehicle Keyless Access',
    'Billing & Invoicing',
    'Vehicle Condition & Damage',
    'Refund & Cancellation',
    'Account & Verification',
  ];

  Future<void> _pickAttachment() async {
    final photo = await ImagePickerModal.show(
      context: context,
      title: 'Attach Photo / Receipt',
    );
    if (photo != null && mounted) {
      setState(() => _attachmentUrl = photo);
      VelixToast.showInfo(context, 'Screenshot / photo attached!');
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = ref.read(userAuthProvider).user;

      try {
        final created = await ref.read(supportRepositoryProvider).createSupportTicket(
              userId: user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
              subject: _subjectController.text.trim(),
              category: _selectedCategory,
              description: _descriptionController.text.trim(),
              attachmentUrl: _attachmentUrl,
            );
        if (mounted) {
          setState(() => _isLoading = false);
          VelixToast.showSuccess(
            context,
            'Support ticket #${created.id} submitted! Team assigned.',
          );
          context.go(AppRoutes.helpSupport);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          VelixToast.showError(context, 'Failed to submit ticket: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.helpSupport),
        ),
        title: Text(
          'Submit Support Ticket',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Open Support Case',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 6),
                Text(
                  'Our dedicated concierge team is active 24/7 to resolve any issue promptly.',
                  style: TextStyle(fontSize: 13, color: subtextColor),
                ),
                const SizedBox(height: 20),
                // Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: cardBg,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        ),
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: textColor))))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val!),
                      ),
                      const SizedBox(height: 18),
                      Text('Subject', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _subjectController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Brief summary of the issue...',
                          hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF), fontSize: 13),
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a subject' : null,
                      ),
                      const SizedBox(height: 18),
                      Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Provide as many details as possible (booking ID, car model, location, etc.)...',
                          hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF), fontSize: 13),
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please describe your issue' : null,
                      ),
                      const SizedBox(height: 18),
                      Text('Attachment (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickAttachment,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _attachmentUrl != null ? const Color(0xFF10B981) : borderColor,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _attachmentUrl != null ? Icons.check_circle : Icons.attach_file,
                                color: _attachmentUrl != null ? const Color(0xFF10B981) : const Color(0xFFC84C00),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _attachmentUrl != null ? 'File Attached (Tap to change)' : 'Upload Receipt / Screenshot',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _attachmentUrl != null ? const Color(0xFF10B981) : textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC84C00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Submit Ticket to Support',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
