import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/screens/consumer/mypage/order/order_detail.dart';
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

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // ✨ 2. 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ✨ 3. 스크롤 감지 및 추가 데이터 요청 함수
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 &&
        _hasMore &&
        !_isFetchingMore) {
      if (_orders.isNotEmpty) {
        // 마지막 주문의 orderId를 cursor로 사용
        _fetchOrders(cursorId: _orders.last.orderId);
      }
    }
  }

  Future<void> _fetchOrders({int? cursorId}) async {
    if (_isFetchingMore) return;

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMore = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');
      
      final headers = {'Authorization': 'Bearer $accessToken'};
      // 페이지 크기는 10으로 설정, cursorId는 있을 때만 추가
      final uri = Uri.parse('$baseUrl/payment').replace(queryParameters: {
        'size': '10', 
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> orderJson = data['result']['content'];
          final newOrders = orderJson.map((json) => Order.fromJson(json)).toList();
          
          if (mounted) {
            setState(() {
              if (cursorId == null) {
                _orders = newOrders;
              } else {
                _orders.addAll(newOrders);
              }
              if (newOrders.length < 10) {
                _hasMore = false;
              }
            });
          }
        }
      }
    } catch (e) {
      print('Failed to fetch orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
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
                          // ✨ 5. ListView.builder 수정
                          : ListView.builder(
                              controller: _scrollController, // 컨트롤러 연결
                              padding: EdgeInsets.zero,
                              itemCount: _orders.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _orders.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
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

    final bool isReviewable = (order.deliveryStatus?.currentStateText == '배송완료') | (order.deliveryStatus?.currentStateText == '배송완료');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            // ✨ isReviewable 값에 따라 onPressed 동작을 결정
            onPressed: isReviewable
                ? () {
                    Navigator.pushNamed(
                      context,
                      '/retailer/mypage/order/review/add',
                      arguments: order,
                    );
                  }
                : null, // false일 경우 버튼 비활성화
            style: ElevatedButton.styleFrom(
              // ✨ isReviewable 값에 따라 버튼 색상 변경
              backgroundColor: isReviewable ? const Color(0xFF6FCF4B) : Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              '리뷰 작성',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}