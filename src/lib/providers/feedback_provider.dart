import 'package:flutter/material.dart';
import '../models/feedback_model.dart';

class FeedbackProvider extends ChangeNotifier {
  final List<DeliveredOrder> _orders = [
    DeliveredOrder(
      orderID: 'ORD-1024',
      custName: 'Siti Aisyah',
      itemsSummary: [
        '1x Crunchy Spicy Cheese (Packet)',
        '1x Seaweed Original (Packet)',
      ],
      totalMyr: 18.00,
      date: '12 Nov 2026',
      isReviewed: false,
    ),
    DeliveredOrder(
      orderID: 'ORD-1023',
      custName: 'Siti Aisyah',
      itemsSummary: [
        '2x Crunchy Nestum Milk (Packet)',
      ],
      totalMyr: 18.00,
      date: '09 Nov 2026',
      isReviewed: false,
    ),
  ];

  final List<CustomerReview> _reviews = [
    const CustomerReview(
      id: 'REV-001',
      orderID: 'ORD-1020',
      custName: 'Ainur Hanum',
      itemsOrdered: 'Crunchy Spicy Cheese (Packet)',
      rating: 5,
      comment:
          'Super crispy and generous spicy cheese coating! Will definitely reorder.',
      date: '06 Nov 2026',
    ),
    const CustomerReview(
      id: 'REV-002',
      orderID: 'ORD-1018',
      custName: 'Damia Qistina',
      itemsOrdered: 'Seaweed Original (Packet)',
      rating: 4,
      comment: 'Fresh packaging and fast self-collection pickup at Serooja.',
      date: '02 Nov 2026',
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
  }) {
    final cleanComment = comment.trim().isEmpty
        ? 'Great service and delicious kerepek!'
        : comment.trim();

    _reviews.insert(
      0,
      CustomerReview(
        id: 'REV-00${_reviews.length + 1}',
        orderID: order.orderID,
        custName: order.custName,
        itemsOrdered: order.itemsSummary.join(', '),
        rating: rating,
        comment: cleanComment,
        date: '14 Nov 2026',
      ),
    );

    order.isReviewed = true;
    notifyListeners();
  }
}