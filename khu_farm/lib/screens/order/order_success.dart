// order_success.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/services/storage_service.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// StorageService에서 사용자 정보를 불러와 상태를 업데이트합니다.
  Future<void> _loadUserInfo() async {
    final userInfo = await StorageService().getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  /// 저장된 사용자 유형에 따라 올바른 메인 페이지로 이동합니다.
  String _getMainRoute() {
    switch (_userInfo?.userType) {
      case 'ROLE_INDIVIDUAL':
        return '/consumer/main';
      case 'ROLE_BUSINESS':
        return '/retailer/main';
      case 'ROLE_FARMER':
        return '/farmer/main';
      default:
        return '/';
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

  void _navigateToOrderListPage() {
    String route = '/login'; // 기본값은 로그인 화면
    if (_userInfo != null) {
      switch (_userInfo!.userType) {
        case 'ROLE_INDIVIDUAL':
          route = '/consumer/mypage/order';
          break;
        case 'ROLE_BUSINESS':
          route = '/retailer/mypage/order';
          break;
        case 'ROLE_FARMER':
          route = '/farmer/mypage/order';
          break;
      }
    }
    // 모든 화면 스택을 제거하고 해당 라우트로 이동합니다.
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
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
    final Map<String, String> result =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String orderNumber = result['merchant_uid'] ?? 'N/A';
    // --- End of receiving data ---

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
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, _getMainRoute(), (route) => false),
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
                    //       '/consumer/notification/list',
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
                      onTap: () => Navigator.pushNamed(context, _getDibsRoute()),
                      child: Image.asset('assets/top_icons/dibs.png', width: 24, height: 24),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, _getCartRoute()),
                      child: Image.asset('assets/top_icons/cart.png', width: 24, height: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // --- This is the updated content section ---
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 마스코트 이미지
                  Image.asset(
                    'assets/mascot/login_mascot.png',
                    height: 100,
                  ),
                  const SizedBox(height: 24),

                  // 성공 메시지
                  const Text(
                    '주문이 완료되었습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 주문 번호
                  Text(
                    '주문번호 : $orderNumber',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40), // 콘텐츠와 버튼 사이 간격

                  // "주문 내역 확인하기" 버튼
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _navigateToOrderListPage,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '주문 내역 확인하기',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // "메인 페이지로 돌아가기" 버튼
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, _getMainRoute(), (route) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCF4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '메인 페이지로 돌아가기',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}