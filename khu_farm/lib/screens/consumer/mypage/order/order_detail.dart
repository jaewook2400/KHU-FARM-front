// lib/screens/consumer/mypage/order_detail_screen.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/model/delivery_tracking.dart';
import 'package:khu_farm/model/order_status.dart';
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
    final getUri = Uri.parse('$baseUrl/delivery/${widget.order.orderId}/tracking');
    final getResponse = await http.get(getUri, headers: headers);
    
    if (getResponse.statusCode == 200) {
      final data = json.decode(utf8.decode(getResponse.bodyBytes));
      if (data['isSuccess'] == true && data['result'] != null) {
        if(mounted) {
          setState(() {
            // --- 이 부분이 수정되었습니다 ---
            // 'deliveryStatus' 객체 대신 'result' 객체 전체를 전달합니다.
            _trackingData = DeliveryTrackingData.fromJson(data['result']);
            // --- 여기까지 ---
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
                                  _buildDeliveryStatus(_trackingData!, widget.order),
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
  Widget _buildDeliveryStatus(DeliveryTrackingData trackingData, Order order) {
    const stepStatuses = ['결제 완료', '배송 준비중', '배송중', '배달 완료'];
    final currentStatusInfo =
        statusMap[trackingData.currentStateText] ?? statusMap['알 수 없음']!;
    int currentStep = stepStatuses.indexOf(currentStatusInfo.stepName);

    final companyName = getDeliveryCompanyName(order.deliveryCompany);

    final invoiceFullText = '운송장 번호 : $companyName ${trackingData.deliveryNumber} (눌러서 복사)';

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
                Clipboard.setData(ClipboardData(text: trackingData.deliveryNumber!));
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