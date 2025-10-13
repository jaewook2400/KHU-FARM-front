import 'package:flutter/material.dart';

class ConsumerTopNotchHeader extends StatelessWidget {
  const ConsumerTopNotchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // 노치 배경
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight + screenHeight * 0.06,
          child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
        ),

        // 우상단 구름
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

        // 좌하단 구름
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

        // 상단 로고 및 아이콘 Row
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
      ],
    );
  }
}

class FarmerTopNotchHeader extends StatelessWidget {
  const FarmerTopNotchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // 노치 배경
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight + screenHeight * 0.06,
          child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
        ),

        // 우상단 구름
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

        // 좌하단 구름
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

        // 상단 로고 및 아이콘 Row
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
      ],
    );
  }
}

class RetailerTopNotchHeader extends StatelessWidget {
  const RetailerTopNotchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // 노치 배경
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight + screenHeight * 0.06,
          child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
        ),

        // 우상단 구름
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

        // 좌하단 구름
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

        // 상단 로고 및 아이콘 Row
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/retailer/notification/list',
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
      ],
    );
  }
}