// lib/models/user_info.dart

class UserInfo {
  final int userId;
  final String userName;
  final String email;
  final String phoneNumber;
  final String userType;
  final int totalPoint;
  final int totalDonation;
  final int totalPurchasePrice;
  final int totalPurchaseWeight;
  final int totalDiscountPrice;

  UserInfo({
    required this.userId,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.totalPoint,
    required this.totalDonation,
    required this.totalPurchasePrice,
    required this.totalPurchaseWeight,
    required this.totalDiscountPrice,
  });

  // JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'N/A',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? '',
      totalPoint: json['totalPoint'] ?? 0,
      totalDonation: json['totalDonation'] ?? 0,
      totalPurchasePrice: json['totalPurchasePrice'] ?? 0,
      totalPurchaseWeight: json['totalPurchaseWeight'] ?? 0,
      totalDiscountPrice: json['totalDiscountPrice'] ?? 0,
    );
  }

  // 객체를 JSON(Map)으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'totalPoint': totalPoint,
      'totalDonation': totalDonation,
      'totalPurchasePrice': totalPurchasePrice,
      'totalPurchaseWeight': totalPurchaseWeight,
      'totalDiscountPrice': totalDiscountPrice,
    };
  }

  @override
  String toString() {
    return 'UserInfo(${toJson()})';
  }
}