import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';

class AccountFind extends StatefulWidget {
  const AccountFind({super.key});

  @override
  State<AccountFind> createState() => _AccountFindState();
}

class _AccountFindState extends State<AccountFind> {
  final TextEditingController idNameController = TextEditingController();
  final TextEditingController idEmailController = TextEditingController();

  final TextEditingController pwNameController = TextEditingController();
  final TextEditingController pwEmailController = TextEditingController();
  final TextEditingController pwIdController = TextEditingController();

  bool _isFindingId = false;
  bool _isFindingPassword = false;

  // ✨ 아이디 찾기 API 호출 함수
  Future<void> _findId() async {
    if (idNameController.text.trim().isEmpty ||
        idEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 이메일을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isFindingId = true);

    final uri = Uri.parse('$baseUrl/auth/findId');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': idNameController.text.trim(),
      'email': idEmailController.text.trim(),
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        final foundId = data['result'];
        Navigator.pushNamed(
          context,
          '/account/find/idfound',
          arguments: {
            'name': idNameController.text.trim(), // 이름 컨트롤러의 텍스트
            'id': foundId,                       // API로 찾은 아이디
          },
        );
      } else {
        Navigator.pushNamed(context, '/account/find/notfound');
      }
    } catch (e) {
      print('Failed to find ID: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')));
    } finally {
      if (mounted) setState(() => _isFindingId = false);
    }
  }

  // ✨ 비밀번호 찾기 API 호출 함수
  Future<void> _findPassword() async {
    if (pwNameController.text.trim().isEmpty ||
        pwEmailController.text.trim().isEmpty ||
        pwIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 정보를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isFindingPassword = true);

    final uri = Uri.parse('$baseUrl/auth/findPassword');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': pwNameController.text.trim(),
      'email': pwEmailController.text.trim(),
      'userId': pwIdController.text.trim(),
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        Navigator.pushNamed(context, '/account/find/temppw');
      } else {
        Navigator.pushNamed(context, '/account/find/notfound');
      }
    } catch (e) {
      print('Failed to find password: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')));
    } finally {
      if (mounted) setState(() => _isFindingPassword = false);
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
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 30,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: 20 + bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/icons/goback.png',
                        width: 16,
                        height: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '아이디/비밀번호 찾기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 아이디 찾기
                        const Text(
                          '아이디 찾기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: '이름',
                          hint: '이름을 입력하세요.',
                          controller: idNameController,
                        ),
                        _LabeledField(
                          label: '이메일',
                          hint: '이메일을 입력하세요.',
                          controller: idEmailController,
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          label: '아이디 찾기',
                          isLoading: _isFindingId, // ✨ 로딩 상태 전달
                          onPressed: _findId,      // ✨ API 호출 함수 연결
                        ),
                        const SizedBox(height: 30),
                        const Divider(),
                        const SizedBox(height: 30),
                        // 비밀번호 찾기
                        const Text(
                          '비밀번호 찾기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: '이름',
                          hint: '이름을 입력하세요.',
                          controller: pwNameController,
                        ),
                        _LabeledField(
                          label: '이메일',
                          hint: '이메일을 입력하세요.',
                          controller: pwEmailController,
                        ),
                        _LabeledField(
                          label: '아이디',
                          hint: '영문과 숫자만 입력해 주세요.',
                          controller: pwIdController,
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          label: '비밀번호 찾기',
                          isLoading: _isFindingPassword, // ✨ 로딩 상태 전달
                          onPressed: _findPassword,      // ✨ API 호출 함수 연결
                        ),
                      ],
                    ),
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

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
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
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading; // 로딩 상태를 받을 변수

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false, // 기본값은 false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // 로딩 중일 때 버튼 비활성화
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6FCF4B),
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox( // 로딩 중일 때 인디케이터 표시
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text( // 로딩 아닐 때 텍스트 표시
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}