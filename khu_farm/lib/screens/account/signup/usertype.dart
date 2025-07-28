// 📄 lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  String? selectedType = "";

  void _handleNext() {
    if (selectedType == 'consumer') {
      Navigator.pushNamed(context, '/signup/consumer');
    } else if (selectedType == 'retailer') {
      Navigator.pushNamed(context, '/signup/retailer');
    } else if (selectedType == 'farmer') {
      Navigator.pushNamed(context, '/signup/farmer');
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
                      '/login',
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
              ],
            ),
          ),

          // 콘텐츠
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                top: statusBarHeight + screenHeight * 0.06 + 30,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 회원 유형 선택
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          'assets/icons/goback.png',
                          width: 18,
                          height: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '회원 유형 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),

                  Column(
                    children: [
                      const Text(
                        '회원 유형을 선택해주세요.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _UserTypeCard(
                            iconPath: 'assets/icons/consumer.png',
                            isSelected: selectedType == 'consumer',
                            onTap:
                                () => setState(() => selectedType = "consumer"),
                          ),
                          _UserTypeCard(
                            iconPath: 'assets/icons/retailer.png',
                            isSelected: selectedType == 'retailer',
                            onTap:
                                () => setState(() => selectedType = "retailer"),
                          ),
                          _UserTypeCard(
                            iconPath: 'assets/icons/farmer.png',
                            isSelected: selectedType == 'farmer',
                            onTap:
                                () => setState(() => selectedType = "farmer"),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 1),
                  const SizedBox(height: 1),

                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: selectedType == null ? null : _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedType == ""
                                    ? Colors.white
                                    : const Color(0xFF6FCF4B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child:
                              selectedType == ""
                                  ? const Text(
                                    "회원 유형을 선택하세요.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  )
                                  : const Text(
                                    '다음',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
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

// 회원유형 카드 위젯
class _UserTypeCard extends StatelessWidget {
  final String iconPath; // 아이콘 경로
  final VoidCallback onTap;
  final bool isSelected;

  const _UserTypeCard({
    required this.iconPath,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? const Color(0xFF6FCF4B) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF6FCF4B) : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              iconPath.isEmpty ? 'assets/icons/placeholder.png' : iconPath,
              height: 66,
              color: isSelected ? Colors.white : null,
            ),
            // const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
