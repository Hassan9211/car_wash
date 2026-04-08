import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingReviewScreen extends StatefulWidget {
  const BookingReviewScreen({
    super.key,
    required this.order,
  });

  final BookingOrderItem order;

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  late final TextEditingController _reviewController;
  late int _selectedRating;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.order.reviewRating ?? 5;
    _reviewController = TextEditingController(text: widget.order.reviewText);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await BookingOrdersStore.instance.updateReview(
        widget.order.id,
        reviewRating: _selectedRating,
        reviewText: _reviewController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      context.pop<bool>(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      key: const Key('booking_review_back_button'),
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppButtonColors.actionForeground,
                        size: 18,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Ratings and Review',
                          key: Key('booking_review_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 22, 14, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'How was your Service Provider?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your overall ratings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9C9C9C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return IconButton(
                          key: Key('booking_review_star_$starIndex'),
                          onPressed: () {
                            setState(() {
                              _selectedRating = starIndex;
                            });
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            starIndex <= _selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 38,
                            color: AppButtonColors.primaryBackground,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add detailed review',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('booking_review_text_field'),
                      controller: _reviewController,
                      cursorColor: AppButtonColors.primaryBackground,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter here...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFC0C0C0),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE4E4E4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppButtonColors.primaryBackground,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    AppPrimaryButton(
                      key: const Key('booking_review_done_button'),
                      label: _isSubmitting ? 'Saving...' : 'Done',
                      onPressed: _isSubmitting ? null : _submitReview,
                      height: 46,
                      borderRadius: 6,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
