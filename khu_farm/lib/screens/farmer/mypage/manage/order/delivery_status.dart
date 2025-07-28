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

class FarmerManageOrderDeliveryStatusScreen extends StatefulWidget {
  const FarmerManageOrderDeliveryStatusScreen({super.key});

  @override
  State<FarmerManageOrderDeliveryStatusScreen> createState() => _FarmerManageOrderDeliveryStatusScreenState();
}

class _FarmerManageOrderDeliveryStatusScreenState extends State<FarmerManageOrderDeliveryStatusScreen> {
  DeliveryTrackingData? _trackingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to safely access arguments in initState
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
      // API call to get tracking info
      final getUri = Uri.parse('$baseUrl/delivery/$orderDetailId/tracking');
      final getResponse = await http.get(getUri, headers: headers);

      if (getResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(getResponse.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          if (mounted) {
            setState(() {
              _trackingData =
                  DeliveryTrackingData.fromJson(data['result']['deliveryStatus']);
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
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       '/farmer/notification/list',
                    //     );
                    //   },
                    //   child: Image.asset(
                    //     'assets/top_icons/notice.png',
                    //     width: 24,
                    //     height: 24,
                    //   ),
                    // ),
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
                      '배송 현황 확인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16,),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(order),
                        const SizedBox(height: 32),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _trackingData != null
                                ? _buildDeliveryStatus(_trackingData!, order)
                                : const Center(
                                    child: Text('배송 정보를 조회할 수 없습니다.')),
                      ],
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

  Widget _buildInfoCard(SellerOrder order) {
    String formattedDate = '';
    try {
      if (order.createdAt.isNotEmpty) {
        formattedDate =
            DateFormat('yyyy.MM.dd').format(DateTime.parse(order.createdAt));
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

  // Helper widget for a single row in the info card
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          const Text('|', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // Helper widget for the delivery status stepper
  Widget _buildDeliveryStatus(DeliveryTrackingData trackingData, SellerOrder sellerOrder) {
    const stepStatuses = ['결제 완료', '배송 준비중', '배송중', '배달 완료'];
    final currentStatusInfo =
        statusMap[trackingData.currentStateText] ?? statusMap['알 수 없음']!;
    int currentStep = stepStatuses.indexOf(currentStatusInfo.stepName);

    final invoiceFullText = '운송장 번호 : ${sellerOrder.deliveryCompany} ${sellerOrder.deliveryNumber} (눌러서 복사)';

    return Column(
      children: [
        _buildStep(title: '결제 완료', isActive: currentStep == 0),
        _buildStepConnector(),

        _buildStep(title: '배송 준비중', isActive: currentStep == 1),
        _buildStepConnector(),

        _buildStep(title: '배송중', isActive: currentStep == 2),
        
        // '배송중' 단계 이거나 그 이후 단계일 때 운송장 번호 표시
        if (currentStep >= 2)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: sellerOrder.deliveryNumber!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('운송장 번호가 복사되었습니다.')),
                );
              },
              child: Text(
                invoiceFullText,
                textAlign: TextAlign.center,
                // 변경된 부분: '배송중' 단계가 활성화(currentStep == 2)일 때만 초록색, 아니면 회색
                style: TextStyle(
                  fontSize: 12,
                  color: currentStep == 2 ? const Color(0xFF6FCF4B) : Colors.grey,
                ),
              ),
            ),
          ),
        _buildStepConnector(),

        _buildStep(title: '배달 완료', isActive: currentStep == 3),
      ],
    );
  }

  Widget _buildStep({required String title, bool isActive = false}) {
    final Color borderColor;
    final Color fontColor;
    final Color backgroundColor;

    if (isActive) {
      borderColor = const Color(0xFF6FCF4B);
      fontColor = const Color(0xFF6FCF4B);
      backgroundColor = Colors.white;
    } else {
      borderColor = Colors.grey;
      fontColor = Colors.grey;
      backgroundColor = Colors.white;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: fontColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 32, // 간격 조정
      alignment: Alignment.center,
      child: const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
    );
  }
}
