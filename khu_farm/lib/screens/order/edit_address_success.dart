// order_success.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/services/storage_service.dart';

class OrderEditAddressSuccessScreen extends StatefulWidget {
  const OrderEditAddressSuccessScreen({super.key});

  @override
  State<OrderEditAddressSuccessScreen> createState() =>
      _OrderEditAddressSuccessScreenState();
}

class _OrderEditAddressSuccessScreenState
    extends State<OrderEditAddressSuccessScreen> {

  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await StorageService().getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  // ✨ 1. User Role에 따라 동적으로 라우트를 반환하는 함수들
  String _getMainRoute() {
    switch (_userInfo?.userType) {
      case 'ROLE_INDIVIDUAL':
        return '/consumer/main';
      case 'ROLE_BUSINESS':
        return '/retailer/main';
      case 'ROLE_FARMER':
        return '/farmer/main';
      default:
        return '/'; // 기본값 (혹은 로그인 화면)
    }
  }

  String _getDibsRoute() {
    switch (_userInfo?.userType) {
      case 'ROLE_INDIVIDUAL':
        return '/consumer/dib/list';
      case 'ROLE_BUSINESS':
        return '/retailer/dib/list';
      case 'ROLE_FARMER':
        return '/farmer/dib/list';
      default:
        return '/';
    }
  }

  String _getCartRoute() {
    switch (_userInfo?.userType) {
      case 'ROLE_INDIVIDUAL':
        return '/consumer/cart/list';
      case 'ROLE_BUSINESS':
        return '/retailer/cart/list';
      case 'ROLE_FARMER':
        return '/farmer/cart/list';
      default:
        return '/';
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
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, _getMainRoute(), (route) => false),
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
                          '/consumer/notification/list',
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
                      // ✨ 3. 찜 목록 아이콘 클릭 시 동적 라우트 적용
                      onTap: () => Navigator.pushNamed(context, _getDibsRoute()),
                      child: Image.asset('assets/top_icons/dibs.png',
                          width: 24, height: 24),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      // ✨ 4. 장바구니 아이콘 클릭 시 동적 라우트 적용
                      onTap: () => Navigator.pushNamed(context, _getCartRoute()),
                      child: Image.asset('assets/top_icons/cart.png',
                          width: 24, height: 24),
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
                  '배송지 변경이 완료되었습니다.',
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
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6FCF4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '돌아가기',
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