// 📄 lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/model/weather_data.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/services/weather_service.dart';
import 'package:khu_farm/shared/text_styles.dart';

import '../../shared/widgets/top_norch_header.dart';


class ConsumerMainScreen extends StatefulWidget {
  const ConsumerMainScreen({super.key});

  @override
  State<ConsumerMainScreen> createState() => _ConsumerMainScreenState();
}

class _ConsumerMainScreenState extends State<ConsumerMainScreen> {
  UserInfo? _userInfo;
  final WeatherService _weatherService = WeatherService();
  Future<WeatherData>? _weatherDataFuture;

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

  String _getWeatherIconPath(String pty, String sky) {
    // PTY(강수형태): 없음(0), 비(1), 비/눈(2), 눈(3), 소나기(4)
    // SKY(하늘상태): 맑음(1), 구름많음(3), 흐림(4)
    switch (pty) {
      case '1': // 비
      case '2': // 비/눈 (-> 비 아이콘으로 표시)
      case '4': // 소나기 (-> 비 아이콘으로 표시)
        return 'assets/weather/rain.png';
      case '3': // 눈
        return 'assets/weather/snow.png';
      case '0': // 강수 없음 -> 하늘 상태(SKY)에 따라 결정
      default:
        switch (sky) {
          case '1': // 맑음
            return 'assets/weather/sunny.png';
          case '3': // 구름많음 (-> 흐림 아이콘으로 표시)
          case '4': // 흐림
            return 'assets/weather/cloudy.png';
          default:
            return 'assets/weather/sunny.png'; // 기본값 (맑음)
        }
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
    final formatter = NumberFormat('#,###');

    // Use the fetched user data, with fallback values
    final String userName = _userInfo?.userName ?? '...';
    final int totalWeight = _userInfo?.totalPurchaseWeight ?? 0;
    final String savedAmount = formatter.format(_userInfo?.totalDiscountPrice ?? 0);

    return Scaffold(
      extendBodyBehindAppBar: true,

      bottomNavigationBar: Container(
        color: const Color(0xFFB6832B),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
              iconPath: 'assets/bottom_navigator/unselect/mypage.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/consumer/mypage',
                  ModalRoute.withName("/consumer/main"),
                );
              },
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          const FarmerTopNotchHeader(),

          // 콘텐츠
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.1,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1) 오늘의 날씨 카드
                // FutureBuilder<WeatherData>(
                //   future: _weatherDataFuture,
                //   builder: (context, snapshot) {
                //     // 기본 카드 디자인
                //     Widget weatherContent;
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       weatherContent = const CircularProgressIndicator(strokeWidth: 2);
                //     } else if (snapshot.hasError) {
                //       weatherContent = const Text('날씨 오류', style: TextStyle(fontSize: 12));
                //     } else if (snapshot.hasData) {
                //       final weather = snapshot.data!;
                //       weatherContent = Column(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: [
                //           const Text('오늘의 날씨', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                //           const SizedBox(height: 8),
                //           Image.asset(_getWeatherIconPath(weather.pty, weather.sky), width: 32, height: 32),
                //           const SizedBox(height: 4),
                //           Text('${weather.tempMax}°C / ${weather.tempMin}°C', style: const TextStyle(fontSize: 13)),
                //         ],
                //       );
                //     } else {
                //       weatherContent = const Text('날씨 정보 없음', style: TextStyle(fontSize: 12));
                //     }

                //     return Container(
                //       width: screenWidth * 0.4,
                //       alignment: Alignment.center,
                //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(12),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black.withOpacity(0.05),
                //             blurRadius: 8,
                //             offset: const Offset(0, 4),
                //           ),
                //         ],
                //       ),
                //       child: weatherContent,
                //     );
                //   },
                // ),
                const SizedBox(height: 80,),

                const SizedBox(height: 40),

                // 2) 환영 문구
                Text(
                  'WELCOME TO\nKHU:FARM!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mainpageText
                ),

                const SizedBox(height: 40),

                // 3) 마스코트 이미지
                SizedBox(
                  width: double.infinity,
                  // height: Row 높이 + 카드 높이 – 겹치는 만큼
                  height: screenWidth * 0.4 + 60,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── 1) Row 위젯 ─────────────────────
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 50, left: 10),
                              child: Text(
                                '공식 마스코트\n나쿠',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: screenWidth * 0.05,
                              ),
                              child: Image.asset(
                                'assets/mascot/main_mascot.png',
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── 2) 카드 (Row 아래로 20px 겹치게) ─────────────────────
                      Positioned(
                        top: screenWidth * 0.4 - 40,
                        left: 0,
                        right: 0,
                        child: Container(
                          // 카드 넓이는 부모 가득 채우기
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE84C4C),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$userName님이 구출한 모난이는\n총 ${totalWeight}kg 이에요!\n구매해주셔서 감사합니다♡',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5) 구매 문구
                Text(
                  '약 $savedAmount원 저렴하게 샀어요!',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
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
