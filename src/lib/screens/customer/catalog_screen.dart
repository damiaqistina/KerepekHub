import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class CatalogScreen extends StatefulWidget {
  final VoidCallback? onViewCartTap;

  const CatalogScreen({super.key, this.onViewCartTap});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortAscending = true;

  // Mock data for M2 demo using Serooja's snack images
  final List<Product> _allProducts = const [
    Product(
      id: '1',
      name: 'Crunchy Spicy Cheese',
      flavour: 'Spicy Cheese',
      size: 'Packet',
      priceMyr: 9.00,
      stockCount: 20,
      imageUrl: 'assets/images/spicy_cheese.png',
    ),
    Product(
      id: '2',
      name: 'Crunchy Nestum Milk',
      flavour: 'Nestum Milk',
      size: 'Packet',
      priceMyr: 9.00,
      stockCount: 15,
      imageUrl: 'assets/images/nestum_milk.png',
    ),
    Product(
      id: '3',
      name: 'Seaweed Original',
      flavour: 'Original Seaweed',
      size: 'Packet',
      priceMyr: 9.00,
      stockCount: 18,
      imageUrl: 'assets/images/seaweed_original.png',
    ),
    Product(
      id: '4',
      name: 'Seaweed Spicy Cheese',
      flavour: 'Spicy Cheese Seaweed',
      size: 'Packet',
      priceMyr: 9.50,
      stockCount: 5,
      imageUrl: 'assets/images/seaweed_spicy.png',
    ),
    Product(
      id: '5',
      name: 'Popia Simpul',
      flavour: 'Traditional Serunding',
      size: 'Bottle',
      priceMyr: 10.00,
      stockCount: 0, // Out of stock item
      imageUrl: 'assets/images/popia_simpul.png',
    ),
  ];

  // Filter snacks by search keyword and sort by price
  List<Product> get _filteredProducts {
    final filtered = _allProducts.where((product) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      return product.name.toLowerCase().contains(q) ||
          product.flavour.toLowerCase().contains(q) ||
          product.size.toLowerCase().contains(q);
    }).toList();

    filtered.sort(
      (a, b) => _sortAscending
          ? a.priceMyr.compareTo(b.priceMyr)
          : b.priceMyr.compareTo(a.priceMyr),
    );

    return filtered;
  }

  // Add item to cart and block if user tries to exceed available stock
  void _handleAdd(CartProvider cart, Product product) {
    final added = cart.addItem(product);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum available stock reached.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        // KerepekHub's logo
        title: Image.asset(
          'assets/images/logo_kerepekhub.png',
          height: 24,
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    hintStyle: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF333333),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF222222),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Price sort chips
                Row(
                  children: [
                    _SortChip(
                      label: 'Price ascending',
                      isSelected: _sortAscending,
                      onTap: () => setState(() => _sortAscending = true),
                    ),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: 'Price descending',
                      isSelected: !_sortAscending,
                      onTap: () => setState(() => _sortAscending = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  'All products',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),

          // 2-column product grid
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      'No snacks found matching your search.',
                      style: TextStyle(color: Color(0xFF777777), fontSize: 14),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.66,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final qtyInCart = cart.getQuantity(product.id);

                      return _ProductCard(
                        product: product,
                        quantityInCart: qtyInCart,
                        onAdd: () => _handleAdd(cart, product),
                        onRemove: () => cart.removeOneItem(product.id),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Bottom view cart bar (only shows when cart is not empty)
      bottomNavigationBar: cart.totalItemCount > 0
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed:
                      widget.onViewCartTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Opening Cart (${cart.totalItemCount} items · RM${cart.totalAmount.toStringAsFixed(2)})',
                            ),
                          ),
                        );
                      },
                  child: Text(
                    'View cart · ${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'} · RM${cart.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// Reusable toggle chip for price sorting
class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F2F2) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF333333)
                : const Color(0xFFCCCCCC),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF222222)
                : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

// Individual product card inside the grid
class _ProductCard extends StatelessWidget {
  final Product product;
  final int quantityInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductCard({
    required this.product,
    required this.quantityInCart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.stockCount == 0;
    final bool isLowStock = product.stockCount > 0 && product.stockCount <= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Snack thumbnail (faded slightly if out of stock)
        AspectRatio(
          aspectRatio: 1.2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Opacity(
              opacity: isOutOfStock ? 0.55 : 1.0,
              child: product.imageUrl.startsWith('http')
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.grey,
                          size: 36,
                        ),
                      ),
                    )
                  : Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.grey,
                          size: 36,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Snack name
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isOutOfStock
                ? const Color(0xFF888888)
                : const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 2),

        // Price tag
        Text(
          'RM${product.priceMyr.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isOutOfStock
                ? const Color(0xFF888888)
                : const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 2),

        // Stock status label (hidden when unavailable)
        if (!isOutOfStock)
          Text(
            isLowStock ? '${product.stockCount} left in stock' : 'In Stock',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isLowStock
                  ? const Color(0xFFE53935)
                  : const Color(0xFF2E9E5B),
            ),
          )
        else
          const SizedBox(height: 15),
        const Spacer(),

        // Bottom button: Unavailable, Add to cart, or quantity stepper (- 1 +)
        SizedBox(
          width: double.infinity,
          height: 38,
          child: isOutOfStock
              ? OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Unavailable',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : quantityInCart > 0
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF555555)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: onRemove,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ),
                      Text(
                        '$quantityInCart',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      InkWell(
                        onTap: onAdd,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : OutlinedButton(
                  onPressed: onAdd,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF222222),
                    side: const BorderSide(color: Color(0xFF555555)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    '+ Add to cart',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
