import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/model/address.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const _storage = FlutterSecureStorage();
  UserInfo? _currentUser;


  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  static Future<String?> getAccessToken() => _storage.read(key: 'accessToken');
  static Future<String?> getRefreshToken() => _storage.read(key: 'refreshToken');

  Future<void> saveUserInfo(UserInfo userInfo) async {
    final userInfoJson = jsonEncode({
      'userId': userInfo.userId,
      'userName': userInfo.userName,
      'email': userInfo.email,
      'phoneNumber': userInfo.phoneNumber,
      'userType': userInfo.userType,
      'totalPoint': userInfo.totalPoint,
      'totalDonation': userInfo.totalDonation,
      'totalPurchasePrice': userInfo.totalPurchasePrice,
      'totalPurchaseWeight': userInfo.totalPurchaseWeight,
      'totalDiscountPrice': userInfo.totalDiscountPrice,
    });
    await _storage.write(key: "userInfo", value: userInfoJson);
    _currentUser = userInfo; // 메모리에 캐싱
  }

  Future<UserInfo?> getUserInfo() async {
    if (_currentUser != null) return _currentUser;

    final userInfoJson = await _storage.read(key: "userInfo");
    if (userInfoJson != null) {
      final userInfoMap = jsonDecode(userInfoJson);
      _currentUser = UserInfo.fromJson(userInfoMap);
      return _currentUser;
    }
    return null;
  }

  Future<void> updateUserInfo({
    String? userName,
    String? email,
    String? phoneNumber,
    int? totalPoint,
    int? totalDonation,
    int? totalPurchasePrice,
    int? totalPurchaseWeight,
    int? totalDiscountPrice,
  }) async {
    final currentUser = await getUserInfo();
    if (currentUser == null) return;

    final updatedInfo = UserInfo(
      userId: currentUser.userId,
      userName: userName ?? currentUser.userName,
      email: email ?? currentUser.email,
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      userType: currentUser.userType,
      totalPoint: totalPoint ?? currentUser.totalPoint,
      totalDonation: totalDonation ?? currentUser.totalDonation,
      totalPurchasePrice: totalPurchasePrice ?? currentUser.totalPurchasePrice,
      totalPurchaseWeight: totalPurchaseWeight ?? currentUser.totalPurchaseWeight,
      totalDiscountPrice: totalDiscountPrice ?? currentUser.totalDiscountPrice,
    );
    await saveUserInfo(updatedInfo);
  }

  Future<void> saveAddresses(List<Address> addresses) async {
    // Convert the list of Address objects to a list of Maps, then to a JSON string.
    final List<Map<String, dynamic>> addressListJson =
        addresses.map((address) => address.toJson()).toList();
    await _storage.write(key: "userAddresses", value: jsonEncode(addressListJson));
  }

  Future<List<Address>?> getAddresses() async {
    final addressListString = await _storage.read(key: "userAddresses");
    if (addressListString != null) {
      final List<dynamic> addressListJson = jsonDecode(addressListString);
      return addressListJson.map((json) => Address.fromJson(json)).toList();
    }
    return null;
  }

  Future<void> clearAllData() async {
    await _storage.deleteAll();
    _currentUser = null;
  }
}