import 'package:khu_farm/model/delivery_tracking.dart'; // deliveryStatus를 위해 import

class Order {
  final int id;
  final String title;
  final String widthImageUrl;
  final String squareImageUrl;
  final int price;
  final int weight;
  final String deliveryCompany;
  final int deliveryDay;
  final int ratingSum;
  final int ratingCount;
  final String description;
  final int stock;
  final int sellerId;
  final String brandName;
  final int fruitCategoryId;
  final int wholesaleRetailCategoryId;
  final int orderCount;
  final int orderId;
  final int orderDetailId;
  final String createdAt;
  final DeliveryTrackingData? deliveryStatus; // ✨ deliveryStatus 필드 추가

  Order({
    required this.id,
    required this.title,
    required this.widthImageUrl,
    required this.squareImageUrl,
    required this.price,
    required this.weight,
    required this.deliveryCompany,
    required this.deliveryDay,
    required this.ratingSum,
    required this.ratingCount,
    required this.description,
    required this.stock,
    required this.sellerId,
    required this.brandName,
    required this.fruitCategoryId,
    required this.wholesaleRetailCategoryId,
    required this.orderCount,
    required this.orderId,
    required this.orderDetailId,
    required this.createdAt,
    this.deliveryStatus, // ✨ 생성자에 추가
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'N/A',
      widthImageUrl: json['widthImageUrl'] ?? '',
      squareImageUrl: json['squareImageUrl'] ?? '',
      price: json['price'] ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      deliveryCompany: json['deliveryCompany'] ?? '',
      deliveryDay: json['deliveryDay'] ?? 0,
      ratingSum: (json['ratingSum'] as num?)?.toInt() ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      sellerId: json['sellerId'] ?? 0,
      brandName: json['brandName'] ?? 'N/A',
      fruitCategoryId: json['fruitCategoryId'] ?? 0,
      wholesaleRetailCategoryId: json['wholesaleRetailCategoryId'] ?? 0,
      orderCount: json['orderCount'] ?? 0,
      orderId: json['orderId'] ?? 0,
      orderDetailId: json['orderDetailId'] ?? 0,
      createdAt: json['createdAt'] ?? '2025.01.01',
      // ✨ fromJson 팩토리에 deliveryStatus 파싱 로직 추가
      deliveryStatus: json['deliveryStatus'] != null
          ? DeliveryTrackingData.fromJson(json['deliveryStatus'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, title: $title, price: $price, brandName: $brandName, orderId: $orderId, createdAt: $createdAt, deliveryStatus: $deliveryStatus)';
  }
}