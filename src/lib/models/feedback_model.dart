class DeliveredOrder{
  final String orderID;
  final String custName;
  final List<String> itemsSummary;
  final double totalMyr;
  final String date;
  bool isReviewed;

  DeliveredOrder({
    required this.orderID,
    required this.custName,
    required this.itemsSummary,
    required this.totalMyr,
    required this.date,
    this.isReviewed = false,
  });

  factory DeliveredOrder.fromMap(Map<String, dynamic> map){
    return DeliveredOrder(
      orderID: map['order_id'].toString(),
      custName: map['customer_name']??'Customer',
      itemsSummary: List<String>.from(map['items_summary']?? []),
      totalMyr: (map['total_myr'] as num).toDouble(),
      date: map['date']?? '',
      isReviewed: map['is_reviewed'] ?? false,
    );
  }
}

class CustomerReview {
  final String id;
  final String orderID;
  final String custName;
  final String itemsOrdered;
  final int rating;
  final String comment;
  final String date;

  const CustomerReview({
    required this.id,
    required this.orderID,
    required this.custName,
    required this.itemsOrdered,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory CustomerReview.fromMap(Map<String, dynamic> map) {
    return CustomerReview(
      id: map['id'].toString(),
      orderID: map['order_id'].toString(),
      custName: map['customer_name'] ?? 'Customer',
      itemsOrdered: map['items_ordered'] ?? '',
      rating: map['rating'] ?? 5,
      comment: map['comment'] ?? '',
      date: map['date'] ?? '',
    );
  }
}