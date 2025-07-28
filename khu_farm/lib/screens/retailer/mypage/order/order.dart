import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/screens/retailer/mypage/order/order_detail.dart';
import 'package:http/http.dart' as http;

class RetailerOrderListScreen extends StatefulWidget {
  const RetailerOrderListScreen({super.key});

  @override
  State<RetailerOrderListScreen> createState() => _RetailerOrderListScreenState();
}

class _RetailerOrderListScreenState extends State<RetailerOrderListScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      setState(() => _isLoading = false);
      return;
    }

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/payment?size=1000');

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> orderJson = data['result']['content'];
          if (mounted) {
            setState(() {
              _orders = orderJson.map((json) => Order.fromJson(json)).toList();
            });
          }
        }
      }
    } catch (e) {
      print('Failed to fetch orders: $e');
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
                    //       '/retailer/notification/list',
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
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: 20,
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
                      '주문/배송',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _orders.isEmpty
                          ? const Center(child: Text('주문 내역이 없습니다.'))
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                return _OrderCard(order: _orders[index]);
                              },
                            ),
                ),
                const SizedBox(height: 30,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    String formattedDate = '';
    try {
      if (order.createdAt.isNotEmpty) {
        formattedDate =
            DateFormat('yyyy.MM.dd').format(DateTime.parse(order.createdAt));
      }
    } catch (e) {
      formattedDate = order.createdAt;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 주문 날짜 및 수량 정보 (기존과 동일)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.orderCount}개 >',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        // 주문 상세 정보 카드 (기존과 동일)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Container(
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
        ),
        const SizedBox(height: 12),

        // --- 🔽 "리뷰 작성" 버튼 위젯 수정 🔽 ---
        
        // TODO: [리뷰 작성 버튼 활성화 로직] 추후 API에 orderStatus와 리뷰 작성 여부 필드가 추가되면 아래 주석을 해제하고 사용하세요.
        /*
        // 1. 이미 리뷰를 작성했는지 확인 (API 응답에 isReviewed 와 같은 boolean 필드가 필요합니다)
        final bool hasReview = order.isReviewed;

        // 2. 리뷰 작성이 가능한 주문 상태인지 확인 (API 응답에 orderStatus 필드가 필요합니다)
        final String currentStatus = order.orderStatus;
        final bool isReviewableStatus = currentStatus == '배달완료' ||
            currentStatus == '환불 대기' ||
            currentStatus == '주문 취소';

        // 3. 최종적으로 버튼이 활성화될 조건
        final bool isButtonEnabled = isReviewableStatus && !hasReview;
        
        // 4. 버튼 텍스트
        final String buttonText = hasReview ? '리뷰 작성 완료' : '리뷰 작성';
        */
        
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            // onPressed: isButtonEnabled ? () { ... } : null, // 추후 위 로직과 연결
            onPressed: () {
              // 리뷰 작성 페이지로 이동하며 order 객체를 arguments로 전달
              Navigator.pushNamed(
                context,
                '/retailer/mypage/order/review/add',
                arguments: order,
              );
            },
            // style: ElevatedButton.styleFrom( backgroundColor: isButtonEnabled ? ... ), // 추후 위 로직과 연결
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6FCF4B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            // child: Text(buttonText), // 추후 위 로직과 연결
            child: const Text(
              '리뷰 작성',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // --- 🔼 버튼 위젯 수정 끝 🔼 ---
        const SizedBox(height: 24),
      ],
    );
  }
}