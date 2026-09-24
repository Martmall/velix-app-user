import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _driverAddon = false;
  bool _childSeatAddon = false;
  final _promoController = TextEditingController();

  void _applyPromoCode() {
    final code = _promoController.text.trim();
    if (code.isNotEmpty) {
      ref.read(bookingDraftProvider.notifier).setPromoCode(code);
      VelixToast.showSuccess(context, 'Promo code "$code" applied!');
    }
  }

  void _handleProceedToPayment() {
    final user = ref.read(userAuthProvider).user;
    final isVerified = user?.isVerified ?? false;

    if (!isVerified) {
      _showVerificationRequiredDialog();
      return;
    }

    context.go(AppRoutes.paymentCard);
  }

  void _showVerificationRequiredDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF332014) : const Color(0xFFFDF0E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_outlined, color: Color(0xFFC84C00), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Verification Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0C1830),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Before booking a luxury vehicle, Velix administrators must verify and approve your driver\'s license and identity.\n\nPlease upload your verification documents or wait for administrator approval.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Later',
              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.go(AppRoutes.identityVerification);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC84C00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Verify Identity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final car = draft.selectedCar;
    final breakdown = draft.breakdown;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.bookingDateLocation),
        ),
        title: Text(
          'Add-ons & Pricing Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 3-Step Stepper Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                Text('Vehicle', style: TextStyle(fontSize: 11, color: subtextColor)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 3, decoration: BoxDecoration(color: const Color(0xFFC84C00), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 8),
                const Text('Add-ons', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 3, decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 8),
                Text('Payment', style: TextStyle(fontSize: 11, color: subtextColor)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0C1830),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            car?.imageUrl ?? CarImageCatalog.mercedesGLE,
                            width: 75,
                            height: 55,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 75,
                              height: 55,
                              color: Colors.white12,
                              child: const Icon(Icons.directions_car, color: Colors.white70, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(car?.name ?? 'Mercedes-Benz GLE 450', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('${car?.brand ?? "Mercedes"} · ${car?.category ?? "Luxury SUV"}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text('₦${(car?.pricePerDay ?? 48000).toStringAsFixed(0)}/day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFDBA74))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('MANDATORY PROTECTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  _buildMandatoryAddonCard(
                    icon: Icons.security,
                    title: 'Standard Damage Collision Waiver',
                    subtitle: 'Covers major accidental vehicle body damage & third party liability',
                    price: 'Included',
                    cardBg: cardBg,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(height: 10),
                  _buildMandatoryAddonCard(
                    icon: Icons.phonelink_lock,
                    title: 'Velix Smart Keyless Access',
                    subtitle: 'Remote app locking, vehicle GPS tracking & emergency immobilization',
                    price: 'Included',
                    cardBg: cardBg,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(height: 20),
                  Text('OPTIONAL EXTRAS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  _buildAddonCard(
                    icon: Icons.person_pin,
                    title: 'Executive Dedicated Chauffeur',
                    subtitle: 'Professional vetted driver for entire booking duration',
                    price: '₦20,000 / day',
                    value: _driverAddon,
                    cardBg: cardBg,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onChanged: (val) {
                      setState(() => _driverAddon = val);
                      ref.read(bookingDraftProvider.notifier).toggleChauffeur(val);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildAddonCard(
                    icon: Icons.child_care,
                    title: 'Child Safety Car Seat',
                    subtitle: 'Certified ISOFIX infant/child protection seat',
                    price: '₦5,000 / day',
                    value: _childSeatAddon,
                    cardBg: cardBg,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onChanged: (val) {
                      setState(() => _childSeatAddon = val);
                      ref.read(bookingDraftProvider.notifier).toggleChildSeat(val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('PRICE BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow('Base Rental (${draft.totalDays} days)', '₦${breakdown.baseRental.toStringAsFixed(0)}', textColor, subtextColor),
                        if (breakdown.chauffeurTotal > 0) ...[
                          const SizedBox(height: 8),
                          _buildPriceRow('Executive Chauffeur', '₦${breakdown.chauffeurTotal.toStringAsFixed(0)}', textColor, subtextColor),
                        ],
                        if (breakdown.childSeatTotal > 0) ...[
                          const SizedBox(height: 8),
                          _buildPriceRow('Child Safety Seat', '₦${breakdown.childSeatTotal.toStringAsFixed(0)}', textColor, subtextColor),
                        ],
                        const SizedBox(height: 8),
                        _buildPriceRow('Service & Platform Fee (5%)', '₦${breakdown.serviceFee.toStringAsFixed(0)}', textColor, subtextColor),
                        const SizedBox(height: 8),
                        _buildPriceRow('VAT (7.5%)', '₦${breakdown.vat.toStringAsFixed(0)}', textColor, subtextColor),
                        if (breakdown.discount > 0) ...[
                          const SizedBox(height: 8),
                          _buildPriceRow('Discount Applied', '-₦${breakdown.discount.toStringAsFixed(0)}', textColor, subtextColor),
                        ],
                        Divider(height: 20, color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                        _buildPriceRow('Refundable Security Deposit', '₦${breakdown.securityDeposit.toStringAsFixed(0)}', textColor, subtextColor),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promoController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Try code VELO5K',
                                  hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _applyPromoCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC84C00),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                elevation: 0,
                              ),
                              child: const Text('Apply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Sticky Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total to pay', style: TextStyle(fontSize: 9, color: subtextColor)),
                    Text('₦${breakdown.grandTotal.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _handleProceedToPayment,
                  icon: const Text('Proceed to Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  label: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC84C00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandatoryAddonCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFFDF0E9), borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Icon(icon, color: const Color(0xFFC84C00), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MANDATORY',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: subtextColor)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text('Included', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required bool value,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB), width: value ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFFDF0E9), borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Icon(icon, color: const Color(0xFFC84C00), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: subtextColor)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: const Color(0xFFC84C00),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color textColor, Color subtextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: subtextColor)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }
}
