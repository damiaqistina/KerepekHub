import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../models/product.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderRecord> _orders = [
    const OrderRecord(
      orderId: 'ORD-1045',
      orderDate: '18 Nov 2026, 01:20 pm',
      deliveryMethod: 'Doorstep Delivery',
      address: '18 Jalan Hillside, Kuching, Sarawak',
      orderStatus: 'Order taken',
      categoryTab: 'Active',
      items: [
        OrderLineItem(
          product: Product(
            id: '1',
            name: 'Crunchy Spicy Cheese',
            flavour: 'Spicy Cheese',
            size: 'Packet',
            priceMyr: 9.00,
            stockCount: 20,
            imageUrl: 'assets/images/spicy_cheese.png',
          ),
          quantity: 1,
        ),
        OrderLineItem(
          product: Product(
            id: '3',
            name: 'Seaweed Original',
            flavour: 'Original Seaweed',
            size: 'Packet',
            priceMyr: 9.00,
            stockCount: 18,
            imageUrl: 'assets/images/seaweed_original.png',
          ),
          quantity: 1,
        ),
      ],
    ),
    const OrderRecord(
      orderId: 'ORD-1042',
      orderDate: '15 Nov 2026, 04:15 pm',
      deliveryMethod: 'Self-Collection',
      address: 'Serooja Pickup Point, Kuching',
      orderStatus: 'Delivered',
      categoryTab: 'Completed',
      items: [
        OrderLineItem(
          product: Product(
            id: '2',
            name: 'Crunchy Nestum Milk',
            flavour: 'Nestum Milk',
            size: 'Packet',
            priceMyr: 9.00,
            stockCount: 15,
            imageUrl: 'assets/images/nestum_milk.png',
          ),
          quantity: 1,
        ),
      ],
    ),
    const OrderRecord(
      orderId: 'ORD-1038',
      orderDate: '10 Nov 2026, 11:05 am',
      deliveryMethod: 'Doorstep Delivery',
      address: 'Lot 22, Petra Jaya, Kuching',
      orderStatus: 'Delivered',
      categoryTab: 'Completed',
      items: [
        OrderLineItem(
          product: Product(
            id: '4',
            name: 'Seaweed Spicy Cheese',
            flavour: 'Spicy Cheese Seaweed',
            size: 'Packet',
            priceMyr: 9.50,
            stockCount: 5,
            imageUrl: 'assets/images/seaweed_spicy.png',
          ),
          quantity: 2,
        ),
      ],
    ),
    const OrderRecord(
      orderId: 'ORD-1031',
      orderDate: '04 Nov 2026, 09:40 am',
      deliveryMethod: 'Self-Collection',
      address: 'Serooja Pickup Point, Kuching',
      orderStatus: 'Cancelled',
      categoryTab: 'Cancelled',
      items: [
        OrderLineItem(
          product: Product(
            id: '5',
            name: 'Popia Simpul',
            flavour: 'Traditional Serunding',
            size: 'Bottle',
            priceMyr: 10.00,
            stockCount: 0,
            imageUrl: 'assets/images/popia_simpul.png',
          ),
          quantity: 1,
        ),
      ],
    ),
  ];

  List<OrderRecord> get orders => List.unmodifiable(_orders);

  List<OrderRecord> getOrdersByTab(String categoryTab) {
    return _orders.where((o) => o.categoryTab == categoryTab).toList();
  }

  /// Allows Checkout (UI-04) to append a newly placed order into Active orders
  void addOrder(OrderRecord newOrder) {
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}
