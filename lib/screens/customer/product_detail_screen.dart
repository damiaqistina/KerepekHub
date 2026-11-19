import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'Small';
  int _quantity = 1;

  double get _unitPrice =>
      widget.product.priceMyr +
      (_selectedSize == 'Large' ? 4.00 : 0.00);

  double get _subtotal => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cart = context.watch<CartProvider>();

    final bool isOutOfStock = product.stockCount == 0;
    final bool isLowStock =
        product.stockCount > 0 && product.stockCount <= 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Product details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl.startsWith('http')
                ? Image.network(
                    product.imageUrl,
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder(),
                  )
                : Image.asset(
                    product.imageUrl,
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder(),
                  ),
          ),

          const SizedBox(height: 20),

          // Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            product.flavour,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            isOutOfStock
                ? 'Out of stock'
                : isLowStock
                    ? '${product.stockCount} left in stock'
                    : 'In Stock',
            style: TextStyle(
              fontSize: 12,
              color: isOutOfStock || isLowStock
                  ? Colors.red
                  : Colors.green,
            ),
          ),

          const SizedBox(height: 24),

          // Size selection
          const Text(
            'Select size',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _sizeOption('Small'),
              const SizedBox(width: 12),
              _sizeOption('Large'),
            ],
          ),

          const SizedBox(height: 24),

          // Price
          const Text(
            'Price per packet',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'RM${_unitPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          // Quantity selector
          const Text(
            'Quantity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              IconButton(
                onPressed: _quantity > 1
                    ? () {
                        setState(() => _quantity--);
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),

              Text(
                '$_quantity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              IconButton(
                onPressed: _quantity < product.stockCount
                    ? () {
                        setState(() => _quantity++);
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Subtotal
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFCCCCCC),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'RM${_subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Add to cart
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isOutOfStock
                  ? null
                  : () {
                      // Check stock for the selected size
                      final currentQty = cart.getQuantity(
                        product.id,
                        selectedSize: _selectedSize,
                      );

                      if (currentQty + _quantity >
                          product.stockCount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Not enough stock available.',
                            ),
                          ),
                        );
                        return;
                      }

                      // Add selected size and quantity
                      for (int i = 0; i < _quantity; i++) {
                        cart.addItem(
                          product,
                          selectedSize: _selectedSize,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart successfully!'),
                        ),
                      );

                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Add to cart',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sizeOption(String size) {
    final bool isSelected = _selectedSize == size;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedSize = size;
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF222222),
          backgroundColor: isSelected
              ? const Color(0xFFF2F2F2)
              : Colors.white,
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF222222)
                : const Color(0xFFCCCCCC),
            width: isSelected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          size,
          style: TextStyle(
            fontWeight: isSelected
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 230,
      width: double.infinity,
      color: const Color(0xFFF2F2F2),
      child: const Icon(
        Icons.fastfood,
        color: Colors.grey,
        size: 48,
      ),
    );
  }
}