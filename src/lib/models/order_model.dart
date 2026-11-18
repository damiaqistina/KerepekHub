import 'product.dart';

class OrderLineItem {
  final Product product;
  final int quantity;

  const OrderLineItem({required this.product, required this.quantity});

  double get subtotal => product.priceMyr * quantity;
}

class OrderRecord {
  final String orderId;
  final String orderDate;
  final String deliveryMethod;
  final String address;
  final String orderStatus; // Order taken, Preparing, Delivered, Cancelled
  final String categoryTab; // Active, Completed, Cancelled (Figure C3 UI-05)
  final List<OrderLineItem> items;

  const OrderRecord({
    required this.orderId,
    required this.orderDate,
    required this.deliveryMethod,
    required this.address,
    required this.orderStatus,
    required this.categoryTab,
    required this.items,
  });

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);
}
