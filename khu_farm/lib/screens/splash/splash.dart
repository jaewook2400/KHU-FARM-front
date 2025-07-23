import 'package:flutter/material.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:khu_farm/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 스플래시 화면을 위한 최소 대기 시간
    await Future.delayed(const Duration(seconds: 1));

    final accessToken = await StorageService.getAccessToken();
    final refreshToken = await StorageService.getRefreshToken();
    final userInfo = await StorageService().getUserInfo();

    if (!mounted) return;

    // 토큰과 유저 정보가 모두 있을 경우, 토큰 재발급 시도
    if (accessToken != null && refreshToken != null && userInfo != null) {
      try {
        final uri = Uri.parse('$baseUrl/auth/reissue');
        final headers = {'Authorization': 'Bearer $accessToken','Cookie': 'refresh_token=$refreshToken'};

        final response = await http.post(uri, headers: headers);

        // 1. 토큰 재발급 성공
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data['isSuccess'] == true) {
            final newAccessToken = data['result']['accessToken'];
            // 새로운 accessToken으로 업데이트
            await StorageService.saveTokens(newAccessToken, refreshToken);
            print('Access Token 재발급 성공');
            _navigateToMainPage(userInfo); // 메인 페이지로 이동
            return;
          }
        }
        // 2. 토큰 재발급 실패 (리프레시 토큰 만료 등)
        throw Exception('Failed to reissue token');
      } catch (e) {
        print('토큰 재발급 실패: $e');
        // 실패 시 모든 정보를 지우고 로그인 화면으로 보냄
        await StorageService().clearAllData();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // 3. 저장된 정보가 없으면 로그인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateToMainPage(UserInfo userInfo) {
    String route;
    switch (userInfo.userType) {
      case 'ROLE_FARMER':
        route = '/farmer/main';
        break;
      case 'ROLE_INDIVIDUAL':
        route = '/consumer/main';
        break;
      case 'ROLE_BUSINESS':
        route = '/retailer/main';
        break;
      default:
        route = '/login';
    }
    Navigator.pushReplacementNamed(context, route);
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}