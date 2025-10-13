import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';

class FarmerAccountCancellationScreen extends StatefulWidget {
  const FarmerAccountCancellationScreen({super.key});

  @override
  State<FarmerAccountCancellationScreen> createState() =>
      _FarmerAccountCancellationScreenState();
}

class _FarmerAccountCancellationScreenState
    extends State<FarmerAccountCancellationScreen> {
  final TextEditingController _pwController = TextEditingController();
  bool _showError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _onDeletePressed() async {
    // 비밀번호 입력 여부 확인
    if (_pwController.text.trim().isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 시작
      _showError = false;
    });

    // 1. 저장된 Access Token 가져오기
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      _showFailureDialog('인증 정보가 만료되었습니다. 다시 로그인해주세요.');
      setState(() => _isLoading = false);
      return;
    }

    // 2. API 요청 준비
    final uri = Uri.parse('$baseUrl/auth/deleteUser');
    final headers = {
      'Authorization': 'Bearer $accessToken',
    };

    try {
      // 3. DELETE 요청 보내기
      final response = await http.delete(uri, headers: headers);

      // 4. 결과 처리
      if (response.statusCode == 200 || response.statusCode == 204) {
        // 성공 시
        await StorageService().clearAllData(); // 로컬 데이터 모두 삭제
        if (mounted) {
          // 성공 페이지로 이동 (이전 화면으로 돌아갈 수 없도록 함)
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/farmer/mypage/info/cancel/success',
            (route) => false,
          );
        }
      } else {
        // 실패 시
        print('Account deletion failed: ${response.statusCode}');
        print('Response: ${response.body}');
        _showFailureDialog('회원 탈퇴에 실패했습니다. 잠시 후 다시 시도해주세요.');
      }
    } catch (e) {
      // 네트워크 에러 등 예외 발생 시
      print('An error occurred during account deletion: $e');
      _showFailureDialog('네트워크 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 종료
        });
      }
    }
  }

  // 실패 시 보여줄 다이얼로그
  void _showFailureDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
          FarmerTopNotchHeader(),

          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: 0,
            right: 0,
            // 하단 버튼이 가리지 않도록 bottom 여백 조정
            bottom: MediaQuery.of(context).padding.bottom + 20 + 48 + 16,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              // 1. Center 위젯을 제거합니다.
              // 2. Column의 정렬 속성을 변경합니다.
              child: Column(
                // mainAxisSize를 제거하여 Column이 사용 가능한 모든 세로 공간을 차지하도록 합니다.
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 세로 정렬을 spaceBetween으로 변경
                crossAxisAlignment: CrossAxisAlignment.center, // 가로 정렬은 시작점으로 변경
                children: [
                  // 최상단 제목 부분
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
                        '계정 탈퇴', // 제목 수정
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  // 중앙 콘텐츠 (새로운 Column으로 감싸서 중앙 정렬)
                  Column(
                    mainAxisSize: MainAxisSize.min, // 콘텐츠 크기만큼만 차지
                    crossAxisAlignment: CrossAxisAlignment.center, // 내부 요소들 수평 중앙 정렬
                    children: [
                      Image.asset(
                        'assets/mascot/login_mascot.png',
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.2,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '정말 삭제하시겠습니까?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '비밀번호를 한 번 더 입력해 주세요.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30), // 입력창과의 간격
                      TextField(
                        controller: _pwController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력해 주세요.',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      if (_showError)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            '비밀번호가 일치하지 않습니다.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(),
                ],
              ),
            ),
          ),
          // --- 여기까지 ---

          // 하단 버튼: 고정 위치
          Positioned(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _onDeletePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE84C4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '계정 삭제하기',
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
