// lib/models/address.dart

class Address {
  final int addressId;
  final String addressName;
  final String portCode;
  final String address;
  final String detailAddress;
  final String recipient;
  final String phoneNumber;
  final bool isDefault;

  Address({
    required this.addressId,
    required this.addressName,
    required this.portCode,
    required this.address,
    required this.detailAddress,
    required this.recipient,
    required this.phoneNumber,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'] ?? 0,
      addressName: json['addressName'] ?? 'N/A',
      portCode: json['portCode'] ?? '',
      address: json['address'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      recipient: json['recipient'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isDefault: json['default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'addressName': addressName,
      'portCode': portCode,
      'address': address,
      'detailAddress': detailAddress,
      'recipient': recipient,
      'phoneNumber': phoneNumber,
      'default': isDefault,
    };
  }
}