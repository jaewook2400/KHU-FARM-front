// lib/models/seller_order.dart
import 'package:khu_farm/model/order_status.dart';

class SellerOrder {
  final int orderId;
  final String merchantUid;
  final String ordererName;
  final int totalPrice;
  final String fruitTitle;
  final int orderCount;
  final String portCode;
  final String address;
  final String detailAddress;
  final String recipient;
  final String phoneNumber;
  final String? deliveryCompany;
  final String? deliveryNumber;
  final String? orderRequest;
  final String createdAt;
  final String status;

  SellerOrder({
    required this.orderId,
    required this.merchantUid,
    required this.ordererName,
    required this.totalPrice,
    required this.fruitTitle,
    required this.orderCount,
    required this.portCode,
    required this.address,
    required this.detailAddress,
    required this.recipient,
    required this.phoneNumber,
    this.deliveryCompany,
    this.deliveryNumber,
    this.orderRequest,
    required this.createdAt,
    required this.status,
  });

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    return SellerOrder(
      orderId: json['orderId'] ?? 0,
      merchantUid: json['merchantUid'] ?? '',
      ordererName: json['ordererName'] ?? 'N/A',
      totalPrice: json['totalPrice'] ?? 0,
      fruitTitle: json['fruitTitle'] ?? 'N/A',
      orderCount: json['orderCount'] ?? 0,
      portCode: json['portCode'] ?? '',
      address: json['address'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      recipient: json['recipient'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      deliveryCompany: json['deliveryCompany'],
      deliveryNumber: json['deliveryNumber'],
      orderRequest: json['orderRequest'],
      createdAt: json['createdAt'] ?? '',
      status: json['deliveryStatus'] ?? '알 수 없음', 
    );
  }
}