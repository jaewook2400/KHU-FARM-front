import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/screens/consumer/mypage/order/order.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key, required this.order});
  final Order order;

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final TextEditingController _reasonController = TextEditingController();
  String? _horizontalImagePath;
  String? _squareImagePath;
  bool _isLoading = false;

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

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("환불 사유를 입력해주세요.")),
      );
      return;
    }

    final accessToken = await StorageService.getAccessToken();

    if (accessToken == null) {
      _showErrorDialog('로그인이 필요합니다.');
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$baseUrl/order/refund/${widget.order.orderDetailId}');
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
        Navigator.pop(context);
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
    print("환불 요청: $reason");
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

  Future<void> _pickImage(ValueChanged<String> onImageSelected) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) onImageSelected(picked.path);
  }

  Widget _buildImageUpload({required String label, required String? imagePath, required ValueChanged<String> onImageSelected,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(onImageSelected),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                '사진 업로드하기',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: imagePath != null
                  ? Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
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
                      '/consumer/main',
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
                          '/consumer/notification/list',
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
                        Navigator.pushNamed(context, '/consumer/dib/list');
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
                        Navigator.pushNamed(context, '/consumer/cart/list');
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
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/icons/goback.png', width: 18, height: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('주문/배송', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 24),
                _RefundCard(order: widget.order),

                const SizedBox(height: 24),

                const Text(
                  "환불 사유",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),

                // ✅ 환불 사유 입력 칸
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), // 연한 그림자
                        blurRadius: 6,
                        offset: const Offset(0, 3), // 그림자 위치
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.shade200, // 연한 테두리
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "내용을 입력해 주세요.",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      border: InputBorder.none, // 기본 border 제거
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                _buildImageUpload(label: '미리보기 이미지 (가로형)',
                  imagePath: _horizontalImagePath,
                  onImageSelected: (path) => setState(() => _horizontalImagePath = path),),
              ],
            ),
          ),
        ]
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16, // 키보드 높이만큼 패딩
          ),
          child: SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _submitRefund,
              child: const Text(
                "접수하기",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RefundCard extends StatelessWidget {
  final Order order;
  const _RefundCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Text(order.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(order.brandName,
                        style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text('${order.orderCount}박스',
                        style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                        '${formatter.format(order.price)}원 / ${order.weight}kg',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  order.squareImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 80, height: 80, color: Colors.grey[200]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
