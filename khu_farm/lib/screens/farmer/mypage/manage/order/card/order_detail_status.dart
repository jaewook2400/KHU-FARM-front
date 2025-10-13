import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/model/seller_order.dart';
import 'package:khu_farm/model/delivery_tracking.dart';
import 'package:khu_farm/model/order_status.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:http/http.dart' as http;

class OrderDetailStatusScreen extends StatefulWidget {
  const OrderDetailStatusScreen({super.key});

  @override
  State<OrderDetailStatusScreen> createState() => _OrderDetailStatusScreenState();
}

class _OrderDetailStatusScreenState extends State<OrderDetailStatusScreen> {
  DeliveryTrackingData? _trackingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final order = ModalRoute.of(context)!.settings.arguments as SellerOrder;
      _fetchTrackingInfo(order.orderDetailId);
    });
  }

  Future<void> _fetchTrackingInfo(int orderDetailId) async {
    setState(() => _isLoading = true);
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      setState(() => _isLoading = false);
      return;
    }
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      // 2단계: GET API 호출
      final getUri = Uri.parse('$baseUrl/delivery/$orderDetailId/tracking');
      final getResponse = await http.get(getUri, headers: headers);

      if (getResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(getResponse.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          if (mounted) {
            setState(() {
              _trackingData = DeliveryTrackingData.fromJson(data['result']['deliveryStatus']);
            });
          }
        }
      } else {
        throw Exception('Failed to fetch tracking info');
      }
    } catch (e) {
      print('Error in fetching tracking info: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    final SellerOrder order = ModalRoute.of(context)!.settings.arguments as SellerOrder;
    final bool isTrackingNumberRegistered = order.deliveryNumber != null && order.deliveryNumber != '미등록';

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
                      '주문 상세 내역',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderDetails(order),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 30,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        '/farmer/mypage/manage/order/delnum',
                        arguments: order,
                      );
                      _fetchTrackingInfo(order.orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FCF4B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(
                      isTrackingNumberRegistered ? '송장번호 수정' : '송장번호 입력',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/farmer/mypage/manage/order/delstat',
                        arguments: order,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FCF4B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('배송현황 확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(SellerOrder order) {
    final DeliveryStatus status =
        statusMap[order.deliveryStatus] ?? statusMap['알 수 없음']!;
    String formattedDate = '';
    try {
      if (order.createdAt.isNotEmpty) {
        formattedDate =
            DateFormat('yyyy.MM.dd').format(DateTime.parse(order.createdAt));
      }
    } catch (e) {
      formattedDate = order.createdAt.split('T').first;
    }

    // 카드 UI가 없는 Column으로 변경
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('이름', order.recipient,
            trailing: _statusChip(status.displayName, status.color)),
        _buildInfoRow('전화번호', order.phoneNumber),
        _buildInfoRow('주문일자', formattedDate),
        _buildInfoRow('주문번호', order.merchantUid),
        _buildInfoRow('상품', '${order.fruitTitle} (${order.orderCount}개)'),
        _buildInfoRow('송장번호', order.deliveryNumber ?? '미등록'),
        _buildInfoRow('택배사', order.deliveryCompany ?? '미등록'),
        _buildInfoRow('주문자 요청사항', order.orderRequest ?? '없음'),
        const SizedBox(height: 24),
        // 메모 필드 추가
        
        const SizedBox(height: 100), // 하단 버튼과의 여백
      ],
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
