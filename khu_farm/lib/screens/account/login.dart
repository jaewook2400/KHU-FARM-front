import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  String? _errorMessage;

  Future<void> _handleLogin() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      setState(() {
        _errorMessage = '아이디와 비밀번호를 모두 입력하세요.';
      });
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:8080/auth/login'); // ← 실제 API 주소로 교체하세요.
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': id,
        'password': pw,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    print('$data');
    if (data['isSuccess'] == true) {
      final accessToken = data['result']['accessToken'];
      final refreshToken = "";
      final userType = data['result']['userType'];

      await StorageService.saveTokens(accessToken, refreshToken);
      setState(() => _errorMessage = null);

      String route = '';
      switch (userType) {
        case 'ROLE_INDIVIDUAL':
          route = '/consumer/main';
          break;
        case 'ROLE_BUSINESS':
          route = '/retailer/main';
          break;
        case 'ROLE_FARMER':
          route = '/farmer/main';
          break;
        case 'ADMIN':
          route = '/admin/daily';
          break;
        default:
          setState(() => _errorMessage = '회원 유형이 올바르지 않습니다.');
          return;
      }

      Navigator.pushReplacementNamed(context, route);
    } else {
      if (data['code'] == 'USER404') {
        setState(() => _errorMessage = '아이디 또는 비밀번호가 일치하지 않습니다.');
      } else if (data['code'] == 'USER401') {
        setState(() => _errorMessage = '아이디 또는 비밀번호가 일치하지 않습니다.');
      } else {
        setState(() => _errorMessage = '아이디 또는 비밀번호가 일치하지 않습니다.');
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

          // 콘텐츠
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight + 20,
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    Image.asset(
                      'assets/mascot/login_mascot.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '아이디',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        hintText: '아이디를 입력하세요.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '비밀번호',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pwController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력하세요.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FCF4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '로그인',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup/usertype');
                      },
                      child: const Text(
                        '회원가입 하기',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/account/find');
                      },
                      child: const Text(
                        '아이디 / 비밀번호 찾기',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
