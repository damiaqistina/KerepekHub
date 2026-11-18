import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color dark = Color(0xFF222222);
  static const Color grey = Color(0xFF888888);
  static const Color borderGrey = Color(0xFFCCCCCC);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,

      // Header
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your cart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: dark,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),

      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(color: grey, fontSize: 14),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Item count
                      Text(
                        '${cart.totalItemCount} items across '
                        '${cart.items.length} products',
                        style: const TextStyle(
                          fontSize: 12,
                          color: grey,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Cart products
                      ...cart.items.values.map((item) {
                        final product = item.product;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderGrey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: product.imageUrl.startsWith('http')
                                    ? Image.network(
                                        product.imageUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _imagePlaceholder(),
                                      )
                                    : Image.asset(
                                        product.imageUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _imagePlaceholder(),
                                      ),
                              ),

                              const SizedBox(width: 10),

                              // Product information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: dark,
                                      ),
                                    ),

                                    Text(
                                      item.selectedSize,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: grey,
                                      ),
                                    ),

                                    Text(
                                      product.stockCount <= 5
                                          ? '${product.stockCount} left in stock'
                                          : 'In Stock',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: product.stockCount <= 5
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Quantity and remove controls
                                    Row(
                                      children: [
                                        Container(
                                          height: 28,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: borderGrey,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 28,
                                                  minHeight: 28,
                                                ),
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 13,
                                                ),
                                                onPressed: () {
                                                  cart.removeOneItem(
                                                    product.id,
                                                    selectedSize: item.selectedSize,
                                                  );
                                                },
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 28,
                                                  minHeight: 28,
                                                ),
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 13,
                                                ),
                                                onPressed: () {
                                                  final added =
                                                      cart.addItem(
                                                        product,
                                                        selectedSize: item.selectedSize,
                                                      );

                                                  if (!added) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Maximum available stock reached.',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        const Spacer(),

                                        TextButton(
                                          onPressed: () {
                                            cart.removeItem(
                                              product.id,
                                              selectedSize: item.selectedSize,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(4),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Remove',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: dark,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 4),

                              // Product subtotal
                              Text(
                                'RM${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: dark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 4),

                      // Add more items
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: dark,
                            side: const BorderSide(color: grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            '+ Add more items',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Order summary
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderGrey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order summary',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'RM${cart.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Fixed bottom checkout button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Continue to checkout',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: const Color(0xFFF2F2F2),
      child: const Icon(Icons.fastfood, color: grey),
    );
  }
}
