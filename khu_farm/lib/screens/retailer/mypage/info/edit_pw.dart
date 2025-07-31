import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';

class RetailerEditPwScreen extends StatefulWidget {
  const RetailerEditPwScreen({super.key});

  @override
  State<RetailerEditPwScreen> createState() => _RetailerEditPwScreenState();
}

class _RetailerEditPwScreenState extends State<RetailerEditPwScreen> {
  late TextEditingController _currentCtrl;
  late TextEditingController _newCtrl;
  late TextEditingController _confirmCtrl;

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentCtrl = TextEditingController();
    _newCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
    _currentCtrl.addListener(_updateButtonState);
    _newCtrl.addListener(_updateButtonState);
    _confirmCtrl.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _currentCtrl.removeListener(_updateButtonState);
    _newCtrl.removeListener(_updateButtonState);
    _confirmCtrl.removeListener(_updateButtonState);
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ✨ 3. 모든 필드가 비어있지 않으면 버튼을 활성화하는 함수
  void _updateButtonState() {
    if (mounted) {
      setState(() {
        _isButtonEnabled = _currentCtrl.text.isNotEmpty &&
                            _newCtrl.text.isNotEmpty &&
                            _confirmCtrl.text.isNotEmpty;
      });
    }
  }

  Future<void> _changePassword() async {
    // 로딩 모달창 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("비밀번호 변경 중..."),
            ],
          ),
        ),
      ),
    );

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing');

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final uri = Uri.parse('$baseUrl/auth/changePassword');
      final body = jsonEncode({
        'currentPassword': _currentCtrl.text,
        'newPassword': _newCtrl.text,
        'confirmNewPassword': _confirmCtrl.text,
      });

      final response = await http.post(uri, headers: headers, body: body);
      
      if(mounted) Navigator.of(context).pop(); // 로딩 모달창 닫기

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          // 성공 시 success 화면으로 이동
          Navigator.pushNamed(context, '/retailer/mypage/info/edit/pw/success');
        } else {
          // isSuccess가 false일 때 (비밀번호 불일치 등)
          _showErrorDialog('현재 비밀번호가 다르거나 새 비밀번호가 서로 다릅니다.');
        }
      } else {
        // HTTP 에러
        _showErrorDialog('현재 비밀번호가 다르거나 새 비밀번호가 서로 다릅니다.');
      }
    } catch (e) {
      if(mounted) Navigator.of(context).pop(); // 네트워크 에러 시에도 로딩 모달창 닫기
      print('Error changing password: $e');
      _showErrorDialog('네트워크 오류가 발생했습니다.');
    }
  }

  // ✨ 5. 에러 메시지를 보여주는 모달 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 시스템 바 투명
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
          // ── 노치 배경 ─────────────────────────────
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

          // ── 콘텐츠 ───────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom:  MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← 뒤로가기 + 제목
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
                      '비밀번호 수정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 스크롤 가능한 폼
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 현재 비밀번호
                        const Text(
                          '현재 비밀번호',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _currentCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '현재 비밀번호를 입력하세요.',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '영문, 숫자, 특수문자 조합',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 새 비밀번호
                        const Text(
                          '새 비밀번호',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '비밀번호를 입력하세요.',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '영문, 숫자, 특수문자 조합',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 새 비밀번호 확인
                        const Text(
                          '새 비밀번호 확인',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '비밀번호를 한 번 더 입력하세요.',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '영문, 숫자, 특수문자 조합',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 변경 완료 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    // ✨ 6. onPressed에 _changePassword 연결 및 활성화 상태 적용
                    onPressed: _isButtonEnabled ? _changePassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FCF4B),
                      // 비활성화 시 색상 지정
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '변경 완료',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
