// lib/screens/retailer/mypage/order_detail_screen.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/model/delivery_tracking.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  DeliveryTrackingData? _trackingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrackingInfo();
  }

  Future<void> _fetchTrackingInfo() async {
    setState(() => _isLoading = true);
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      setState(() => _isLoading = false);
      return;
    }
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final getUri = Uri.parse('$baseUrl/delivery/${widget.order.orderDetailId}/tracking');
      final getResponse = await http.get(getUri, headers: headers);

      if (getResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(getResponse.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          if(mounted) {
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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final formatter = NumberFormat('#,###');
    
    String formattedDate = '';
    try {
      // --- This is the corrected part ---
      if (widget.order.createdAt.isNotEmpty) {
        formattedDate =
            DateFormat('yyyy.MM.dd').format(DateTime.parse(widget.order.createdAt));
      }
    } catch (e) {
      formattedDate = widget.order.createdAt;
    }

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
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       '/consumer/notification/list',
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

          // Content
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
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
                    const Text('주문/배송', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // --- This is the new content ---
                // Order Info Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${widget.order.orderCount}개 >', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
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
                            Text(widget.order.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.order.brandName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 12),
                            Text('${widget.order.orderCount}박스', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text('${formatter.format(widget.order.price)}원 / ${widget.order.weight}kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(widget.order.squareImageUrl, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _trackingData == null
                          ? const Center(child: Text('배송 정보를 조회할 수 없습니다.'))
                          : SingleChildScrollView( // Make the status scrollable
                              child: Column(
                                children: [
                                  _buildDeliveryStatus(_trackingData!),
                                  const SizedBox(height: 40),
                                  const Text('제품에 문제가 있나요?', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('환불 접수하기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        Icon(Icons.chevron_right, color: Colors.black),
                                      ],
                                    ),
                                  ),
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

  /// Helper widget for the delivery status stepper
  Widget _buildDeliveryStatus(DeliveryTrackingData trackingData) {
    final statusMap = {
      'at_pickup': 0,
      'in_transit': 1,
      'out_for_delivery': 2,
      'delivered': 3,
    };
    int currentStep = statusMap[trackingData.currentStateText] ?? 0;
    
    return Column(
      children: [
        _buildStep(title: '결제 완료', isDone: true), // Always done if on this screen
        _buildStepConnector(),
        _buildStep(title: '배송 준비중', isDone: currentStep >= 1, isActive: currentStep == 1),
        _buildStepConnector(),
        _buildStep(title: '배송중', isDone: currentStep >= 2, subText: '운송장 번호: ${trackingData.carrierName}'),
        _buildStepConnector(),
        _buildStep(title: '배송완료', isDone: currentStep >= 3),
      ],
    );
  }

  Widget _buildStep({required String title, String? subText, bool isDone = false, bool isActive = false}) {
    final Color activeColor = isDone ? const Color(0xFF6FCF4B) : Colors.grey.shade300;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.black : Colors.grey)),
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(subText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 20,
      alignment: Alignment.center,
      child: const Icon(Icons.arrow_downward, color: Colors.grey, size: 16),
    );
  }
}