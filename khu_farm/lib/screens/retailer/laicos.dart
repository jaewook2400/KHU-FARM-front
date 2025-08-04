import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/screens/chatbot.dart';

const Color highlightColor = Color(0xFFE5533D);
const Color titleColor = Color(0xFF333333);
const Color textColor = Color(0xFF555555);
const Color subtitleColor = Color(0xFF888888);

class Member {
  final String name;
  final String role;
  Member(this.name, this.role);
}


class RetailerLaicosScreen extends StatelessWidget {
  const RetailerLaicosScreen({super.key});

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
                  '/retailer/daily',
                  ModalRoute.withName("/retailer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/stock.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/stock',
                  ModalRoute.withName("/retailer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/harvest.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/harvest',
                  ModalRoute.withName("/retailer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/select/laicos.png',
              onTap: () {},
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/mypage.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/mypage',
                  ModalRoute.withName("/retailer/main"),
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
                      '/retailer/main',
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
                    //       '/retailer/notification/list',
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
                        Navigator.pushNamed(context, '/retailer/dib/list');
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
                        Navigator.pushNamed(context, '/retailer/cart/list');
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
            padding: EdgeInsets.only(top: statusBarHeight + screenHeight * 0.07),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('KHU:FARM — 우리 팀을 소개합니다.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor)),
                  const SizedBox(height: 12,),
                  Divider(
                    indent: screenWidth * 0.4,
                    endIndent: screenWidth * 0.4,
                  ),
                  const SizedBox(height: 12,),
                  const Text("흠집 난 과일의 달콤함과 특별함을 세상에 알리고자 합니다.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: textColor, height: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('“우리는 ‘못난이 과일’이 버려지지 않고 새로운 가치를 얻을 수 있도록,\n농가와 소비자가 직접 연결되는 플랫폼을 만들고 있습니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: textColor, height: 1.5)),
                  const SizedBox(height: 12),
                  const Text('팀원들 각자의 전문성을 발휘해 푸드 웨이스트를 줄이고\n농가와 소비자 모두가 웃을 수 있는 따뜻한 연결을 만드는 것이\n쿠팜(KHU:FARM)의 목표입니다.”', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: textColor, height: 1.5)),
                  const SizedBox(height: 12,),
                  Divider(
                    indent: screenWidth * 0.4,
                    endIndent: screenWidth * 0.4,
                  ),
                  const SizedBox(height: 12,),
                  
                  // --- 테크 프로덕트팀 ---
                  const Text('테크 프로덕트팀', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor)),
                  const Text('Digital Product', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: textColor, height: 1.5)),
                  const SizedBox(height: 20),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // 1. stretch로 높이를 꽉 채움
                      children: [
                        // << 왼쪽 자식 (Column) >>
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 2. 내부 항목을 위아래로 분산 정렬
                            children: [
                              // 왼쪽 영역의 모든 내용을 배치 (SizedBox 제거)
                              _LeftItem(
                                content: RichText(text: const TextSpan(style: TextStyle(fontSize: 14, color: textColor, height: 1.4), children: [
                                  TextSpan(text: '경희대학교 재학생과 졸업생이 모여 만든 어플, '),
                                  TextSpan(text: '쿠팜(KHU:FARM)', style: TextStyle(color: Color(0xFF7AC833), fontWeight: FontWeight.bold)),
                                ])),
                              ),
                              _LeftItem(
                                content: RichText(text: const TextSpan(style: TextStyle(fontSize: 14, color: textColor, height: 1.4), children: [
                                  TextSpan(text: '못난이 과일과 판매 경로 자체에 대한 인지도 부족(문제 인식) - '),
                                  TextSpan(text: '어플 개발', style: TextStyle(color: Color(0xFFF65353), fontWeight: FontWeight.bold)),
                                  TextSpan(text: ' 결심'),
                                ])),
                              ),
                              _LeftItem(
                                content: const Text('각자의 재능을 환경보호(E)와 농가상생(S) 실현에 기여하려는 열정과 포부의 팀\n2025 상반기, 어플 프로토타입 제작 및 개발 착수, 8월 출시 예상', style: TextStyle(fontSize: 14, color: textColor, height: 1.4)),
                              ),
                              const Divider(),
                              _LeftItem(
                                content: const Text('연장 운영과 마케팅 — 신규 팀원\n건국대학교 졸업생 영입, 기획 봉사에 동행', style: TextStyle(fontSize: 14, color: textColor, height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24), // 좌우 영역 사이의 간격
                        // << 오른쪽 자식 (Column) >>
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 2. 내부 항목을 위아래로 분산 정렬
                            children: [
                              // 오른쪽 영역의 모든 내용을 배치 (SizedBox 제거)
                              _MemberItem(member: Member('안소연', '테크 프로덕트팀 기획/제반 영역 총괄(PM)')),
                              _MemberItem(member: Member('김성욱', '경희대학교 컴퓨터공학과 졸업예정, 개발자')),
                              _MemberItem(member: Member('정지안', '경희대학교 컴퓨터공학과 석사과정, 개발자')),
                              _MemberItem(member: Member('서은지', '경희대학교 시각디자인학과 졸업, 디자이너')),
                              _MemberItem(member: Member('양희창', '테크 프로덕트팀 대외협력/마케팅')),
                              _MemberItem(member: Member('차연지', '테크 프로덕트팀 대외협력/마케팅')),
                              _MemberItem(member: Member('정태현', '건국대학교 경영학과 졸업, 마케팅/DA')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12,),
                  Divider(
                    indent: screenWidth * 0.4,
                    endIndent: screenWidth * 0.4,
                  ),
                  const SizedBox(height: 12,),

                  // --- 라이브 필드팀 ---
                  const Text('라이브 필드팀', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor)),
                  const Text('On-site Campaign', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: textColor, height: 1.5)),
                  const SizedBox(height: 20),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // 1. stretch로 높이를 꽉 채움
                      children: [
                        // << 왼쪽 자식 (Column) >>
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 2. 내부 항목을 위아래로 분산 정렬
                            children: [
                              // 왼쪽 영역의 모든 내용을 배치 (SizedBox 제거)
                              _LeftItem(
                                content: RichText(text: const TextSpan(style: TextStyle(fontSize: 14, color: textColor, height: 1.4), children: [
                                  TextSpan(text: '경희대학교 중앙동아리, \n라이코스(LAICOS) 경희 지부 🌐'),
                                ])),
                              ),
                              const Divider(),
                              _LeftItem(
                                content: RichText(text: const TextSpan(style: TextStyle(fontSize: 14, color: textColor, height: 1.4), children: [
                                  TextSpan(text: '서울시 자원봉사센터 주관, ‘서울동행기획 2기’ 참가 - '),
                                  TextSpan(text: '쿠팜(KHU:FARM)', style: TextStyle(color: Color(0xFF7AC833), fontWeight: FontWeight.bold)),
                                  TextSpan(text: '팀 결성'),
                                ])),
                              ),
                              _LeftItem(
                                content: RichText(text: const TextSpan(style: TextStyle(fontSize: 14, color: textColor, height: 1.4), children: [
                                  TextSpan(text: '2025 상반기 대동제 부스, 못난이 과일 활용한'),
                                  TextSpan(text: '‘푸드 리버브’', style: TextStyle(color: Color(0xFFF65353), fontWeight: FontWeight.bold)),
                                  TextSpan(text: '주스 무료 나눔 행사 및 캠페인'),
                                ])),
                              ),
                              const Divider(),
                              _LeftItem(
                                content: const Text('추가 팀원 모집 및 ‘테크 프로덕트’팀 신설', style: TextStyle(fontSize: 14, color: textColor, height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24), // 좌우 영역 사이의 간격
                        // << 오른쪽 자식 (Column) >>
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 2. 내부 항목을 위아래로 분산 정렬
                            children: [
                              // 오른쪽 영역의 모든 내용을 배치 (SizedBox 제거)
                              _MemberItem(member: Member('강수민', '2025 상반기 라이코스 회장, 행사 총괄')),
                              _MemberItem(member: Member('차연지', '2025 상반기 라이코스 부회장, 행사 총괄')),
                              _MemberItem(member: Member('박보경', '홍보 담당, 하반기 라이코스 회장')),
                              _MemberItem(member: Member('강혜원', '2025 상반기 라이코스 부회장, 총무·회계')),
                              _MemberItem(member: Member('박진서', '운영 지원 및 회의록 총괄 담당')),
                              _MemberItem(member: Member('양희창', '운영 지원 및 테크 프로덕트팀 대외협력')),
                              _MemberItem(member: Member('안소연', '운영 지원 및 테크 프로덕트팀 기획/총괄')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                ],
              ),
            ),
          ),

          // 채팅 모달 버튼 (고정)
          // Positioned(
          //   bottom: screenWidth * 0.02,
          //   right: screenWidth * 0.02,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.white,
          //       border: Border.all(color: Colors.grey.shade300),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 4,
          //           offset: const Offset(0, 2),
          //         ),
          //       ],
          //     ),
          //     child: GestureDetector(
          //       onTap: () {
          //         showChatbotModal(context);
          //       },
          //       child: Image.asset(
          //         'assets/chat/chatbot_icon.png',
          //         width: 68,
          //         height: 68,
          //       ),
          //     ),
          //   ),
          // ),
        ],
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: subtitleColor)),
        const SizedBox(height: 12),
        const Divider(color: Colors.black26, thickness: 1),
      ],
    );
  }
}

// 왼쪽 영역의 각 항목을 구성하는 위젯
class _LeftItem extends StatelessWidget {
  final Widget content;
  const _LeftItem({required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 6.0), child: Icon(Icons.square, size: 8, color: textColor)),
        const SizedBox(width: 12),
        Expanded(child: content),
      ],
    );
  }
}

