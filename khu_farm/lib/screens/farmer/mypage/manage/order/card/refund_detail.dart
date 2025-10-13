import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/model/seller_order.dart';
import 'package:khu_farm/model/delivery_tracking.dart';
import 'package:khu_farm/model/order_status.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:http/http.dart' as http;

class FarmerManageOrderRefundScreen extends StatefulWidget {
  const FarmerManageOrderRefundScreen({super.key});

  @override
  State<FarmerManageOrderRefundScreen> createState() => _FarmerManageOrderRefundScreenState();
}

class _FarmerManageOrderRefundScreenState extends State<FarmerManageOrderRefundScreen> {

  bool _isProcessing = false;

  // ✨ 2. 환불 승인 API 호출 함수
  Future<void> _approveRefund(SellerOrder order) async {
    setState(() => _isProcessing = true);
    print(order);

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Access token not found');

      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/payment/refund/{orderDetailId}?orderDetailId=${order.orderDetailId}');
      print(uri);
      
      final response = await http.post(uri, headers: headers);
      print(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          // 성공 시 accept 화면으로 이동
          if (!mounted) return;
          final result = await Navigator.pushNamed(
            context,
            '/farmer/mypage/manage/order/refund/accept',
          );
          // accept 화면에서 true를 반환받으면, 이 화면도 true를 반환하며 닫기
          if (result == true && mounted) {
            Navigator.pop(context, true);
          }
        } else {
          throw Exception('Failed to approve refund: ${data['message']}');
        }
      } else {
        throw Exception('Failed to approve refund: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('환불 승인 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ✨ 3. 환불 거절 API 호출 함수
  Future<void> _denyRefund(SellerOrder order) async {
    setState(() => _isProcessing = true);
    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Access token not found');

      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/payment/refund/{orderDetailId}/deny?orderDetailId=${order.orderDetailId}');
      
      final response = await http.post(uri, headers: headers);
      
      if (response.statusCode == 200) {
         final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          // 성공 시 reject 화면으로 이동
           if (!mounted) return;
          final result = await Navigator.pushNamed(
            context,
            '/farmer/mypage/manage/order/refund/reject',
          );
          // reject 화면에서 true를 반환받으면, 이 화면도 true를 반환하며 닫기
           if (result == false && mounted) {
            Navigator.pop(context, true);
          }
        } else {
          throw Exception('Failed to deny refund: ${data['message']}');
        }
      } else {
        throw Exception('Failed to deny refund: ${response.statusCode}');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('환불 거절 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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

    final SellerOrder order =
        ModalRoute.of(context)!.settings.arguments as SellerOrder;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          FarmerTopNotchHeader(),

          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: bottomPadding + 20,
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
                        width: 18,
                        height: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '환불',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(order), // 주문 정보 카드
                        const SizedBox(height: 24),
                        _buildRefundReasonSection(order), // 환불 사유 섹션
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(order),// 하단 버튼 영역
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
          _buildInfoRow('송장번호', order.deliveryNumber ?? '미등록'),
          _buildInfoRow('택배사', order.deliveryCompany ?? '미등록'),
          _buildInfoRow('주문자 요청사항', order.orderRequest ?? '없음'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ),
          const Text('|', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildRefundReasonSection(SellerOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('환불 사유', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(order.refundReason ?? '사유가 등록되지 않았습니다.', style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(SellerOrder order) { // ✨ 5. order 객체 받기
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            // ✨ 6. API 호출 함수 연결 및 로딩 중 비활성화
            onPressed: _isProcessing ? null : () => _approveRefund(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('환불 승인', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            // ✨ 7. API 호출 함수 연결 및 로딩 중 비활성화
            onPressed: _isProcessing ? null : () => _denyRefund(order),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('환불 거절', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
