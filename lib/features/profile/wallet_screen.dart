import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  String _activeFilter = 'All';
  final _amountController = TextEditingController();

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'tx_001',
      'title': 'Wallet Top Up (Card)',
      'date': 'Today, 04:30 PM',
      'amount': 50000.0,
      'isCredit': true,
      'status': 'Completed',
      'category': 'Deposit',
      'ref': 'VLX-DEP-88491',
    },
    {
      'id': 'tx_002',
      'title': 'Trip Payment — Mercedes GLE 450',
      'date': 'Yesterday, 11:15 AM',
      'amount': 63000.0,
      'isCredit': false,
      'status': 'Completed',
      'category': 'Bookings',
      'ref': 'VLX-TRP-44012',
    },
    {
      'id': 'tx_003',
      'title': 'Security Deposit Refund',
      'date': '08 Sep 2026, 02:20 PM',
      'amount': 25000.0,
      'isCredit': true,
      'status': 'Completed',
      'category': 'Refunds',
      'ref': 'VLX-RFD-19034',
    },
    {
      'id': 'tx_004',
      'title': 'Trip Payment — Toyota Camry 2024',
      'date': '01 Sep 2026, 09:00 AM',
      'amount': 35000.0,
      'isCredit': false,
      'status': 'Completed',
      'category': 'Bookings',
      'ref': 'VLX-TRP-22981',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showTopUpSheet(BuildContext context, double currentBalance) {
    final user = ref.read(userAuthProvider).user;
    if (user == null) {
      AuthGateModal.show(
        context: context,
        title: 'Sign In to Fund Wallet',
        message: 'Create an account or sign in to deposit funds, save payment cards, and enjoy 1-click rental checkouts.',
        onSignIn: () => context.go(AppRoutes.signIn),
        onRegister: () => context.go(AppRoutes.createAccount),
      );
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);

    double selectedAmount = 10000;
    _amountController.text = '10000';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
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
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Up Wallet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close, color: subtextColor, size: 20),
                      ),
                    ],
                  ),
                  Text(
                    'Add funds instantly using Debit Card, Bank Transfer, or USSD',
                    style: TextStyle(fontSize: 12, color: subtextColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select Amount (₦)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5000.0, 10000.0, 25000.0, 50000.0, 100000.0].map((amt) {
                      final isSel = selectedAmount == amt;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            selectedAmount = amt;
                            _amountController.text = amt.toStringAsFixed(0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFFC84C00)
                                : (isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? const Color(0xFFC84C00) : borderColor,
                            ),
                          ),
                          child: Text(
                            '₦${(amt / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        setSheetState(() => selectedAmount = parsed);
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Text('₦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final depositAmount = double.tryParse(_amountController.text.trim()) ?? selectedAmount;
                      if (depositAmount <= 0) {
                        VelixToast.showError(context, 'Please enter a valid amount');
                        return;
                      }
                      Navigator.pop(ctx);
                      _executeDeposit(depositAmount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC84C00),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Pay ₦${selectedAmount.toStringAsFixed(0)} with Paystack / Flutterwave',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _executeDeposit(double amount) {
    setState(() {
      _transactions.insert(0, {
        'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Instant Wallet Top Up',
        'date': 'Just now',
        'amount': amount,
        'isCredit': true,
        'status': 'Completed',
        'category': 'Deposit',
        'ref': 'VLX-DEP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      });
    });

    ref.read(userAuthProvider.notifier).topUpWallet(amount);

    VelixToast.showSuccess(context, '₦${amount.toStringAsFixed(0)} deposited to your Velix Wallet!');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final dividerColor = isDark ? const Color(0xFF262B38) : const Color(0xFFF3F4F6);

    final user = ref.watch(userAuthProvider).user;
    final balance = user?.walletBalance ?? 0.0;

    final filteredTx = _transactions.where((tx) {
      if (_activeFilter == 'All') return true;
      return tx['category'] == _activeFilter;
    }).toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.userProfile),
        ),
        title: Text(
          'My Wallet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showTopUpSheet(context, balance),
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC84C00)),
            tooltip: 'Fund Wallet',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC84C00),
                    Color(0xFF9A3400),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC84C00).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Available Balance',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Secured by Velix', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '₦${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showTopUpSheet(context, balance),
                          icon: const Icon(Icons.add, size: 16, color: Color(0xFFC84C00)),
                          label: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            VelixToast.showInfo(context, 'Virtual NUBAN account: 9035427435 (Wema Bank)');
                          },
                          icon: const Icon(Icons.account_balance, size: 16, color: Colors.white),
                          label: const Text('Bank Transfer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Saved Payment Methods Tile
            Text(
              'PAYMENT METHODS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.credit_card, color: Color(0xFF3B82F6), size: 20),
                    ),
                    title: Text('•••• •••• •••• 4242', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                    subtitle: Text('Mastercard • Expires 08/28', style: TextStyle(fontSize: 11, color: subtextColor)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    ),
                  ),
                  Divider(height: 1, color: dividerColor),
                  ListTile(
                    onTap: () => _showTopUpSheet(context, balance),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: Color(0xFFC84C00), size: 20),
                    ),
                    title: const Text('Add New Payment Card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFC84C00)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transactions Header & Category Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRANSACTION HISTORY',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5),
                ),
                Text(
                  '${filteredTx.length} records',
                  style: TextStyle(fontSize: 11, color: subtextColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Deposit', 'Bookings', 'Refunds'].map((f) {
                  final isSel = _activeFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFC84C00)
                              : (isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? const Color(0xFFC84C00) : borderColor),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? Colors.white : subtextColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Transaction History List
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: filteredTx.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 40, color: subtextColor),
                            const SizedBox(height: 10),
                            Text('No transactions found', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                            Text('Your wallet activity will appear here.', style: TextStyle(fontSize: 11, color: subtextColor)),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTx.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
                      itemBuilder: (ctx, idx) {
                        final tx = filteredTx[idx];
                        final isCredit = tx['isCredit'] as bool;
                        final amt = tx['amount'] as double;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isCredit
                                  ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                                  : (isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCredit ? Icons.arrow_downward : Icons.directions_car,
                              color: isCredit ? const Color(0xFF10B981) : const Color(0xFFC84C00),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            tx['title'] as String,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          subtitle: Text(
                            '${tx['date']} • ${tx['ref']}',
                            style: TextStyle(fontSize: 10, color: subtextColor),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? '+' : '-'}₦${amt.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tx['status'] as String,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: subtextColor),
                              ),
                            ],
                          ),
                        );
                      },
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
          if (i >= 0 && i < routes.length) {
            context.go(routes[i]);
          }
        },
      ),
    );
  }
}
