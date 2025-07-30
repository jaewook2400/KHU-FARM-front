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

class FarmerManageOrderListScreen extends StatefulWidget {
  const FarmerManageOrderListScreen({super.key});

  @override
  State<FarmerManageOrderListScreen> createState() => _FarmerManageOrderListScreenState();
}

class _FarmerManageOrderListScreenState extends State<FarmerManageOrderListScreen> {
  String? _selectedPeriod;
  String? _selectedStatus;

  List<SellerOrder> _orders = [];
  bool _isLoading = true;

  // ✨ 1. 페이지네이션을 위한 상태 변수 추가
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchSellerOrders();
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
    // 필터가 적용되지 않았을 때만 무한 스크롤 동작
    if (_selectedPeriod == null && _selectedStatus == null) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 &&
          _hasMore &&
          !_isFetchingMore) {
        if (_orders.isNotEmpty) {
          _fetchSellerOrders(cursorId: _orders.last.orderDetailId);
        }
      }
    }
  }

  // ✨ 4. cursorId를 파라미터로 받도록 _fetchSellerOrders 함수 수정
  Future<void> _fetchSellerOrders({int? cursorId}) async {
    if (_isFetchingMore) return;

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMore = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) return;

      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/order/seller/orders').replace(queryParameters: {
        'size': '5',
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });
      
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print(data);
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> orderJson = data['result']['content'];
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

    List<SellerOrder> filteredOrders = List.from(_orders);
    
    // Filter by Status
    if (_selectedStatus != null) {
      filteredOrders = filteredOrders
          .where((order) => order.status == _selectedStatus)
          .toList();
    }

    if (_selectedPeriod != null && _selectedPeriod != '모두') {
      DateTime now = DateTime.now();
      DateTime startDate;
      switch (_selectedPeriod) {
        case '1개월':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '2개월':
          startDate = now.subtract(const Duration(days: 60));
          break;
        case '4개월':
          startDate = now.subtract(const Duration(days: 120));
          break;
        case '6개월':
          startDate = now.subtract(const Duration(days: 180));
          break;
        default:
          startDate = DateTime(2000);
      }
      
      filteredOrders = filteredOrders.where((order) {
        try {
          DateTime orderDate = DateTime.parse(order.createdAt);
          return orderDate.isAfter(startDate);
        } catch (e) {
          return false;
        }
      }).toList();
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
                      '주문 내역 확인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16,),

                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildFilterDropdown(
                //         hint: '기간',
                //         value: _selectedPeriod,
                //         items: ['모두', '1개월', '3개월', '6개월'],
                //         onChanged: (val) => setState(() => _selectedPeriod = val == '모두' ? null : val),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildFilterDropdown(
                //         hint: '상태',
                //         value: _selectedStatus,
                //         // statusMap의 key(한글 문자열)를 아이템으로 사용
                //         items: ['모두', ...statusMap.keys.where((k) => k != '알 수 없음')],
                //         onChanged: (val) {
                //           setState(() {
                //             _selectedStatus = val == '모두' ? null : val;
                //           });
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 16),
                
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
                                  (_hasMore && _selectedPeriod == null && _selectedStatus == null ? 1 : 0),
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
  final SellerOrder order; // Use the new SellerOrder model
  final VoidCallback onEditTrackingNumber;
  final VoidCallback onTrackDelivery;
  const _OrderInfoCard({required this.order, required this.onEditTrackingNumber, required this.onTrackDelivery});

  @override
  Widget build(BuildContext context) {
    final DeliveryStatus status = statusMap[order.status] ?? statusMap['알 수 없음']!;
    print(order.status);
    
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


    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.only(bottom: 16),
      // --- 🖼️ 이 부분이 수정되었습니다 ---
      color: Colors.white, // 1. 배경색 흰색으로 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // 2. 테두리 색상을 어두운 회색으로 설정
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        status.displayName,
                        style: TextStyle(
                            color: status.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      Icon(Icons.chevron_right, color: status.color, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('주문일자 : $formattedDate', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text('주문번호 : ${order.merchantUid}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 8),
            Text('${order.address} ${order.detailAddress} [${order.portCode}]', style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  isTrackingNumberRegistered ? '송장번호 수정' : '송장번호 입력',
                  onPressed: onEditTrackingNumber, // 콜백 연결
                ),
                _actionButton('배송 현황 확인', onPressed: onTrackDelivery),
                _actionButton('환불', onPressed: () => {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, {required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      // 텍스트 폰트 사이즈를 기본값으로 되돌립니다.
      child: Text(label),
    );
  }
}