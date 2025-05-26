// 📄 lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConsumerSignupScreen extends StatefulWidget {
  const ConsumerSignupScreen({super.key});

  @override
  State<ConsumerSignupScreen> createState() => _ConsumerSignupScreenState();
}

class _ConsumerSignupScreenState extends State<ConsumerSignupScreen> {
  bool _agreedToTerms = false;

  Future<void> _showTermsDialog() async {
    // showDialog 의 리턴 타입을 bool 로 명시
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => const TermsDialog(),
    );
    // null 이 아니고 true 면 체크박스 활성화
    if (agreed == true) {
      setState(() {
        _agreedToTerms = true;
      });
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
                    // TODO: 로고 터치 시 동작
                  },
                  child: const Text(
                    'KHU:FARM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
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
                        '회원가입 (개인)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const _LabeledTextField(
                            label: '이름',
                            hint: '이름을 입력하세요.',
                          ),
                          const _LabeledTextField(
                            label: '이메일',
                            hint: '이메일을 입력하세요.',
                          ),
                          const _IdCheckField(),
                          const _LabeledTextField(
                            label: '전화번호',
                            hint: "'-'없이 기호를 제외한 10자리 숫자를 입력하세요.",
                          ),
                          const _LabeledTextField(
                            label: '비밀번호',
                            hint: '영문, 숫자, 특수문자 조합',
                            obscureText: true,
                          ),
                          const _LabeledTextField(
                            label: '비밀번호 확인',
                            hint: '영문, 숫자, 특수문자 조합',
                            obscureText: true,
                          ),

                          const SizedBox(height: 12),

                          // ✅ 약관 동의 체크박스 (임시 비활성)
                          GestureDetector(
                            onTap: _showTermsDialog,
                            child: Row(
                              children: [
                                // onChanged: null 로 읽기 전용
                                Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: null,
                                ),
                                const Text('모든 약관에 동의합니다.'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ✅ 회원가입 버튼 (비활성 디자인)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/signup/consumer/success',
                                );
                              }, // 이후 활성화 로직 연결
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6FCF4B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                '회원가입 하기',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;

  const _LabeledTextField({
    required this.label,
    required this.hint,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _IdCheckField extends StatelessWidget {
  const _IdCheckField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Text('아이디', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '아이디를 입력하세요.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {}, // 중복확인 기능 연결 예정
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('중복 확인'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '영문과 숫자로 입력해 주세요.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 320,
        height: 480,
        child: Column(
          children: [
            // 1) 타이틀 (옵션)
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: 8,
              ),
              child: Text(
                '약관 제목',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // 2) 스크롤 가능한 약관 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Text(
                    // 여기에 실제 약관 텍스트를 넣으세요
                    '약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용'
                    '약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용'
                    '약관 내용약관 내용약관 내용약관 내용약관 내용약관 내용',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),

            // 3) 하단 버튼 (닫기 / 동의)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('닫기'),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('동의'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