// 오른쪽 영역의 멤버 정보를 구성하는 위젯
class _MemberItem extends StatelessWidget {
  final Member member;
  const _MemberItem({required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(member.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: titleColor)),
        const SizedBox(width: 8),
        Expanded(child: Text(member.role, style: const TextStyle(fontSize: 14, color: textColor, height: 1.3))),
      ],
    );
  }
}

/// 팀 소개 레이아웃을 구성하는 핵심 위젯 (독립적인 2단 구조)
class _TeamLayoutRow extends StatelessWidget {
  final Widget? leftContent;
  final List<Member> rightContent;

  const _TeamLayoutRow({this.leftContent, this.rightContent = const []});

  @override
  Widget build(BuildContext context) {
    // 화면 너비에 기반한 고정 너비 계산
    final totalContentWidth = MediaQuery.of(context).size.width - 32; // 양쪽 패딩 16*2
    const spacerWidth = 24.0;
    final leftWidth = (totalContentWidth - spacerWidth) * 0.43; // 왼쪽 영역 너비
    final rightWidth = (totalContentWidth - spacerWidth) * 0.57; // 오른쪽 영역 너비

    // 왼쪽 영역 위젯
    final Widget leftPane = Container(
      width: leftWidth,
      child: leftContent != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(top: 6.0), child: Icon(Icons.square, size: 8, color: textColor)),
                const SizedBox(width: 12),
                Expanded(child: leftContent!),
              ],
            )
          : null, // 내용이 없으면 Container는 비어있게 됨
    );

    // 오른쪽 영역 위젯
    final Widget rightPane = Container(
      width: rightWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rightContent.map((member) => _MemberItem(member: member)).toList(),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftPane, // 왼쪽 영역
          const SizedBox(width: spacerWidth),
          rightPane, // 오른쪽 영역
        ],
      ),
    );
  }
}
