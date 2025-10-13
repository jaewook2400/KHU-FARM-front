import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/shared/widgets/top_norch_header.dart';

class ConsumerFAQListScreen extends StatelessWidget {
  const ConsumerFAQListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 시스템 UI 투명화
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // 화면 크기 및 상태바 높이
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // 예시 질문 리스트
    final List<String> questions = [
      '문의 제목',
      '문의 제목',
      '문의 제목',
      '문의 제목',
      '문의 제목',
      '문의 제목',
    ];
    final String sampleAnswer = '답변 내용이 여기에 표시됩니다. 자세한 안내를 위해 내용을 입력해 주세요.';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ConsumerTopNotchHeader(),

          // 콘텐츠: FAQ 리스트
          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: 0,
            child: Column(
              children: [
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
                      '자주 묻는 질문',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            questions[index],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          children: [
                            Text(
                              sampleAnswer,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
