// lib/models/cart_order_data.dart

import 'package:khu_farm/model/address.dart';
import 'package:khu_farm/model/fruit.dart';

// A special version of the Fruit model that includes 'count' and 'cartId'
class FruitWithCount extends Fruit {
  final int count;
  final int cartId;

  FruitWithCount({
    required super.id,
    required super.title,
    required super.widthImageUrl,
    required super.squareImageUrl,
    required super.price,
    required super.weight,
    super.deliveryCompany,
    required super.deliveryDay,
    required super.ratingSum,
    required super.ratingCount,
    required super.description,
    required super.stock,
    required super.sellerId,
    super.brandName,
    required super.fruitCategoryId,
    required super.wholesaleRetailCategoryId,
    required super.isWishList,
    required super.wishListId,
    required this.count,
    required this.cartId,
  });

  factory FruitWithCount.fromJson(Map<String, dynamic> json) {
    return FruitWithCount(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      widthImageUrl: json['widthImageUrl'] ?? '',
      squareImageUrl: json['squareImageUrl'] ?? '',
      price: json['price'] ?? 0,
      weight: json['weight'] ?? 0,
      deliveryCompany: json['deliveryCompany'],
      deliveryDay: json['deliveryDay'],
      ratingSum: (json['ratingSum'] as num?)?.toInt() ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      sellerId: json['sellerId'] ?? 0,
      brandName: json['brandName'],
      fruitCategoryId: json['fruitCategoryId'] ?? 0,
      wholesaleRetailCategoryId: json['wholesaleRetailCategoryId'] ?? 0,
      isWishList: json['isWishList'] ?? false,
      wishListId: json['wishListId'] ?? 0,
      count: json['count'] ?? 0,
      cartId: json['cartId'] ?? 0,
    );
  }
}

// The main data model for the cart order screen
class CartOrderData {
  final Address address;
  final List<FruitWithCount> products;

  CartOrderData({required this.address, required this.products});

  factory CartOrderData.fromJson(Map<String, dynamic> json) {
    var productList = json['fruitResponseWithCount'] as List;
    List<FruitWithCount> products =
        productList.map((i) => FruitWithCount.fromJson(i)).toList();

    return CartOrderData(
      address: Address.fromJson(json['addressResponse']),
      products: products,
    );
  }
}