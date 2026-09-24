import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class PaymentWalletScreen extends ConsumerStatefulWidget {
  const PaymentWalletScreen({super.key});

  @override
  ConsumerState<PaymentWalletScreen> createState() => _PaymentWalletScreenState();
}

class _PaymentWalletScreenState extends ConsumerState<PaymentWalletScreen> {
  int _selectedPayTab = 2; // 0: Card, 1: Bank, 2: Wallet

  void _showTopUpModal(BuildContext context) {
    double selectedAmount = 50000.0;
    final customController = TextEditingController(text: '50000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Top Up Velix Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                  const SizedBox(height: 4),
                  const Text('Select or enter an amount to fund your wallet instantly', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 20),
                  // Quick Amount Chips Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [50000.0, 100000.0, 150000.0].map((amt) {
                      final isSelected = selectedAmount == amt;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedAmount = amt;
                            customController.text = amt.toStringAsFixed(0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFC84C00) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '₦${amt.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: customController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Deposit Amount (₦)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFC84C00)),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0.0;
                      setModalState(() => selectedAmount = parsed);
                    },
                  ),
                  const SizedBox(height: 24),
                  PartnerOrangeButton(
                    text: 'Confirm Deposit of ₦${selectedAmount.toStringAsFixed(0)}',
                    onPressed: () async {
                      final finalAmount = double.tryParse(customController.text) ?? selectedAmount;
                      if (finalAmount > 0) {
                        Navigator.pop(ctx);
                        await ref.read(userAuthProvider.notifier).topUpWallet(finalAmount);
                        if (!mounted) return;
                        setState(() {});
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('₦${finalAmount.toStringAsFixed(0)} deposited into your Velix Wallet!'),
                            backgroundColor: const Color(0xFF0C1830),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Secure Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
            Text('Complete your booking', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ),
      ),
      body: Column(
        children: [
          // 3-Step Stepper Line Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Color(0xFFC84C00)),
                const SizedBox(width: 4),
                const Text('Choose Car', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                Expanded(child: Container(height: 2, color: const Color(0xFFC84C00))),
                const Icon(Icons.check_circle, size: 14, color: Color(0xFFC84C00)),
                const SizedBox(width: 4),
                const Text('Trip Details', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                Expanded(child: Container(height: 2, color: const Color(0xFFC84C00))),
                const CircleAvatar(radius: 8, backgroundColor: Color(0xFF0C1830), child: Text('3', style: TextStyle(fontSize: 9, color: Colors.white))),
                const SizedBox(width: 4),
                const Text('Payment', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
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
                  const Text('Bank Name', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  // Available Balance Solid Terracotta Card
                  Builder(
                    builder: (context) {
                      final user = ref.watch(userAuthProvider).user;
                      final balance = user?.walletBalance ?? 0.0;
                      final amountToPay = totalCost > 0 ? totalCost : 135000.0;
                      final isSufficient = balance >= amountToPay;
                      final remaining = isSufficient ? balance - amountToPay : 0.0;
                      final needed = amountToPay - balance;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC84C00),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text('Available Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => _showTopUpModal(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('+ Top Up', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '₦${balance.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Payment Details Container Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Payment Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Amount to pay', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                    Text('₦${amountToPay.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Balance after payment', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                    Text(
                                      '₦${remaining.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSufficient ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!isSufficient) ...[
                            // Insufficient Balance Alert Card
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.priority_high, color: Colors.white, size: 14),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Insufficient Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                                        const SizedBox(height: 4),
                                        Text(
                                          'You need ₦${needed.toStringAsFixed(0)} more to complete this transaction.',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C), height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Sufficient Balance Badge
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF6EE7B7)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Your wallet has sufficient funds to complete this booking.',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),
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
                            text: isSufficient ? 'Pay ₦${amountToPay.toStringAsFixed(0)} from Wallet' : 'Fund Wallet (Deposit ₦${needed.toStringAsFixed(0)})',
                            onPressed: () async {
                              if (isSufficient) {
                                ref.read(bookingDraftProvider.notifier).setPaymentMethod('Velix Digital Wallet');
                                final user = ref.read(userAuthProvider).user;
                                final booking = await ref.read(bookingDraftProvider.notifier).confirmAndPay(user: user);
                                await ref.read(userAuthProvider.notifier).deductWallet(amountToPay, bookingId: booking?.id);
                                ref.invalidate(userBookingsProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Payment completed from Velix Wallet!'),
                                      backgroundColor: Color(0xFF0C1830),
                                    ),
                                  );
                                  context.go(AppRoutes.bookingConfirmation);
                                }
                              } else {
                                _showTopUpModal(context);
                              }
                            },
                          ),
                        ],
                      );
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
}
