import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;
  final double rating;
  final int reviewCount;
  final int stockCount;
  final String vendor;
  final Map<String, String> specifications;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.categoryId,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stockCount = 100,
    this.vendor = 'ShopEasy',
    this.specifications = const {},
  });

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  bool get isInStock => stockCount > 0;

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'original_price': originalPrice,
        'image_url': imageUrl,
        'image_urls': jsonEncode(imageUrls),
        'category_id': categoryId,
        'rating': rating,
        'review_count': reviewCount,
        'stock_count': stockCount,
        'vendor': vendor,
        'specifications': jsonEncode(specifications),
      };

  factory Product.fromDbMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        price: (map['price'] as num).toDouble(),
        originalPrice: map['original_price'] != null
            ? (map['original_price'] as num).toDouble()
            : null,
        imageUrl: map['image_url'],
        imageUrls: map['image_urls'] != null
            ? List<String>.from(jsonDecode(map['image_urls']))
            : [],
        categoryId: map['category_id'],
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: map['review_count'] as int? ?? 0,
        stockCount: map['stock_count'] as int? ?? 100,
        vendor: map['vendor'] ?? 'ShopEasy',
        specifications: map['specifications'] != null
            ? Map<String, String>.from(jsonDecode(map['specifications']))
            : {},
      );
}
