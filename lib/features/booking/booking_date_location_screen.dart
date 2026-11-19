import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class BookingDateLocationScreen extends ConsumerStatefulWidget {
  const BookingDateLocationScreen({super.key});

  @override
  ConsumerState<BookingDateLocationScreen> createState() => _BookingDateLocationScreenState();
}

class _BookingDateLocationScreenState extends ConsumerState<BookingDateLocationScreen> {
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 4));
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);
  bool _includeDriver = false;

  Future<void> _selectPickupDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: VelixPalette.copper),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        if (_returnDate.isBefore(_pickupDate)) {
          _returnDate = _pickupDate.add(const Duration(days: 1));
        }
      });
      ref.read(bookingDraftProvider.notifier).setDates(_pickupDate, _returnDate);
    }
  }

  Future<void> _selectReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: _pickupDate,
      lastDate: DateTime.now().add(const Duration(days: 120)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: VelixPalette.copper),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _returnDate = picked);
      ref.read(bookingDraftProvider.notifier).setDates(_pickupDate, _returnDate);
    }
  }

  static DateTime _at(DateTime day, TimeOfDay time) => DateTime(day.year, day.month, day.day, time.hour, time.minute);

  /// The pickers keep date and time separately; the booking needs both combined.
  void _continue() {
    final pickup = _at(_pickupDate, _pickupTime);
    final dropoff = _at(_returnDate, _returnTime);
    if (pickup.isBefore(DateTime.now())) {
      VelixToast.showInfo(context, 'Please choose a pickup time in the future.');
      return;
    }
    if (!dropoff.isAfter(pickup)) {
      VelixToast.showInfo(context, 'The return time must be after the pickup time.');
      return;
    }
    ref.read(bookingDraftProvider.notifier).setDates(pickup, dropoff);
    context.go(AppRoutes.bookingSummary);
  }

  Future<void> _selectPickupTime() async {
    final picked = await showTimePicker(context: context, initialTime: _pickupTime);
    if (picked != null) setState(() => _pickupTime = picked);
  }

  Future<void> _selectReturnTime() async {
    final picked = await showTimePicker(context: context, initialTime: _returnTime);
    if (picked != null) setState(() => _returnTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final car = draft.selectedCar;
    final breakdown = draft.breakdown;

    return Scaffold(
      backgroundColor: VelixPalette.paper,
      appBar: AppBar(
        backgroundColor: VelixPalette.paper,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: VelixPalette.stone, borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: VelixPalette.ink, size: 16),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.carListing);
              }
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Book a Car', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
            Text(car?.name ?? 'Mercedes-Benz GLE 450', style: const TextStyle(fontSize: 11, color: VelixPalette.muted)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 3-Step Stepper Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              children: [
                _buildStepCircle('1', 'Dates', true),
                Expanded(child: Container(height: 2, color: VelixPalette.line)),
                _buildStepCircle('2', 'Extras', false),
                Expanded(child: Container(height: 2, color: VelixPalette.line)),
                _buildStepCircle('3', 'Payment', false),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Vehicle Mini Banner Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: VelixPalette.ink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            car?.imageUrl ?? CarImageCatalog.mercedesGLE,
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 60,
                              color: Colors.white12,
                              child: const Icon(Icons.directions_car, color: VelixPalette.paper),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car?.name ?? 'Mercedes-Benz GLE 450',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${car?.category ?? 'SUV'} • ${car?.transmission ?? 'Automatic'}',
                                style: const TextStyle(fontSize: 10, color: VelixPalette.lineStrong),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₦${(car?.pricePerDay ?? 48000).toStringAsFixed(0)}/day',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.copper),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('• RENTAL DATES & TIMES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.ink, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectPickupDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: VelixPalette.paper,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: VelixPalette.copper, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: VelixPalette.copper),
                                    SizedBox(width: 4),
                                    Text('PICKUP DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(DateFormat('EEE, MMM d').format(_pickupDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                                GestureDetector(
                                  onTap: _selectPickupTime,
                                  child: Text(_pickupTime.format(context), style: const TextStyle(fontSize: 10, color: VelixPalette.copper, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectReturnDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: VelixPalette.paper,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: VelixPalette.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: VelixPalette.muted),
                                    SizedBox(width: 4),
                                    Text('RETURN DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelixPalette.muted)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(DateFormat('EEE, MMM d').format(_returnDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                                GestureDetector(
                                  onTap: _selectReturnTime,
                                  child: Text(_returnTime.format(context), style: const TextStyle(fontSize: 10, color: VelixPalette.muted)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: VelixPalette.copperSoft, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14, color: VelixPalette.copper),
                        const SizedBox(width: 4),
                        Text('${breakdown.days} Days Duration', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('• PICKUP & RETURN LOCATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.ink, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: VelixPalette.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: VelixPalette.line)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: VelixPalette.copperSoft, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.location_on, color: VelixPalette.copper, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PICKUP & RETURN LOCATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelixPalette.lineStrong)),
                              Text(draft.pickupLocation, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('• CHAUFFEUR OPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelixPalette.ink, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: VelixPalette.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: VelixPalette.line)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: VelixPalette.copperSoft, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.person, color: VelixPalette.copper, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Include Professional Chauffeur', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                              Text('Sent to the partner as a request; arranged with them', style: TextStyle(fontSize: 10, color: VelixPalette.muted)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _includeDriver,
                          activeTrackColor: VelixPalette.copper,
                          onChanged: (val) {
                            setState(() => _includeDriver = val);
                            ref.read(bookingDraftProvider.notifier).toggleChauffeur(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: VelixPalette.paper, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -4))]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ESTIMATED SUBTOTAL', style: TextStyle(fontSize: 9, color: VelixPalette.muted, letterSpacing: 0.5)),
                    Text('₦${breakdown.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                    Text('${breakdown.days} days rental', style: const TextStyle(fontSize: 9, color: VelixPalette.muted)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _continue,
                  icon: const Text('Continue to Extras', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
                  label: const Icon(Icons.arrow_forward, size: 16, color: VelixPalette.paper),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelixPalette.copper,
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

  Widget _buildStepCircle(String number, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? VelixPalette.copper : VelixPalette.line,
          child: Text(number, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? VelixPalette.paper : VelixPalette.muted)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? VelixPalette.copper : VelixPalette.muted)),
      ],
    );
  }
}
