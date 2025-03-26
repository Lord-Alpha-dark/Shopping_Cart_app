class Product{
  String? sid;
  String? title;
  double? price;
  String? description;
  List<String>? image;
  double? discountPercentage;
  double? rating;
  int? stock;
  List<String>? tags;
  String? brand;
  String? category;
  
  Product({
    this.sid,
    this.title,
    this.price,
    this.description,
    this.image,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.tags,
    this.brand,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    sid: json['id'],
    title: json['title'],
    price: json['price'].toDouble(),
    description: json['description'],
    image:List<String>.from(json['image']),
    discountPercentage: json['discountPercentage'].toDouble(),
    rating: json['rating'].toDouble(),
    stock: json['stock'].toInt(),
    tags: List<String>.from(json['tags']),
    brand: json['brand'],
    category: json['category'],
  );
}