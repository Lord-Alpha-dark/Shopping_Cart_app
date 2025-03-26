class Product{
  final String sid;
  final String title;
  final double price;
  final String description;
  final List<String> image;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String category;
  
  Product({
    required this.sid,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
   sid: json['id'].toString(),
        title: json['title']?.toString() ?? 'Untitled', // Handle null
        price: (json['price'] as num).toDouble(),
        description: json['description']?.toString() ?? 'No description', // Handle null
        image: List<String>.from(json['images'] ?? []),
        discountPercentage: (json['discountPercentage'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        stock: (json['stock'] as num).toInt(),
        tags: List<String>.from(json['tags'] ?? []),
        brand: json['brand']?.toString() ?? 'Unknown',
        category: json['category']?.toString() ?? 'Unknown',
  );
}