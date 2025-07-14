import 'package:flutter/material.dart';

class FarmerAddProductPreviewScreen extends StatefulWidget {
  const FarmerAddProductPreviewScreen({super.key});

  @override
  State<FarmerAddProductPreviewScreen> createState() =>
      _FarmerAddProductPreviewScreen();
}

class _FarmerAddProductPreviewScreen
    extends State<FarmerAddProductPreviewScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> prevArgs = ModalRoute.of(context)!
        .settings
        .arguments as Map<String, dynamic>;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 상단 노치 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + 40,
            child:
                Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),

          // 상단 아이콘 row
          Positioned(
            top: statusBarHeight,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'KHU:FARM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Image.asset('assets/top_icons/notice.png',
                        width: 24, height: 24),
                    const SizedBox(width: 12),
                    Image.asset('assets/top_icons/dibs.png',
                        width: 24, height: 24),
                    const SizedBox(width: 12),
                    Image.asset('assets/top_icons/cart.png',
                        width: 24, height: 24),
                  ],
                ),
              ],
            ),
          ),

          Positioned.fill(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 뒤로가기 + 제목
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/icons/goback.png',
                          width: 18, height: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('제품 추가하기 (미리보기)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
              ]
            )
          ),

          // 하단 고정 버튼
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6FCF4B)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      '이전',
                      style: TextStyle(color: Color(0xFF6FCF4B)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      //
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FCF4B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('완료하기',
                    style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}