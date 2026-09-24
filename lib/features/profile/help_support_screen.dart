import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  int? _expandedFaq;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final iconBtnBg = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);

    final ticketsAsync = ref.watch(userSupportTicketsProvider);
    final tickets = ticketsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const Center(
          child: VelixBackButton(fallbackRoute: AppRoutes.userProfile),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Need Urgent Help Solid Terracotta Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFC84C00),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.headset_mic, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need urgent help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('Our support team is available 24/7', style: TextStyle(fontSize: 10, color: Colors.white70)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Call Support: 0800-VELIX', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('FREQUENTLY ASKED QUESTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            // FAQs Container Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildFaqItem(0, Icons.calendar_today, 'How do I cancel a booking?', 'You can cancel up to 24 hours before pickup for a full refund.', textColor, subtextColor, isDark),
                  Divider(height: 1, color: dividerColor),
                  _buildFaqItem(1, Icons.directions_car, 'What if the car has an issue?', 'Contact your host immediately or use the Trip Update tool in the app to notify support.', textColor, subtextColor, isDark),
                  Divider(height: 1, color: dividerColor),
                  _buildFaqItem(2, Icons.shield_outlined, 'How does insurance work?', 'Full insurance cover protects against collision and theft with zero excess.', textColor, subtextColor, isDark),
                  Divider(height: 1, color: dividerColor),
                  _buildFaqItem(3, Icons.credit_card, 'How do I add a payment method?', 'Go to Profile > Payment Methods to add cards or top up your wallet.', textColor, subtextColor, isDark),
                  Divider(height: 1, color: dividerColor),
                  _buildFaqItem(4, Icons.access_time, 'Can I extend my rental?', 'Yes, extensions can be requested directly from your active trip dashboard.', textColor, subtextColor, isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('CONTACT US', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            // Contact Us Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => context.go(AppRoutes.liveChat),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconBtnBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.chat_bubble_outline, color: textColor, size: 20),
                    ),
                    title: Text('Start Live Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                    subtitle: const Row(
                      children: [
                        CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text('Online ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        Text('Support Agent Ready', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor),
                  ),
                  Divider(height: 1, color: dividerColor),
                  ListTile(
                    onTap: () => context.go(AppRoutes.submitTicket),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFFC84C00), size: 20),
                    ),
                    title: Text('Submit a Ticket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                    subtitle: Text('Describe your issue in detail', style: TextStyle(fontSize: 10, color: subtextColor)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // My Recent Tickets Section
            if (tickets.isNotEmpty) ...[
              Text('MY RECENT SUPPORT TICKETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtextColor, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              ...tickets.map((t) {
                final isResolved = t.status == TicketStatus.resolved;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isResolved
                                  ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                                  : (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isResolved
                                    ? (isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0))
                                    : (isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A)),
                              ),
                            ),
                            child: Text(
                              isResolved ? 'Resolved' : 'In Review',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isResolved ? const Color(0xFF10B981) : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(t.subject, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 4),
                      Text(t.description, style: TextStyle(fontSize: 12, color: subtextColor)),
                      const SizedBox(height: 6),
                      Text('Category: ${t.category}', style: TextStyle(fontSize: 10, color: subtextColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
            ],
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

  Widget _buildFaqItem(int index, IconData icon, String question, String answer, Color textColor, Color subtextColor, bool isDark) {
    final isExpanded = _expandedFaq == index;
    return Column(
      children: [
        ListTile(
          onTap: () => setState(() => _expandedFaq = isExpanded ? null : index),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFC84C00), size: 18),
          ),
          title: Text(question, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
          trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: subtextColor),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 54.0, right: 16.0, bottom: 12.0),
            child: Text(answer, style: TextStyle(fontSize: 11, color: subtextColor, height: 1.4)),
          ),
      ],
    );
  }
}
