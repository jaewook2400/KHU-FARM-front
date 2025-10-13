import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/model/user_info.dart';

import '../../../shared/widgets/top_norch_header.dart';

class ConsumerMypageScreen extends StatefulWidget {
  const ConsumerMypageScreen({super.key});

  @override
  State<ConsumerMypageScreen> createState() => _ConsumerMypageScreenState();
}

class _ConsumerMypageScreenState extends State<ConsumerMypageScreen> {
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
                  '/consumer/daily',
                  ModalRoute.withName("/consumer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/harvest.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/consumer/harvest',
                  ModalRoute.withName("/consumer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/laicos.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/consumer/laicos',
                  ModalRoute.withName("/consumer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/select/mypage.png',
              onTap: () {},
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          ConsumerTopNotchHeader(),

          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: bottomPadding,
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
                      Navigator.pushNamed(context, '/consumer/mypage/info');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 이름/타입 + 이메일
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
                        '/consumer/mypage/order',
                      );
                    },
                  ),
                  _SectionItem(
                    label: '작성한 리뷰',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/consumer/mypage/review',
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
                        '/consumer/mypage/inquiry/personal',
                      );
                    },
                  ),
                  // _SectionItem(
                  //   label: '자주 묻는 질문',
                  //   onTap: () {
                  //     Navigator.pushNamed(
                  //       context,
                  //       '/consumer/mypage/inquiry/faq',
                  //     );
                  //   },
                  // ),
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
          '※ ‘판매 상품 문의’가 아닌 ‘앱 관련 문의’는 ‘ansy00@khu.ac.kr’로 남겨 주세요.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 60),
        Text(
          '모든 거래에 대한 책임과 배송·교환·환불 민원은 쿠팜에서 접수·관리하며, 실제 처리(재배송·수거 등)는 협력 출고처가 수행합니다.\n문의: ansy00@khu.ac.kr, 0502-1949-1224',
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
