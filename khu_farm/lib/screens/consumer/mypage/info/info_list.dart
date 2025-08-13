import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:http/http.dart' as http;

class ConsumerInfoListScreen extends StatelessWidget {
  const ConsumerInfoListScreen({super.key});

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
          // 노치 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + screenHeight * 0.06,
            child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),

          // 우상단 이미지
          Positioned(
            top: 0,
            right: 0,
            height: statusBarHeight * 1.2,
            child: Image.asset(
              'assets/notch/morning_right_up_cloud.png',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
            ),
          ),

          // 좌하단 이미지
          Positioned(
            top: statusBarHeight,
            left: 0,
            height: screenHeight * 0.06,
            child: Image.asset(
              'assets/notch/morning_left_down_cloud.png',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
            ),
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
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/consumer/main',
                      (route) => false,
                    );
                  },
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
                      onTap: () {
                        Navigator.pushNamed(context, '/consumer/dib/list');
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
                        Navigator.pushNamed(context, '/consumer/cart/list');
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
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← 내 정보 타이틀
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/icons/goback.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '내 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20), // 타이틀과 리스트 사이의 간격

                // --- 🖼️ 이 부분이 수정되었습니다 ---
                // Expanded 대신 Column을 직접 사용
                Column(
                  children: [
                  //   _OptionItem(
                  //     label: '회원 정보 수정',
                  //     onTap: () {
                  //       Navigator.pushNamed(
                  //         context,
                  //         '/consumer/mypage/info/edit/profile',
                  //       );
                  //     },
                  //   ),
                  // const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _OptionItem(
                      label: '비밀번호 수정',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/consumer/mypage/info/edit/pw',
                        );
                      },
                    ),
                  // const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _OptionItem(
                      label: '배송지 관리',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/consumer/mypage/info/edit/address',
                        );
                      },
                    ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _OptionItem(
                      label: '로그아웃',
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => _LogoutConfirmDialog(),
                          );
                      },
                    ),
                    _OptionItem(
                      label: '계정 탈퇴',
                      color: Colors.red, // 색상 지정
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/consumer/mypage/info/cancel',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color; // 색상 파라미터 추가 (nullable)

  const _OptionItem({
    required this.label,
    required this.onTap,
    this.color, // 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? const Color(0xFF333333);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: itemColor, // 텍스트 색상 적용
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: itemColor, // 아이콘 색상 적용
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  Future<void> _handleLogout(BuildContext context) async {
    final accessToken = await StorageService.getAccessToken();
    final refreshToken = await StorageService.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      print('Error: Tokens not found.');
      return;
    }

    // --- 🖼️ 이 부분이 수정되었습니다 ---
    final headers = {
      'Authorization': 'Bearer $accessToken',
      // refresh_token을 Cookie 헤더에 포함시킵니다.
      'Cookie': 'refresh_token=$refreshToken',
    };
    // --- 여기까지 ---

    final uri = Uri.parse('$baseUrl/auth/logout');

    try {
      // 요청 시 body를 제거합니다.
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        print('Logout successful');
      } else {
        print('Logout failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('An error occurred during logout: $e');
    } finally {
      await StorageService().clearAllData();

      if (context.mounted) {
        Navigator.pop(context); // 확인 다이얼로그 닫기
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _LogoutSuccessDialog(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 8,
                top: 51, // 기존 40에서 더 아래로 내려 조정
                child: Image.asset(
                  'assets/mascot/login_mascot.png',
                  width: 50,
                  height: 50,
                ),
              ),
              // 콘텐츠
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '정말 로그아웃 하시겠습니까?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50), // 마스코트 공간 확보
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCF4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('예',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6FCF4B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '아니요',
                        style: TextStyle(color: Color(0xFF6FCF4B)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _LogoutSuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: 8,
                  top: 13,
                  child: Image.asset(
                    'assets/mascot/login_mascot.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('로그아웃 되었습니다.'),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FCF4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('닫기',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}