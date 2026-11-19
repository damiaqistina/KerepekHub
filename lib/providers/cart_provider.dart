import 'package:flutter/material.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.product,
    this.selectedSize = 'Small',
    this.quantity = 1,
  });

  // Large size costs RM4 more
  double get unitPrice =>
      product.priceMyr + (selectedSize == 'Large' ? 4.00 : 0.00);

  // Calculate subtotal based on selected size and quantity
  double get subtotal => unitPrice * quantity;

  // Unique identifier for product and size combination
  String get cartItemId => '${product.id}_$selectedSize';
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // Total number of individual packets
  int get totalItemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  // Number of distinct product-size combinations
  int get totalProducts => _items.length;

  // Total cart amount
  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  // Get quantity of a specific product and size
  int getQuantity(String productId, {String selectedSize = 'Small'}) {
    final key = '${productId}_$selectedSize';
    return _items[key]?.quantity ?? 0;
  }

  // Add product with selected size
  // Defaults to Small when added directly from catalog
  bool addItem(Product product, {String selectedSize = 'Small'}) {
    final key = '${product.id}_$selectedSize';
    final currentQty = getQuantity(
      product.id,
      selectedSize: selectedSize,
    );

    if (currentQty >= product.stockCount) {
      return false;
    }

    if (_items.containsKey(key)) {
      _items[key]!.quantity += 1;
    } else {
      _items[key] = CartItem(
        product: product,
        selectedSize: selectedSize,
        quantity: 1,
      );
    }

    notifyListeners();
    return true;
  }

  // Decrease quantity or remove item when quantity reaches zero
  void removeOneItem(
    String productId, {
    String selectedSize = 'Small',
  }) {
    final key = '${productId}_$selectedSize';

    if (!_items.containsKey(key)) return;

    if (_items[key]!.quantity > 1) {
      _items[key]!.quantity -= 1;
    } else {
      _items.remove(key);
    }

    notifyListeners();
  }

  // Remove the entire product-size combination
  void removeItem(
    String productId, {
    String selectedSize = 'Small',
  }) {
    final key = '${productId}_$selectedSize';

    _items.remove(key);
    notifyListeners();
  }

  // Clear all cart items
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}