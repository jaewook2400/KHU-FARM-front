class Fruit {
  final int id;
  final String title;
  final String widthImageUrl;
  final String squareImageUrl;
  final int price;
  final int weight;
  final String? deliveryCompany;
  final String? deliveryDay;
  final int ratingSum;
  final int ratingCount;
  final String description;
  final int stock;
  final int sellerId;
  final String? brandName;
  final int fruitCategoryId;
  final int wholesaleRetailCategoryId;
  final bool liked;

  Fruit({
    required this.id,
    required this.title,
    required this.widthImageUrl,
    required this.squareImageUrl,
    required this.price,
    required this.weight,
    this.deliveryCompany,
    this.deliveryDay,
    required this.ratingSum,
    required this.ratingCount,
    required this.description,
    required this.stock,
    required this.sellerId,
    this.brandName,
    required this.fruitCategoryId,
    required this.wholesaleRetailCategoryId,
    this.liked = false,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      id: json['id'] as int,
      title: json['title'] as String,
      widthImageUrl: json['widthImageUrl'] as String,
      squareImageUrl: json['squareImageUrl'] as String,
      price: json['price'] as int,
      weight: int.tryParse(json['weight'].toString()) ?? 0,
      deliveryCompany: json['deliveryCompany']?.toString(), // Safely convert to String
      deliveryDay: json['deliveryDay']?.toString(),       // Safely convert to String
      ratingSum: json['ratingSum'] as int,
      ratingCount: json['ratingCount'] as int,
      description: json['description'] as String,
      stock: json['stock'] as int,
      sellerId: json['sellerId'] as int,
      brandName: json['brandName'] as String?,
      fruitCategoryId: json['fruitCategoryId'] as int,
      wholesaleRetailCategoryId: json['wholesaleRetailCategoryId'] as int,
      liked: json['liked'] as bool? ?? false,
    );
  }
}
