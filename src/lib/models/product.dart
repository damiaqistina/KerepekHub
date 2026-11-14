class Product {
  final String id;
  final String name;
  final String flavour;
  final String size;
  final double priceMyr;
  final int stockCount;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.flavour,
    required this.size,
    required this.priceMyr,
    required this.stockCount,
    required this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      flavour: map['flavour'] ?? '',
      size: map['size'] ?? 'packet',
      priceMyr: (map['price_myr'] as num).toDouble(),
      stockCount: map['stock_count'] ?? 0,
      imageUrl: map['image_url'] ?? '',
    );
  }
}
