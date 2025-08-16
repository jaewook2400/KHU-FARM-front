// order_success.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/services/storage_service.dart';

class FarmerDeleteProductScreen extends StatefulWidget {
  const FarmerDeleteProductScreen({super.key});

  @override
  State<FarmerDeleteProductScreen> createState() => _FarmerDeleteProductScreen();
}

class _FarmerDeleteProductScreen extends State<FarmerDeleteProductScreen> {
  bool _isDeleting = false;

  // 상품 삭제 API 호출 함수
  Future<void> _deleteProduct(int fruitId) async {
    setState(() => _isDeleting = true);

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null || !mounted) {
      setState(() => _isDeleting = false);
      return;
    }

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/fruits/seller/$fruitId');

    try {
      final response = await http.delete(uri, headers: headers);
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 삭제 성공 시 true를 반환하며 이전 화면으로 돌아감
        Navigator.pushReplacementNamed(
          context,
          '/farmer/mypage/manage/product/delete/success',
        );
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        throw Exception('상품 삭제 실패: ${data['message']}');
      }
    } catch (e) {
      print('상품 삭제 오류: $e');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // --- Receive the payment result from the previous screen ---
    final Fruit fruit = ModalRoute.of(context)!.settings.arguments as Fruit;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background and Header UI
          Positioned(
            top: 0, left: 0, right: 0,
            height: statusBarHeight + screenHeight * 0.06,
            child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 0, right: 0,
            height: statusBarHeight * 1.2,
            child: Image.asset('assets/notch/morning_right_up_cloud.png', fit: BoxFit.cover, alignment: Alignment.topRight),
          ),
          Positioned(
            top: statusBarHeight, left: 0,
            height: screenHeight * 0.06,
            child: Image.asset('assets/notch/morning_left_down_cloud.png', fit: BoxFit.cover, alignment: Alignment.topRight),
          ),
          Positioned(
            top: statusBarHeight,
            height: statusBarHeight + screenHeight * 0.02,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/farmer/main', (route) => false),
                  child: const Text(
                    'KHU:FARM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LogoFont',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/farmer/notification/list',
                        );
                      },
                      child: Image.asset(
                        'assets/top_icons/notice.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/farmer/dib/list');
                      },
                      child: Image.asset(
                        'assets/top_icons/dibs.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/farmer/cart/list');
                      },
                      child: Image.asset(
                        'assets/top_icons/cart.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // --- This is the updated content section ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/mascot/login_mascot.png', height: 100),
                const SizedBox(height: 24),
                const Text(
                  '정말 삭제하시겠습니까?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isDeleting ? null : () => _deleteProduct(fruit.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isDeleting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text(
                        '제품 삭제하기',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}