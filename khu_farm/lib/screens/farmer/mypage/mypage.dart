import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/model/user_info.dart';

class FarmerMypageScreen extends StatefulWidget {
  const FarmerMypageScreen({super.key});

  @override
  State<FarmerMypageScreen> createState() => _FarmerMypageScreenState();
}

class _FarmerMypageScreenState extends State<FarmerMypageScreen> {
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// Loads user information from storage and updates the state.
  Future<void> _loadUserInfo() async {
    final userInfo = await StorageService().getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  String _getUserTypeString(String? userType) {
    switch (userType) {
      case 'ROLE_INDIVIDUAL':
        return '일반회원';
      case 'ROLE_BUSINESS':
        return '기업회원';
      case 'ROLE_FARMER':
        return '농가회원';
      default:
        return '회원';
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,

      bottomNavigationBar: Container(
        color: const Color(0xFFB6832B),
        padding: EdgeInsets.only(
          // top: 20,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/daily.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/farmer/daily',
                  ModalRoute.withName("/farmer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/stock.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/farmer/stock',
                  ModalRoute.withName("/farmer/main"),
                );
              },
            ),
            // _NavItem(
            //   iconPath: 'assets/bottom_navigator/unselect/harvest.png',
            //   onTap: () {
            //     Navigator.pushNamedAndRemoveUntil(
            //       context,
            //       '/farmer/harvest',
            //       ModalRoute.withName("/farmer/main"),
            //     );
            //   },
            // ),
            // _NavItem(
            //   iconPath: 'assets/bottom_navigator/unselect/laicos.png',
            //   onTap: () {
            //     Navigator.pushNamedAndRemoveUntil(
            //       context,
            //       '/farmer/laicos',
            //       ModalRoute.withName("/farmer/main"),
            //     );
            //   },
            // ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/select/mypage.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/farmer/mypage',
                  ModalRoute.withName("/farmer/main"),
                );
              },
            ),
          ],
        ),
      ),

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
                      '/farmer/main',
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

          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: 10,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뒤로가기 + 제목
                  const SizedBox(width: 8),
                  const Text(
                    'My Page',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),

                  // 1) 회원 정보
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/farmer/mypage/info');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Display user info dynamically
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // Show user name or a loading message
                                _userInfo != null
                                    ? '${_userInfo!.userName}님 어서오세요. [${_getUserTypeString(_userInfo!.userType)}]'
                                    : '로딩 중...',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Show user ID (email) or an empty string
                                _userInfo?.email.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.15,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/farmer/mypage/manage');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FCF4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          '우리 농가 관리하기',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(),

                  // 2) 배송 섹션
                  const SizedBox(height: 12),
                  const Text(
                    '배송',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _SectionItem(
                    label: '주문/배송',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/farmer/mypage/order',
                      );
                    },
                  ),
                  _SectionItem(
                    label: '작성한 리뷰',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/farmer/mypage/review',
                      );
                    },
                  ),

                  const Divider(),

                  // 3) 고객센터 섹션
                  const SizedBox(height: 12),
                  const Text(
                    '고객센터',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _SectionItem(
                    label: '1:1 문의',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/farmer/mypage/inquiry/personal',
                      );
                    },
                  ),
                  // _SectionItem(
                  //   label: '자주 묻는 질문',
                  //   onTap: () {
                  //     Navigator.pushNamed(
                  //       context,
                  //       '/farmer/mypage/inquiry/faq',
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 20),
                    _buildBusinessInfoFooter(),
                    const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '개별 판매자가 등록한 모든 거래에 대한 배송, 교환, 환불 민원 등의 의무와 책임은 각 판매자가 부담하며, 경우에 따라 \'쿠팜(KHUFARM)\'은 통신판매중개업자로서 그 절차를 보조할 수 있습니다. 자세한 문의는 판매 상품 내 \'문의\'로 남겨주시면 빠른 시일 내 순차적으로 도와 드리겠습니다.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Text(
          '상호명: 쿠팜(KHUFARM)\n'
          '사업자 등록: 안소연, 272-20-02300\n'
          '주소 : 서울특별시 강남구 강남대로 342, 5층 501-12호(역삼동,역삼빌딩)\n'
          '전화 : 0502-1949-1224\n'
          '통신판매신고번호: 2025-서울강남-03927',
          style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }
}

class _SectionItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SectionItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _NavItem({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.15;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Image.asset(iconPath, width: size, height: size)],
      ),
    );
  }
}
