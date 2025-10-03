import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/model/seller_order.dart';
import 'package:khu_farm/model/order_status.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/screens/farmer/mypage/order/order_detail.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/screens/farmer/mypage/manage/order/order_handle_list.dart';



class PaymentCancelScreen extends StatefulWidget {
  const PaymentCancelScreen({super.key});

  @override
  State<PaymentCancelScreen> createState() => _PaymentCancelScreenState();
}

class _PaymentCancelScreenState extends State<PaymentCancelScreen> {

  List<SellerOrder> _orders = [];
  bool _isLoading = true;

  // ✨ 1. 페이지네이션을 위한 상태 변수 추가
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    print("initState!");
    _fetchSellerOrders();
    print('the length of orders is ${_orders.length}');
    // ✨ 2. 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _titleOf(OrderSection s) {
    switch (s) {
      case OrderSection.newOrder:
        return 'NEW! 신규 주문';
      case OrderSection.shipping:
        return '배송 현황';
      case OrderSection.refund:
        return '환불 처리';
      case OrderSection.cancelled:
        return '결제 취소';
    }
  }

  // argument에 따라 바뀌는 “사소한 버튼”
  Widget _actionButton(OrderSection s) {
    switch (s) {
      case OrderSection.newOrder:
        return ElevatedButton(
          onPressed: () {
            setState(() {
              // 예: 신규 주문 처리 로직
            });
          },
          child: const Text('결제 완료'),
        );
      case OrderSection.shipping:
        return ElevatedButton(
          onPressed: () {
            setState(() {
              // 예: 송장 업로드 로직
            });
          },
          child: const Text('배송 중'),
        );
      case OrderSection.refund:
        return ElevatedButton(
          onPressed: () {
            setState(() {
              // 예: 환불 승인 로직
            });
          },
          child: const Text('환불 대기'),
        );
      case OrderSection.cancelled:
        return ElevatedButton(
          onPressed: () {
            setState(() {
              // 예: 취소 관련 로직
            });
          },
          child: const Text('결제 취소'),
        );
    }
  }

  // ✨ 3. 스크롤 감지 및 추가 데이터 요청 함수
  void _onScroll() {
    // 필터가 적용되지 않았을 때만 무한 스크롤 동작
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 &&
        _hasMore &&
        !_isFetchingMore) {
      if (_orders.isNotEmpty) {
        _fetchSellerOrders(cursorId: _orders.last.orderDetailId);
      }
    }
  }

  // ✨ 4. cursorId를 파라미터로 받도록 _fetchSellerOrders 함수 수정
  Future<void> _fetchSellerOrders({int? cursorId}) async {
    if (_isFetchingMore) return;

    setState(() {
      if (cursorId == null) {
        _isLoading = true;
        // ✨ 새로고침 시 기존 데이터를 비우고, 페이지네이션 상태를 초기화
        _orders = [];
        _hasMore = true;
      } else {
        _isFetchingMore = true;
      }
    });


    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) return;

      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/order/seller/orders/4').replace(queryParameters: {
        'size': '5',
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print(data);

        if (data['isSuccess'] == true) {
          _handleOrders(data, cursorId);
        }
      } else {
        // ✅ 200이 아닐 경우에도 목데이터 채우기
        print('Server error: ${response.statusCode}, using mock data');
        _handleOrders(null, cursorId);
      }
    } catch (e) {
      print('Failed to fetch seller orders: $e');
    } finally {
      if (mounted) setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  void _handleOrders(dynamic data, int? cursorId) { //statusCode가 200이 아닐 때 목데이터를 _orders에 저장해주는 함수
    List<dynamic> orderJson = [];

    if (data == null || data['result'] == null || (data['result']['size'] ?? 0) == 0) {
      // ✅ 목데이터
      orderJson = [
        {
          "orderId": 1,
          "orderDetailId": 101,
          "merchantUid": "MUID-001",
          "ordererName": "홍길동",
          "totalPrice": 15000,
          "fruitTitle": "사과 3kg",
          "orderCount": 1,
          "portCode": "PORT001",
          "address": "서울특별시 강남구 테헤란로 123",
          "detailAddress": "101호",
          "recipient": "홍길동",
          "phoneNumber": "010-1234-5678",
          "deliveryCompany": "CJ대한통운",
          "deliveryNumber": "123456789",
          "orderRequest": "문 앞에 두세요",
          "deliveryStatus": "ORDER_COMPLETED",
          "orderStatus": "결제 취소",
          "refundReason": "",
          "createdAt": "2025-10-01T08:49:27.703Z"
        },
        {
          "orderId": 2,
          "orderDetailId": 102,
          "merchantUid": "MUID-002",
          "ordererName": "김철수",
          "totalPrice": 20000,
          "fruitTitle": "배 5kg",
          "orderCount": 2,
          "portCode": "PORT002",
          "address": "부산광역시 해운대구 센텀로 456",
          "detailAddress": "202호",
          "recipient": "김철수",
          "phoneNumber": "010-9876-5432",
          "deliveryCompany": "한진택배",
          "deliveryNumber": "987654321",
          "orderRequest": "직접 전달 부탁드립니다",
          "deliveryStatus": "SHIPPING",
          "orderStatus": "결제 취소",
          "refundReason": "",
          "createdAt": "2025-10-01T08:50:00.000Z"
        },
      ];
    } else {
      orderJson = data['result']['content'] ?? [];
    }

    final newOrders = orderJson.map((json) => SellerOrder.fromJson(json)).toList();

    setState(() {
      if (cursorId == null) {
        _orders = newOrders;
      } else {
        _orders.addAll(newOrders);
      }
      if (newOrders.length < 5) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final String title = "결제 취소";

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

    List<SellerOrder> filteredOrders = List.from(_orders);

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
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16,),

                // Order List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredOrders.isEmpty
                      ? const Center(child: Text('주문 내역이 없습니다.'))
                  // ✨ 5. ListView.builder 수정
                      : ListView.builder(
                    controller: _scrollController, // 컨트롤러 연결
                    padding: EdgeInsets.zero,
                    itemCount: filteredOrders.length +
                        // 필터가 없고, 더 불러올 데이터가 있을 때만 로딩 인디케이터 공간 추가
                        (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 마지막 아이템일 경우 로딩 인디케이터 표시
                      if (index == filteredOrders.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final order = filteredOrders[index];
                      // --- This is the updated part ---
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/farmer/mypage/manage/order/detail',
                            arguments: order,
                          );
                          _fetchSellerOrders();
                        },
                        child: _OrderInfoCard(
                          order: order,
                          onEditTrackingNumber: () async {
                            await Navigator.pushNamed(
                              context,
                              '/farmer/mypage/manage/order/delnum',
                              arguments: order,
                            );
                            _fetchSellerOrders();
                          },
                          onTrackDelivery: () {
                            Navigator.pushNamed(
                              context,
                              '/farmer/mypage/manage/order/delstat',
                              arguments: order,
                            );
                          },
                          onRefund: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/farmer/mypage/manage/order/refund',
                              arguments: order,
                            );

                            // 환불 화면에서 true(승인) 또는 false(거절)를 반환받으면 목록 새로고침
                            if (result == true || result == false) {
                              _fetchSellerOrders();
                            }
                          },
                        ),
                      );
                      // --- End of update ---
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    Widget Function(T)? itemBuilder, // Optional builder for custom item text
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(color: Colors.black, fontSize: 14)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder != null ? itemBuilder(item) : Text(item.toString(), style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  final SellerOrder order;
  final VoidCallback onEditTrackingNumber;
  final VoidCallback onTrackDelivery;
  // ✨ 2. onRefund 콜백 추가
  final VoidCallback onRefund;

  const _OrderInfoCard(
      {required this.order,
        required this.onEditTrackingNumber,
        required this.onTrackDelivery,
        required this.onRefund}); // ✨ 3. 생성자에 onRefund 추가

  @override
  Widget build(BuildContext context) {
    final DeliveryStatus status =
        statusMap[order.status] ?? statusMap['알 수 없음']!;

    String formattedDate = '';
    try {
      if (order.createdAt.isNotEmpty) {
        formattedDate =
            DateFormat('yyyy.MM.dd').format(DateTime.parse(order.createdAt));
      }
    } catch (e) {
      formattedDate = order.createdAt.split('T').first;
    }

    final bool isTrackingNumberRegistered =
        order.deliveryNumber != null && order.deliveryNumber != '미등록';

    final bool isRefundPending = order.status == '환불 대기';

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.recipient,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFFB3B3B3),
                        width: 0.5,
                      )
                  ),
                  child: Row(
                    children: [
                      Text(
                        '결제 취소',
                        style: TextStyle(
                            color: Color(0xFFB3B3B3),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4,),
                Icon(Icons.arrow_forward_ios, color: Color(0xFF333333), size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text('주문일자 : $formattedDate', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 2),
            Text('주문번호 : ${order.merchantUid}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 2),
            Text('${order.address} ${order.detailAddress}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  isTrackingNumberRegistered ? '송장번호 수정' : '송장번호 입력',
                  onPressed: onEditTrackingNumber,
                ),
                _actionButton('배송 현황 확인', onPressed: onTrackDelivery),
                isRefundPending
                    ? SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    // ✨ 4. onPressed에 콜백 함수 연결
                    onPressed: onRefund,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('환불'),
                  ),
                )
                    : _actionButton('환불', onPressed: null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
        width: 90,
        height: 24,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            disabledForegroundColor: Colors.grey.shade400,
            side: BorderSide(
              color:
              onPressed != null ? Colors.grey.shade600 : Colors.grey.shade300,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        )
    );
  }
}