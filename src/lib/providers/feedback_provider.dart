import 'package:flutter/material.dart';
import '../models/feedback_model.dart';

class FeedbackProvider extends ChangeNotifier {
  final List<DeliveredOrder> _orders = [
    DeliveredOrder(
      orderID: 'ORD-1042',
      custName: 'Nic Co',
      itemsSummary: [
        '1x Crunchy Nestum Milk (Packet)'
      ],
      totalMyr: 9.00,
      date: '15 Nov 2026',
      isReviewed: false,
    ),
    DeliveredOrder(
      orderID: 'ORD-1038',
      custName: 'Nic Co',
      itemsSummary: [
        '2x Seaweed Spicy Cheese (Packet)'
      ],
      totalMyr: 19.00,
      date: '12 Nov 2026',
      isReviewed: false,
    ),
  ];

  final List<CustomerReview> _reviews = [
    const CustomerReview(
      id: 'REV-001',
      orderID: 'ORD-1020',
      custName: 'Anonymous',
      itemsOrdered: 'Crunchy Spicy Cheese (Packet)',
      rating: 5,
      comment:
          'Super crispy and generous spicy cheese coating! Will definitely reorder.',
      date: '06 Nov 2026',
    ),
    const CustomerReview(
      id: 'REV-002',
      orderID: 'ORD-1018',
      custName: 'Della',
      itemsOrdered: 'Seaweed Original (Packet)',
      rating: 4,
      comment: 'Fresh packaging and fast self-collection pickup at Serooja.',
      date: '31 Oct 2026',
    ),
  ];

  List<DeliveredOrder> get eligibleOrders =>
      _orders.where((o) => !o.isReviewed).toList();

  List<CustomerReview> get reviews => List.unmodifiable(_reviews);

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  void submitReview({
    required DeliveredOrder order,
    required int rating,
    required String comment,
    bool isAnonymous = false,
  }) {
    final cleanComment = comment.trim().isEmpty
        ? 'Great service and delicious kerepek!'
        : comment.trim();

    _reviews.insert(
      0,
      CustomerReview(
        id: 'REV-00${_reviews.length + 1}',
        orderID: order.orderID,
        custName: isAnonymous? 'Anonymous' : 'Adilla',
        itemsOrdered: order.itemsSummary.join(', '),
        rating: rating,
        comment: cleanComment,
        date: '14 Nov 2026',
      ),
    );

    _orders.removeWhere((o) => o.orderID == order.orderID);
    notifyListeners();
  }
}