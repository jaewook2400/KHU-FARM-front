// order_success.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/services/storage_service.dart';

class FarmerDeleteProductSuccessScreen extends StatelessWidget {
  const FarmerDeleteProductSuccessScreen({super.key});

  void _navigateToList(BuildContext context) {
    // farmer main까지 스택을 모두 제거하고 manage list 화면으로 이동
    Navigator.popUntil(context, ModalRoute.withName('/farmer/mypage/manage/product'));
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
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       '/farmer/notification/list',
                    //     );
                    //   },
                    //   child: Image.asset(
                    //     'assets/top_icons/notice.png',
                    //     width: 24,
                    //     height: 24,
                    //   ),
                    // ),
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
                  '삭제되었습니다.',
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
                onPressed: () => _navigateToList(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '닫기',
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