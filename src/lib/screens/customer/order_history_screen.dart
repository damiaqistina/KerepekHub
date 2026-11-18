import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'feedback_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback? onBackToHomeTap;

  const OrderHistoryScreen({super.key, this.onBackToHomeTap});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedTab = 'Active';

  static const Color _brandYellow = Color(0xFFFFC107);
  static const Color _brandCharcoal = Color(0xFF222222);

  String _formatStatusDate(OrderRecord order) {
    if (order.orderStatus == 'Delivered') {
      return 'Delivered on ${order.orderDate}';
    } else if (order.orderStatus == 'Cancelled') {
      return 'Cancelled on ${order.orderDate}';
    }
    return '${order.orderStatus} · ${order.orderDate}';
  }

  void _handleOrderAgain(BuildContext context, OrderRecord order) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Order Again',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Add items from ${order.orderId} (RM${order.total.toStringAsFixed(2)}) to your shopping cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandCharcoal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              final cart = context.read<CartProvider>();
              int addedUnits = 0;
              final List<String> unavailableItems = [];

              for (final lineItem in order.items) {
                for (int i = 0; i < lineItem.quantity; i++) {
                  final ok = cart.addItem(lineItem.product);
                  if (ok) {
                    addedUnits++;
                  } else if (!unavailableItems.contains(
                    lineItem.product.name,
                  )) {
                    unavailableItems.add(lineItem.product.name);
                  }
                }
              }

              if (!context.mounted) return;

              if (addedUnits == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cannot reorder: ${unavailableItems.join(', ')} is currently out of stock.',
                    ),
                    backgroundColor: const Color(0xFFE53935),
                  ),
                );
              } else if (unavailableItems.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added $addedUnits item(s) to cart. Out of stock: ${unavailableItems.join(', ')}.',
                    ),
                    backgroundColor: Colors.orange.shade800,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added $addedUnits item(s) from ${order.orderId} to cart!',
                    ),
                    backgroundColor: const Color(0xFF2E9E5B),
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleLeaveReview(BuildContext context, OrderRecord order) {
    if (order.orderStatus != 'Delivered') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reviews can only be submitted once your order is Delivered.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
    );
  }

  void _showOrderDetailsSheet(BuildContext context, OrderRecord order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.orderId}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _brandCharcoal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const Divider(),
              Text('Date: ${order.orderDate}'),
              const SizedBox(height: 4),
              Text('Method: ${order.deliveryMethod}'),
              const SizedBox(height: 4),
              Text('Address: ${order.address}'),
              const SizedBox(height: 4),
              Text(
                'Status: ${order.orderStatus}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Items Ordered',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} (${item.product.size}) × ${item.quantity}',
                        ),
                      ),
                      Text('RM${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'RM${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _brandCharcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandCharcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    _handleOrderAgain(context, order);
                  },
                  child: const Text(
                    'Order Again',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleOrders = context.watch<OrderProvider>().getOrdersByTab(
      _selectedTab,
    );
    const tabs = ['Active', 'Completed', 'Cancelled'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _brandCharcoal),
          tooltip: 'Back to Home',
          onPressed:
              widget.onBackToHomeTap ??
              () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
        ),
        titleSpacing: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _brandCharcoal,
            ),
            children: [
              TextSpan(text: 'Kerepek'),
              TextSpan(
                text: 'Hub ',
                style: TextStyle(color: Color(0xFFF4C430)),
              ),
              TextSpan(
                text: 'Order History',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Top Status Tabs: Active | Completed | Cancelled
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: tabs.map((tab) {
                final isSelected = _selectedTab == tab;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? _brandYellow
                              : Colors.white,
                          foregroundColor: _brandCharcoal,
                          side: BorderSide(
                            color: isSelected
                                ? _brandCharcoal
                                : const Color(0xFFCCCCCC),
                            width: isSelected ? 1.2 : 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => setState(() => _selectedTab = tab),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Order History Cards
          Expanded(
            child: visibleOrders.isEmpty
                ? const Center(
                    child: Text(
                      'No order history is available.',
                      style: TextStyle(color: Color(0xFF777777), fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    itemCount: visibleOrders.length,
                    itemBuilder: (context, index) {
                      final order = visibleOrders[index];
                      final isCancelled = order.orderStatus == 'Cancelled';
                      final isDelivered = order.orderStatus == 'Delivered';

                      return InkWell(
                        onTap: () => _showOrderDetailsSheet(context, order),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Status + Date & Order ID
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _formatStatusDate(order),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: isCancelled
                                            ? const Color(0xFFC62828)
                                            : isDelivered
                                            ? const Color(0xFF2E7D32)
                                            : Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    order.orderId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF777777),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 18,
                                color: Color(0xFFEEEEEE),
                              ),

                              // Full list of all items in the order
                              ...order.items.map(
                                (lineItem) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          lineItem.product.imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Container(
                                            width: 50,
                                            height: 50,
                                            color: const Color(0xFFF5F5F5),
                                            child: const Icon(
                                              Icons.fastfood,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lineItem.product.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: _brandCharcoal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${lineItem.product.size} · RM${lineItem.product.priceMyr.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF777777),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '× ${lineItem.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _brandCharcoal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Total row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Order Total',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'RM${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _brandCharcoal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Dual Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 44,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _brandCharcoal,
                                          side: const BorderSide(
                                            color: Color(0xFF555555),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _handleLeaveReview(context, order),
                                        child: const Text(
                                          'Leave a review',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SizedBox(
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _brandCharcoal,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _handleOrderAgain(context, order),
                                        child: const Text(
                                          'Order Again',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
