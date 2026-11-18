
import 'package:flutter/material.dart';

import '../../../providers/cart_provider.dart';

class ConfirmationScreen extends StatelessWidget {
  final String customerName;
  final String phone;
  final String address;
  final List<CartItem> orderItems;
  final double totalAmount;

  const ConfirmationScreen({
    super.key,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.orderItems,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),

            const SizedBox(height: 16),

            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Thank you for shopping with KerepekHub.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Delivery Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            _detailRow('Name', customerName),
            _detailRow('Phone', phone),
            _detailRow('Address', address),

            const Divider(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            ...orderItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} (${item.selectedSize}) x ${item.quantity}',
                    ),
                  ),
                  Text('RM ${item.subtotal.toStringAsFixed(2)}'),
                ],
              ),
            )),

            const Divider(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'RM ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
