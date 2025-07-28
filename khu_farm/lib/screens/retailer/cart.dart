import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';

// API 응답에 맞춘 새로운 데이터 모델
class CartItemData {
  final Fruit fruit;
  int count;
  final int cartId;

  CartItemData({required this.fruit, required this.count, required this.cartId});

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      fruit: Fruit.fromJson(json),
      count: json['count'] ?? 0,
      cartId: json['cartId'] ?? -1,
    );
  }
}

class RetailerCartScreen extends StatefulWidget {
  const RetailerCartScreen({super.key});

  @override
  State<RetailerCartScreen> createState() => _RetailerCartScreenState();
}

class _RetailerCartScreenState extends State<RetailerCartScreen> {
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
  Future<void> _updateQuantity(int cartId, bool increase) async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    // Determine the correct API endpoint based on the 'increase' flag
    final String action = increase ? 'increase' : 'decrease';
    final uri = Uri.parse('$baseUrl/cart/$cartId/$action');

    try {
      // Use PATCH method for the API call
      final response = await http.patch(uri, headers: headers);

      if (response.statusCode == 200) {
        print('Quantity updated successfully.');
        // On success, refresh the entire cart list
        await _fetchCartItems();
      } else {
        print('Failed to update quantity: ${response.statusCode}');
        print('Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('수량 변경에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      print('An error occurred while updating quantity: $e');
    }
  }

  // TODO: 장바구니 삭제 API 연동
  Future<void> _deleteItem(int cartId) async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print('Error: Access token is missing.');
      return;
    }

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/cart/$cartId/delete');

    try {
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Successfully deleted item from cart.');
        // On success, refresh the cart list to show the change
        await _fetchCartItems();
      } else {
        print('Failed to delete item. Status: ${response.statusCode}');
        print('Response Body: ${utf8.decode(response.bodyBytes)}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('삭제에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      print('An error occurred while deleting cart item: $e');
    }
  }

  void _handleCartPayment() {
    // 1. Get a list of cartIds for the selected items
    final List<int> selectedCartIds = [];
    for (var item in _cartItems) {
      // Check the _selectedItems map; note the key is fruit.id
      if (_selectedItems[item.fruit.id] == true) {
        selectedCartIds.add(item.cartId);
      }
    }

    if (selectedCartIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제할 상품을 선택해주세요.')),
      );
      return;
    }

    // 2. Navigate to the cart order screen with the list of IDs
    Navigator.pushNamed(
      context,
      '/order/cart',
      arguments: {
        'cartIds': selectedCartIds,
      },
    );
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
    final deliveryFee = 0;
    // final deliveryFee = totalPayment > 0 ? 5000 : 0; // 예시 배송비
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
            ),
            child: Column(
              children: [
                // '장바구니' 타이틀
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/icons/goback.png', width: 18, height: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('장바구니', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),

                // '전체선택' 체크박스
                Row(
                  children: [
                    Checkbox(
                      value: _isAllSelected,
                      onChanged: _onSelectAll,
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => BorderSide(
                          width: 1.5,
                          color: states.contains(MaterialState.selected) ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    const Text('전체선택', style: TextStyle(fontSize: 14)),
                  ],
                ),

                // 상품 목록 (스크롤 영역)
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _cartItems.isEmpty
                          ? const Center(child: Text('장바구니에 담긴 상품이 없습니다.'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 160), // 하단 결제 영역만큼 여백 확보
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return _CartListItem(
                                  itemData: item,
                                  isSelected: _selectedItems[item.fruit.id] ?? false,
                                  onSelected: (isSelected) => _onItemSelect(item.fruit.id, isSelected),
                                  onQuantityChanged: (cartId, increase) => _updateQuantity(item.cartId, increase),
                                  onDelete: () => _deleteItem(item.cartId),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),

          // 하단 결제 정보 및 버튼 (Stack의 맨 위에 위치)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(screenWidth * 0.08, 16, screenWidth * 0.08, MediaQuery.of(context).padding.bottom + 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('결제 예상 금액', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${formatter.format(finalPayment)}원', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('상품 금액'),
                      Text('${formatter.format(totalPayment)}원'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('배송비'),
                      Text('${formatter.format(deliveryFee)}원'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _handleCartPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCF4B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('${formatter.format(finalPayment)}원 결제하기', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          )
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
  final Function(int, bool) onQuantityChanged;
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단 영역: 체크박스와 삭제 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (val) => onSelected(val!),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // --- 이 부분이 추가되었습니다 ---
                activeColor: Colors.white,
                checkColor: Colors.black,
                side: MaterialStateBorderSide.resolveWith(
                  (states) => BorderSide(
                    width: 1.5,
                    color: states.contains(MaterialState.selected)
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                // --- 여기까지 ---
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 20, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 하단 영역: 정보와 이미지
          LayoutBuilder(
            builder: (context, constraints) {
              final imageSize = constraints.maxWidth * 0.33;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 정보 영역 (상품명, 농장, 수량, 가격)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fruit.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fruit.brandName ?? '알 수 없음',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildQuantityButton(
                                icon: Icons.remove,
                                onTap: () {
                                  onQuantityChanged(itemData.cartId, false);
                                }),
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  itemData.count.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                                icon: Icons.add,
                                onTap: () {
                                  onQuantityChanged(itemData.cartId, true);
                                }),
                            const SizedBox(width: 8),
                            const Text('박스',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${itemData.count}박스',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${formatter.format(fruit.price * itemData.count)}원',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/ ${fruit.weight}kg',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 이미지 영역
                  Container(
                    width: imageSize,
                    height: imageSize,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fruit.squareImageUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child:
                                const Icon(Icons.error, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 수량 조절 버튼을 위한 헬퍼 위젯
  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}