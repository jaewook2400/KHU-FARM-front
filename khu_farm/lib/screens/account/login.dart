import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/model/address.dart';
import 'package:khu_farm/services/storage_service.dart';

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
      setState(() => _errorMessage = '아이디와 비밀번호를 모두 입력하세요.');
      return;
    }

    // 1. 로그인 API 호출
    final loginUri = Uri.parse('$baseUrl/auth/login');
    final loginResponse = await http.post(
      loginUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': id, 'password': pw}),
    );

    final loginData = jsonDecode(utf8.decode(loginResponse.bodyBytes));

    if (loginData['isSuccess'] == true) {
      final loginResult = loginData['result'];
      final accessToken = loginResult['accessToken'];
      final userType = loginResult['userType'];
      String? refreshToken;
      final String? rawCookie = loginResponse.headers['set-cookie'];
      if (rawCookie != null) {
        final regExp = RegExp(r'refresh_token=([^;]+)');
        final match = regExp.firstMatch(rawCookie);
        if (match != null) {
          refreshToken = match.group(1);
        }
      }

      if (refreshToken == null) {
        setState(() => _errorMessage = '로그인에 실패했습니다. (토큰 오류)');
        return;
      }

      // 2. 토큰 저장
      await StorageService.saveTokens(accessToken, refreshToken);

      // 3. 유저 가치(Value) 정보 API 호출
      final userInfoUri = Uri.parse('$baseUrl/users/value');
      final userInfoResponse = await http.get(
        userInfoUri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (userInfoResponse.statusCode != 200) {
        setState(() => _errorMessage = '사용자 정보 로딩에 실패했습니다.');
        return;
      }

      final userInfoData = jsonDecode(utf8.decode(userInfoResponse.bodyBytes));
      if (userInfoData['isSuccess'] != true) {
        setState(() => _errorMessage = '사용자 정보 로딩에 실패했습니다.');
        return;
      }
      
      final valueResult = userInfoData['result'];

      // 4. 두 API 응답을 합쳐서 하나의 UserInfo 객체 생성
      final UserInfo userInfo = UserInfo(
        userId: valueResult['userId'],
        userName: valueResult['userName'],
        totalPoint: valueResult['totalPoint'],
        totalDonation: valueResult['totalDonation'],
        totalPurchasePrice: valueResult['totalPurchasePrice'],
        totalPurchaseWeight: valueResult['totalPurchaseWeight'],
        totalDiscountPrice: valueResult['totalDiscountPrice'],
        email: loginResult['email'], // From login API
        phoneNumber: loginResult['phoneNumber'], // From login API
        userType: userType, // From login API
      );

      // 5. 통합된 사용자 정보를 Storage Service에 저장
      await StorageService().saveUserInfo(userInfo);

      setState(() => _errorMessage = null);

      final addressUri = Uri.parse('$baseUrl/address');
      final addressResponse = await http.get(
        addressUri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (addressResponse.statusCode == 200) {
        final addressData = json.decode(utf8.decode(addressResponse.bodyBytes));
        if (addressData['isSuccess'] == true && addressData['result'] != null) {
          final List<dynamic> addressJson = addressData['result']['content'];
          final addresses = addressJson.map((json) => Address.fromJson(json)).toList();
          await StorageService().saveAddresses(addresses);
          print('User addresses saved successfully.');
        }
      }

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
      if(mounted) Navigator.pushReplacementNamed(context, route);

    } else {
      setState(() => _errorMessage = '아이디 또는 비밀번호가 일치하지 않습니다.');
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
                  onTap: () {},
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white
                          ),
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
