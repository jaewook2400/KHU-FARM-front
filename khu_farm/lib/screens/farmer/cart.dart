import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:khu_farm/fruit.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/storage_service.dart';

// API 응답에 맞춘 새로운 데이터 모델
class CartItemData {
  final Fruit fruit;
  final int count;

  CartItemData({required this.fruit, required this.count});

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    // API 응답의 각 항목을 Fruit 객체와 count로 분리하여 저장
    return CartItemData(
      fruit: Fruit.fromJson(json),
      count: json['count'] ?? 0,
    );
  }
}

class FarmerCartScreen extends StatefulWidget {
  const FarmerCartScreen({super.key});

  @override
  State<FarmerCartScreen> createState() => _FarmerCartScreenState();
}

class _FarmerCartScreenState extends State<FarmerCartScreen> {
  List<CartItemData> _cartItems = [];
  Map<int, bool> _selectedItems = {};
  bool _isLoading = true;
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('Error: Access token is missing.');
        return;
      }
      final headers = {'Authorization': 'Bearer $accessToken'};

      final response = await http.get(Uri.parse('$baseUrl/cart'), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> itemsJson = data['result']['fruitsWithCount']['content'];
          setState(() {
            _cartItems = itemsJson.map((json) => CartItemData.fromJson(json)).toList();
            // 기본적으로 모든 항목을 선택된 상태로 초기화
            _selectedItems = {for (var item in _cartItems) item.fruit.id: true};
            _updateSelectAllState();
          });
        }
      } else {
        print('Cart API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while fetching cart items: $e');
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemSelect(int fruitId, bool isSelected) {
    setState(() {
      _selectedItems[fruitId] = isSelected;
      _updateSelectAllState();
    });
  }

  void _onSelectAll(bool? isSelected) {
    if (isSelected == null) return;
    setState(() {
      _isAllSelected = isSelected;
      for (var item in _cartItems) {
        _selectedItems[item.fruit.id] = isSelected;
      }
    });
  }

  void _updateSelectAllState() {
    if (_cartItems.isEmpty) {
      _isAllSelected = false;
      return;
    }
    _isAllSelected = _selectedItems.values.every((isSelected) => isSelected);
  }

  int _calculateTotalPrice() {
    int total = 0;
    for (var item in _cartItems) {
      if (_selectedItems[item.fruit.id] == true) {
        total += item.fruit.price * item.count;
      }
    }
    return total;
  }
  
  // TODO: 수량 변경 API 연동
  void _updateQuantity(int fruitId, int newQuantity) {
    // 수량 변경 API 호출 후 _fetchCartItems() 재호출
  }

  // TODO: 장바구니 삭제 API 연동
  void _deleteItem(int fruitId) {
    // 삭제 API 호출 후 _fetchCartItems() 재호출
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
    final totalPayment = _calculateTotalPrice();
    final deliveryFee = totalPayment > 0 ? 5000 : 0; // 예시 배송비
    final finalPayment = totalPayment + deliveryFee;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 상단 UI (변경 없음)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + screenHeight * 0.06,
            child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),
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
                      onTap: () {},
                      child: Image.asset(
                        'assets/top_icons/cart_selected_morning.png',
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
                      '장바구니',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isAllSelected,
                                    onChanged: _onSelectAll,
                                  ),
                                  const Text('전체선택', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = _cartItems[index];
                                  return _CartListItem(
                                    itemData: item,
                                    isSelected: _selectedItems[item.fruit.id] ?? false,
                                    onSelected: (isSelected) => _onItemSelect(item.fruit.id, isSelected),
                                    onQuantityChanged: (newQuantity) => _updateQuantity(item.fruit.id, newQuantity),
                                    onDelete: () => _deleteItem(item.fruit.id),
                                  );
                                },
                              ),
                              const Divider(thickness: 1.0, height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '결제 예상 금액',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${formatter.format(finalPayment)}원',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('상품 금액'),
                                  Text('${formatter.format(totalPayment)}원')
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('배송비'),
                                  Text('${formatter.format(deliveryFee)}원')
                                ],
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 결제 API 연동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  '${formatter.format(finalPayment)}원 결제하기',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 장바구니 각 항목을 렌더링하는 위젯
class _CartListItem extends StatelessWidget {
  final CartItemData itemData;
  final bool isSelected;
  final Function(bool) onSelected;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;

  const _CartListItem({
    required this.itemData,
    required this.isSelected,
    required this.onSelected,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final fruit = itemData.fruit;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: isSelected, onChanged: (val) => onSelected(val!)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fruit.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  fruit.brandName ?? '알 수 없음',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatter.format(fruit.price)}원 / ${fruit.weight}kg',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (itemData.count > 1) onQuantityChanged(itemData.count - 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        itemData.count.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onQuantityChanged(itemData.count + 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fruit.squareImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                    width: 80, height: 80, child: Icon(Icons.error));
              },
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}