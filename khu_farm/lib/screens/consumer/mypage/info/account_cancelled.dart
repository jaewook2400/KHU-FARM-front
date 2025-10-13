import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/shared/widgets/top_norch_header.dart';

class ConsumerAccountCancelledScreen extends StatelessWidget {
  const ConsumerAccountCancelledScreen({super.key});

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
          ConsumerTopNotchHeader(),

          Positioned(
            top: statusBarHeight + screenHeight * 0.06,
            left: 0,
            right: 0,
            bottom: 84, // 버튼 높이(48) + 안전영역 여백
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/mascot/sad_mascot.png',
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '계정 삭제가 완료되었습니다.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '안녕히가세요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 하단 닫기 버튼
          Positioned(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  // 1. StorageService에 저장된 모든 데이터 삭제
                  await StorageService().clearAllData();

                  // 2. 위젯이 마운트 상태인지 확인 후 화면 이동
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/', // 로그인 또는 시작 화면으로 이동
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE84C4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '닫기',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
