import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/feedback_model.dart';
import '../../providers/feedback_provider.dart';

class FeedbackScreen extends StatefulWidget {
  final String? initialOrderId; //why String?: bcs initialOrderId is an optional parameters
  const FeedbackScreen({super.key, this.initialOrderId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedRating = 0;
  DeliveredOrder? _selectedOrder;
  bool _isAnonymous = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit(FeedbackProvider provider, DeliveredOrder targetOrder) {
    if (_selectedRating < 1 || _selectedRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating (1–5) before submitting.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_commentController.text.trim().length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review comment cannot exceed 500 characters.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    provider.submitReview(
      order: targetOrder,
      rating: _selectedRating,
      comment: _commentController.text,
      isAnonymous: _isAnonymous,
    );

    setState(() {
      _selectedOrder = null;
      _selectedRating = 0;
      _commentController.clear();
      _isAnonymous = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your review has been submitted.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = context.watch<FeedbackProvider>();
    final eligibleOrders = feedbackProvider.eligibleOrders;
    final reviews = feedbackProvider.reviews;
    final hasEligible = eligibleOrders.isNotEmpty;

    if (hasEligible && (_selectedOrder == null || !eligibleOrders.contains(_selectedOrder))) {
      if(widget.initialOrderId != null){
        _selectedOrder = eligibleOrders.firstWhere(
          (o) => o.orderID == widget.initialOrderId, orElse: () => eligibleOrders.first,
        );
      }
      else{
        _selectedOrder = eligibleOrders.first;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/kerepekhub_logo_font.png',
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Text(
                'KerepekHub',
                style: TextStyle(
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width:6),
            const Text(
              'Reviews',
              style: TextStyle(
                color: Color(0xFF222222),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rate your order',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFF4C430), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${feedbackProvider.averageRating.toStringAsFixed(1)} (${reviews.length})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCCCCCC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasEligible)
                    const Text(
                      'All delivered orders have been reviewed. Thank you!',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E9E5B),
                      ),
                    )
                  else ...[
                    const Text(
                      'Select delivered order',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<DeliveredOrder>(
                      initialValue: _selectedOrder,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFCCCCCC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF222222),
                            width: 1.2,
                          ),
                        ),
                      ),
                      items: eligibleOrders.map((order) {
                        return DropdownMenuItem(
                          value: order,
                          child: Text(
                            '${order.orderID} • ${order.itemsSummary.join(', ')}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF222222),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedOrder = val),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        iconSize: 32,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          starValue <= _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: starValue <= _selectedRating
                              ? const Color(0xFFF4C430)
                              : const Color(0xFF888888),
                        ),
                        onPressed: hasEligible
                            ? () => setState(() => _selectedRating = starValue)
                            : null,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    enabled: hasEligible,
                    maxLength: 500,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText:
                          'Share your feedback for your order (optional)...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF222222),
                          width: 1.2,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Post Anonymously
                  InkWell(
                    onTap: hasEligible
                        ? () => setState(() => _isAnonymous = !_isAnonymous)
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 48,
                          child: Checkbox(
                            value: _isAnonymous,
                            activeColor: const Color(0xFF222222),
                            onChanged: hasEligible
                                ? (val) => setState(
                                    () => _isAnonymous = val ?? false)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Post anonymously',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: hasEligible
                                ? const Color(0xFF333333)
                                : const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF222222),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFCCCCCC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: hasEligible && _selectedOrder != null
                          ? () =>
                              _handleSubmit(feedbackProvider, _selectedOrder!)
                          : null,
                      child: const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Recent Shop Reviews',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final rev = reviews[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rev.custName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF222222),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFFF4C430), size: 16),
                              const SizedBox(width: 3),
                              Text(
                                '${rev.rating}/5',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF222222),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rev.itemsOrdered,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E9E5B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rev.comment,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rev.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}