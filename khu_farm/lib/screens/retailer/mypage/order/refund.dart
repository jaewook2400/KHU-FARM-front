// lib/screens/retailer/mypage/order_detail_screen.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RetailerRefundScreen extends StatefulWidget {
  const RetailerRefundScreen({super.key});

  @override
  State<RetailerRefundScreen> createState() => _RetailerRefundScreenState();
}

class _RetailerRefundScreenState extends State<RetailerRefundScreen> {
  final TextEditingController _reasonController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(() {
      final isEnabled = _reasonController.text.isNotEmpty;
      if (isEnabled != _isButtonEnabled) {
        setState(() {
          _isButtonEnabled = isEnabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRefund() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final order = ModalRoute.of(context)!.settings.arguments as Order;
    final accessToken = await StorageService.getAccessToken();

    if (accessToken == null) {
      _showErrorDialog('로그인이 필요합니다.');
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$baseUrl/order/refund/${order.orderDetailId}');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'refundReason': _reasonController.text,
    });

    try {
      final response = await http.patch(uri, headers: headers, body: body);
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      print(responseBody);

      if (response.statusCode == 200 && responseBody['isSuccess'] == true) {
        // 성공 시, 주문/배송 목록 화면으로 이동
        if (mounted) {
          // 1. 성공 화면으로 이동하고, 해당 화면이 닫힐 때까지 기다립니다.
          await Navigator.pushNamed(context, '/retailer/mypage/order/refund/success');
          
          // 2. 성공 화면에서 돌아오면(pop), 현재 환불 접수 화면도 닫습니다(pop).
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        // API가 실패 응답을 보냈을 경우
        final message = responseBody['message'] ?? '알 수 없는 오류가 발생했습니다.';
        _showErrorDialog(message);
      }
    } catch (e) {
      // 네트워크 오류 등 예외 발생 시
      _showErrorDialog('네트워크 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 실패 알림창을 띄우는 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('환불 접수 실패'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
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
    final formatter = NumberFormat('#,###');
    final order = ModalRoute.of(context)!.settings.arguments as Order;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background and Header UI
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

          // Content
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              children: [
                // Back button and Title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/icons/goback.png', width: 18, height: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('환불 접수하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 상품 정보 카드
                        Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(order.brandName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 12),
                            Text('${order.orderCount}박스', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text('${formatter.format(order.price)}원 / ${order.weight}kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(order.squareImageUrl, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
                        const SizedBox(height: 32),

                        // 2. 환불 사유 입력 필드
                        const Text(
                          '환불 사유',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reasonController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: '내용을 입력해 주세요.',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6FCF4B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled && !_isLoading
                          ? _submitRefund // 활성화 & 로딩중 아닐 때 API 호출
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled
                            ? const Color(0xFF6FCF4B)
                            : Colors.grey.shade400,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              '접수하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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