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
import 'package:khu_farm/screens/farmer/mypage/order/order_detail.dart';
import 'package:http/http.dart' as http;

class FarmerManageOrderDetailScreen extends StatefulWidget {
  const FarmerManageOrderDetailScreen({super.key});

  @override
  State<FarmerManageOrderDetailScreen> createState() => _FarmerManageOrderDetailScreenState();
}

class _FarmerManageOrderDetailScreenState extends State<FarmerManageOrderDetailScreen> {
  DeliveryTrackingData? _trackingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final order = ModalRoute.of(context)!.settings.arguments as SellerOrder;
      _fetchTrackingInfo(order.orderId);
    });
  }

  Future<void> _fetchTrackingInfo(int orderId) async {
    setState(() => _isLoading = true);
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      setState(() => _isLoading = false);
      return;
    }
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      // 1단계: PATCH API 호출 (필요한 경우)
      final patchUri = Uri.parse('$baseUrl/delivery/$orderId');
      await http.patch(patchUri, headers: headers);

      // 2단계: GET API 호출
      final getUri = Uri.parse('$baseUrl/delivery/$orderId/tracking');
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

    String formattedDate = '';
    try {
      if (order.createdAt.isNotEmpty) {
        formattedDate =
            DateFormat('yyyy.MM.dd').format(DateTime.parse(order.createdAt));
      }
    } catch (e) {
      formattedDate = order.createdAt.split('T').first;
    }
    
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
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
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
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(order),
                        const SizedBox(height: 32),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _trackingData != null
                                ? _buildDeliveryStatus(_trackingData!)
                                : const Center(
                                    child: Text('배송 정보를 조회할 수 없습니다.')),
                        const SizedBox(height: 120),
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

  Widget _buildDeliveryStatus(DeliveryTrackingData trackingData) {
    // 각 배송 단계에 대한 상태 문자열 리스트
    const stepStatuses = ['결제 완료', '배송 준비중', '배송중', '배달 완료'];
    
    // 현재 상태 텍스트를 statusMap에서 찾아보고, 없으면 '알 수 없음'으로 처리
    final currentStatusInfo = statusMap[trackingData.currentStateText] ?? statusMap['알 수 없음']!;
    
    // 현재 상태가 몇 번째 단계인지 확인 (없으면 -1)
    int currentStep = stepStatuses.indexOf(currentStatusInfo.displayName);

    return Column(
      children: [
        _buildStep(title: '결제 완료', isDone: true), // 결제는 항상 완료된 상태로 가정
        _buildStepConnector(),
        _buildStep(title: '배송 준비중', isDone: currentStep >= 3, isActive: currentStep == 3),
        _buildStepConnector(),
        _buildStep(
          title: '배송중',
          isDone: currentStep >= 4,
          isActive: currentStep == 4,
          subText: '운송장 번호 : ${trackingData.carrierName} ${trackingData.progresses.isNotEmpty ? trackingData.progresses.first.description : ''} (눌러서 복사)',
        ),
        _buildStepConnector(),
        _buildStep(title: '배송 완료', isDone: currentStep >= 5, isActive: currentStep == 5),
      ],
    );
  }

  /// Helper widget for a single step in the stepper
  Widget _buildStep(
      {required String title, String? subText, bool isDone = false, bool isActive = false}) {
    final Color activeColor = isDone ? const Color(0xFF6FCF4B) : Colors.grey.shade300;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: activeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDone ? Colors.black : Colors.grey)),
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(subText,
                style: const TextStyle(fontSize: 12, color: Colors.green)),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoCard(SellerOrder order) {
    final DeliveryStatus status = statusMap[order.status] ?? statusMap['알 수 없음']!;
    // --- 여기까지 ---

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
          _buildInfoRow('이름', order.recipient,
              trailing: _statusChip(status.displayName, status.color)),
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

  Widget _buildStepConnector() {
    return Container(
      height: 24,
      alignment: Alignment.center,
      child: const Icon(Icons.arrow_downward,
          color: Colors.grey, size: 16),
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
