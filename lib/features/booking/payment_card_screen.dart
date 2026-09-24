import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class PaymentCardScreen extends ConsumerStatefulWidget {
  const PaymentCardScreen({super.key});

  @override
  ConsumerState<PaymentCardScreen> createState() => _PaymentCardScreenState();
}

class _PaymentCardScreenState extends ConsumerState<PaymentCardScreen> {
  int _selectedPayTab = 0; // 0: Card, 1: Bank, 2: Wallet
  bool _useSavedCard = true;
  bool _saveCardToggle = true;
  bool _isLoading = false;

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  void _processPayment() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(AppRoutes.paymentOtp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final car = draft.selectedCar;
    final totalCost = draft.breakdown.grandTotal;
    final days = draft.breakdown.days;
    final location = draft.pickupLocation.isNotEmpty ? draft.pickupLocation : 'Ikeja, Lagos';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0C1830), size: 16),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.bookingSummary);
              }
            },
          ),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 3-Step Stepper Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              children: [
                _buildStepCircle('1', 'Dates', false),
                Expanded(child: Container(height: 2, color: const Color(0xFFC84C00))),
                _buildStepCircle('2', 'Extras', false),
                Expanded(child: Container(height: 2, color: const Color(0xFFC84C00))),
                _buildStepCircle('3', 'Payment', true),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Vehicle Summary White Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            car?.imageUrl ?? CarImageCatalog.toyotaPrado,
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 60,
                              color: const Color(0xFFF3F4F6),
                              child: const Icon(Icons.directions_car, size: 36, color: Color(0xFF9CA3AF)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car?.name ?? 'Toyota Land Cruiser Prado',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text('📅 $days Days | 📍 $location', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                              const SizedBox(height: 4),
                              const Text('Total Amount', style: TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
                              Text('₦${totalCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Pay With', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                  const SizedBox(height: 10),
                  // Pay With Tabs Segment
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildPayTab(0, Icons.credit_card, 'Card', () => context.go(AppRoutes.paymentCard))),
                        Expanded(child: _buildPayTab(1, Icons.account_balance, 'Bank Transfer', () => context.go(AppRoutes.paymentBank))),
                        Expanded(child: _buildPayTab(2, Icons.account_balance_wallet, 'Wallet', () => context.go(AppRoutes.paymentWallet))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('SAVED CARD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  // Saved Card Box
                  GestureDetector(
                    onTap: () => setState(() => _useSavedCard = true),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _useSavedCard ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB), width: _useSavedCard ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('VISA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic)),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('•••• •••• •••• 4523', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0C1830), letterSpacing: 1.0)),
                                SizedBox(height: 2),
                                Text('Expires 09/28 . Oluwaseun T.', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          Icon(
                            _useSavedCard ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: _useSavedCard ? const Color(0xFFC84C00) : const Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Or use a new card', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('NEW CARD DETAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  // New Card Inputs Form
                  const Text('Card Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                    decoration: _buildInputDecoration('0000 0000 0000 0000'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expiry Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _expiryController,
                              style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                              decoration: _buildInputDecoration('MM/YY'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CVV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _cvvController,
                              obscureText: true,
                              style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                              decoration: _buildInputDecoration('•••'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Name on Card', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _cardHolderController,
                    style: const TextStyle(color: Color(0xFF0C1830), fontSize: 14),
                    decoration: _buildInputDecoration('e.g. Oluwaseun Temilola'),
                  ),
                  const SizedBox(height: 16),
                  // Save Card Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF0E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.lock, color: Color(0xFFC84C00), size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Save this card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                              Text('For faster future payments', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        Switch(
                          value: _saveCardToggle,
                          activeTrackColor: const Color(0xFFC84C00),
                          onChanged: (val) => setState(() => _saveCardToggle = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 12, color: Color(0xFF6B7280)),
                      SizedBox(width: 4),
                      Text('256-bit SSL . Secured by Velix', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PartnerOrangeButton(
                    text: 'Pay ₦${totalCost.toStringAsFixed(0)}',
                    isLoading: _isLoading,
                    onPressed: () {
                      ref.read(bookingDraftProvider.notifier).setPaymentMethod('Debit Card');
                      _processPayment();
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayTab(int index, IconData icon, String label, VoidCallback onTap) {
    final isSelected = _selectedPayTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPayTab = index);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isSelected ? const Color(0xFF0C1830) : const Color(0xFF6B7280)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0C1830) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
    );
  }

  Widget _buildStepCircle(String number, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB),
          child: Text(number, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.white : const Color(0xFF6B7280))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? const Color(0xFFC84C00) : const Color(0xFF6B7280))),
      ],
    );
  }
}
