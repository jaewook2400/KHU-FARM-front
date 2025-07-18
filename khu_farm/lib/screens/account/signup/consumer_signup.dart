import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConsumerSignupScreen extends StatefulWidget {
  const ConsumerSignupScreen({super.key});

  @override
  State<ConsumerSignupScreen> createState() => _ConsumerSignupScreenState();
}

class _ConsumerSignupScreenState extends State<ConsumerSignupScreen> {
  bool _agreeAll = false;
  bool _agreeService = false;
  bool _agreePrivacy = false;

  void showTermsModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '닫기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          // 노치 배경 이미지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + screenHeight * 0.06,
            child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),
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

          // 상단 로고
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
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 상단 뒤로가기 및 타이틀
          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            child: Row(
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
                  '회원가입 (개인)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // 입력 필드 및 체크박스 (스크롤 영역)
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 60,
              bottom: 80,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [
                  const _LabeledTextField(label: '이름', hint: '이름을 입력하세요.'),
                  const _LabeledTextField(label: '이메일', hint: '이메일을 입력하세요.'),
                  const _IdCheckField(),
                  const _LabeledTextField(
                    label: '전화번호',
                    hint: "'-'없이 10자리 숫자를 입력하세요.",
                  ),
                  const _LabeledTextField(
                    label: '비밀번호',
                    hint: '영문, 숫자, 특수문자 조합',
                    obscureText: true,
                  ),
                  const _LabeledTextField(
                    label: '비밀번호 확인',
                    hint: '비밀번호를 다시 입력하세요.',
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  // 약관 동의 체크박스들
                  _customCheckboxTile(
                    value: _agreeAll,
                    onChanged: (value) {
                      setState(() {
                        _agreeAll = value!;
                        _agreeService = value;
                        _agreePrivacy = value;
                      });
                    },
                    label: '모든 약관에 동의합니다.',
                    isAllAgreement: true, // 👈 추가
                  ),
                  _customCheckboxTile(
                    value: _agreeService,
                    onChanged: (value) {
                      setState(() {
                        _agreeService = value!;
                        _agreeAll = _agreeService && _agreePrivacy; // ✅ 개별 약관 모두 true면 _agreeAll도 true
                      });
                    },
                    label: '(필수) 이용약관에 동의합니다.',
                  ),
                  _customCheckboxTile(
                    value: _agreePrivacy,
                    onChanged: (value) {
                      setState(() {
                        _agreePrivacy = value!;
                        _agreeAll = _agreeService && _agreePrivacy; // ✅ 개별 약관 모두 true면 _agreeAll도 true
                      });
                    },
                    label: '(필수) 개인정보 수집 및 이용에 동의합니다.',
                  ),
                ],
              ),
            ),
          ),

          // 하단 고정 버튼
          Positioned(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: 30,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (_agreeService && _agreePrivacy)
                  ? () {
                      Navigator.pushNamed(context, '/signup/consumer/success');
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_agreeService && _agreePrivacy)
                      ? const Color(0xFF6FCF4B)
                      : const Color(0xFFE0E0E0), // 비활성 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  '회원가입 하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: (_agreeService && _agreePrivacy)
                        ? Colors.white
                        : Colors.grey, // 비활성 텍스트 색상
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customCheckboxTile({
  required bool value,
  required Function(bool?) onChanged,
  required String label,
  bool isAllAgreement = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isAllAgreement ? FontWeight.w800 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!isAllAgreement)
                InkWell(
                  onTap: () {
                    showTermsModal(
                      context,
                      '이용약관',
                                    '약관 내용\n' * 50, // 실제 약관
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '더보기',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                )
              ],
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
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdCheckField extends StatelessWidget {
  const _IdCheckField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
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
      ),
    );
  }
}