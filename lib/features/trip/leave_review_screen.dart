import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class LeaveReviewScreen extends ConsumerStatefulWidget {
  const LeaveReviewScreen({super.key});

  @override
  ConsumerState<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends ConsumerState<LeaveReviewScreen> {
  int _overallRating = 5;
  int _cleanlinessRating = 5;
  int _comfortRating = 5;
  int _valueRating = 5;
  bool _postPublicly = true;
  final _commentController = TextEditingController();
  final List<String> _photos = [];
  bool _isLoading = false;

  Future<void> _addPhoto() async {
    // Reviews are text + rating only on the backend (POST /bookings/:id/reviews).
    VelixToast.showInfo(context, 'Photos on reviews are coming soon.');
  }

  void _submitReview() async {
    final trip = ref.read(lastCompletedTripProvider);
    if (trip == null) {
      VelixToast.showInfo(context, 'You can review a trip once it has been completed.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(supportRepositoryProvider).submitReview(
            bookingId: trip.id,
            rating: _overallRating,
            comment: _commentController.text.trim(),
          );
      if (!mounted) return;
      VelixToast.showSuccess(context, 'Thank you for your rating & feedback!');
      context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) VelixToast.showError(context, ApiClient.parseErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(lastCompletedTripProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                context.go(AppRoutes.myBookings);
              }
            },
          ),
        ),
        title: const Text(
          'Write a Review',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Review Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      CarImageCatalog.toyotaPrado,
                      width: 70,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 50,
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.directions_car, size: 36, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip?.carName ?? 'Your last trip', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                        const SizedBox(height: 2),
                        Text(
                          trip == null ? 'No completed trip yet' : '${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('3 available', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Overall Experience Rating Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Text('How was your experience?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                  const SizedBox(height: 4),
                  const Text('Tap a star to rate your overall trip', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        icon: Icon(
                          i < _overallRating ? Icons.star : Icons.star_border,
                          size: 32,
                          color: i < _overallRating ? Colors.amber : const Color(0xFFD1D5DB),
                        ),
                        onPressed: () => setState(() => _overallRating = i + 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Very Good', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Rate by Category Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RATE BY CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  _buildCategoryRatingRow('Cleanliness', _cleanlinessRating, (val) => setState(() => _cleanlinessRating = val)),
                  const Divider(color: Color(0xFFE5E7EB)),
                  _buildCategoryRatingRow('Comfort', _comfortRating, (val) => setState(() => _comfortRating = val)),
                  const Divider(color: Color(0xFFE5E7EB)),
                  _buildCategoryRatingRow('Value', _valueRating, (val) => setState(() => _valueRating = val)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Your Review Textarea Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOUR REVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          maxLength: 500,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0C1830)),
                          decoration: const InputDecoration(
                            hintText: 'Share your experience... What did you enjoy most about this rental?',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                        const Text('0/500', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Add Photos Section Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ADD PHOTOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
                      Text('Optional - Up to 5', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _addPhoto,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF0E9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.4)),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Color(0xFFC84C00), size: 16),
                                SizedBox(height: 2),
                                Text('Add Photo', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ..._photos.map(
                          (photo) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    photo,
                                    width: 58,
                                    height: 58,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _photos.remove(photo)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Post Publicly Switch Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Post Publicly', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                        SizedBox(height: 2),
                        Text('Others can see your review on the listing', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Switch(
                    value: _postPublicly,
                    activeTrackColor: const Color(0xFFC84C00),
                    onChanged: (val) => setState(() => _postPublicly = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PartnerOrangeButton(
              text: 'Submit Review',
              isLoading: _isLoading,
              onPressed: _submitReview,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRatingRow(String title, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
        Row(
          children: List.generate(
            5,
            (i) => GestureDetector(
              onTap: () => onChanged(i + 1),
              child: Icon(
                i < value ? Icons.star : Icons.star_border,
                size: 18,
                color: i < value ? Colors.amber : const Color(0xFFD1D5DB),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
