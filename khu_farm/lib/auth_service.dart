import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _baseUrl = 'http://10.0.2.2:8080'; // 변경 가능

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    await _storage.write(key: 'accessSavedAt', value: DateTime.now().millisecondsSinceEpoch.toString());
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  static Future<String?> getValidAccessToken() async {
    final token = await _storage.read(key: 'accessToken');
    final savedAt = await _storage.read(key: 'accessSavedAt');

    if (token == null || savedAt == null) return null;

    final savedTime = int.tryParse(savedAt) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const expiration = 36000000; // 10 hours

    if ((currentTime - savedTime) < expiration) {
      return token;
    } else {
      return await refreshAccessToken();
    }
  }

  static Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reissue'),
      headers: {'Authorization': 'Bearer $refreshToken'},
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && data['isSuccess'] == true) {
      final newAccessToken = data['result']['accessToken'];
      await _storage.write(key: 'accessToken', value: newAccessToken);
      await _storage.write(key: 'accessSavedAt', value: DateTime.now().millisecondsSinceEpoch.toString());
      return newAccessToken;
    }

    return null;
  }

  static Future<Map<String, dynamic>?> tryAutoLogin() async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/reissue'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes))['result'];
    }

    return null;
  }
}