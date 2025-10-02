///송장번호 수정 페이지
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/model/seller_order.dart';
import 'package:khu_farm/model/delivery_tracking.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/screens/farmer/mypage/order/order_detail.dart';
import 'package:http/http.dart' as http;

class DeliveryNumberEditScreen extends StatefulWidget {
  const DeliveryNumberEditScreen({super.key});

  @override
  State<DeliveryNumberEditScreen> createState() => _DeliveryNumberEditScreenState();
}

class _DeliveryNumberEditScreenState extends State<DeliveryNumberEditScreen> {
  final _trackingNumberController = TextEditingController();
  String? _selectedCourierName;
  SellerOrder? _order;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null) {
      final order = ModalRoute.of(context)!.settings.arguments as SellerOrder;
      setState(() {
        _order = order;
        if (order.deliveryNumber != null && order.deliveryNumber != '미등록') {
          _trackingNumberController.text = order.deliveryNumber!;
        }
        // deliveryCompany 필드에 저장된 택배사 이름을 초기값으로 설정
        _selectedCourierName = order.deliveryCompany;
      });
    }
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    super.dispose();
  }
  
  // --- New function to save tracking info ---
  Future<void> _saveTrackingInfo() async {
    if (_order == null ||
        _selectedCourierName == null ||
        _trackingNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('송장번호와 택배사를 모두 입력해주세요.')),
      );
      return;
    }

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('$baseUrl/delivery/${_order!.orderDetailId}');
    final body = jsonEncode({
      "deliveryCompany": _selectedCourierName,
      "deliveryNumber": _trackingNumberController.text,
    });

    try {
      final response = await http.patch(uri, headers: headers, body: body);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const _SuccessDialog(),
          );
        }
      } else {
        throw Exception('Failed to save tracking info: ${data['message']}');
      }
    } catch (e) {
      print('Error saving tracking info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.')),
        );
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
                      '/farmer/main',
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
                          '/farmer/notification/list',
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
                        Navigator.pushNamed(context, '/farmer/dib/list');
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
                        Navigator.pushNamed(context, '/farmer/cart/list');
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
              bottom: bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← 내 정보 타이틀
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
                      '송장번호 입력하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_order != null) _buildInfoCard(_order!),
                        const SizedBox(height: 24),
                        _buildLabeledTextField(
                          label: '송장번호',
                          hint: '송장번호를 입력해 주세요.',
                          controller: _trackingNumberController,
                        ),
                        const SizedBox(height: 16),
                        _buildCourierDropdown(),
                      ],
                    ),
                  ),
                ),
                // Save Button
                
              ],
            ),
          ),
          
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: _saveTrackingInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCF4B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('저장하기', style: TextStyle(fontSize: 18 ,color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(SellerOrder order) {
    String formattedDate = '';
    try {
      if (order.createdAt.isNotEmpty) {
        formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(order.createdAt));
      }
    } catch (e) {
      formattedDate = order.createdAt.split('T').first;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildInfoRow('이름', order.recipient),
          _buildInfoRow('전화번호', order.phoneNumber),
          _buildInfoRow('주문일자', formattedDate),
          _buildInfoRow('주문번호', order.merchantUid),
          _buildInfoRow('상품', '${order.fruitTitle} (${order.orderCount}개)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ),
          const Text('|', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCourierDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('택배사', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourierName, // value는 이제 이름(name)
              isExpanded: true,
              hint: const Text('이용하시는 택배사를 선택해 주세요.'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCourierName = newValue;
                });
              },
              // items 리스트 생성 시 value에 name을 할당
              items: deliveryCompany.map<DropdownMenuItem<String>>((company) {
                return DropdownMenuItem<String>(
                  value: company['name'], // value를 이름으로 변경
                  child: Text(company['name']!),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('성공'),
      content: const Text('송장 정보가 성공적으로 저장되었습니다.'),
      actions: [
        TextButton(
          onPressed: () {
            // '/farmer/mypage/manage/order' 라우트를 만날 때까지 현재 화면들을 모두 pop 합니다.
            Navigator.of(context).popUntil(ModalRoute.withName('/farmer/mypage/manage/order'));
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}