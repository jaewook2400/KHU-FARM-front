import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/fruit.dart'; // Fruit 모델 임포트
import 'package:khu_farm/services/storage_service.dart';

class FarmerManageProductListScreen extends StatefulWidget {
  const FarmerManageProductListScreen({super.key});

  @override
  State<FarmerManageProductListScreen> createState() =>
      _FarmerManageProductListScreenState();
}

class _FarmerManageProductListScreenState
    extends State<FarmerManageProductListScreen> {
  bool _isLoading = true;
  List<Fruit> _products = [];

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
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
      if (_products.isNotEmpty) {
        _fetchMyProducts(cursorId: _products.last.id);
      }
    }
  }
  
  Future<void> _fetchMyProducts({int? cursorId}) async {
    if (_isFetchingMore) return;

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMore = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing');
      
      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/fruits/seller').replace(queryParameters: {
        'size': '5',
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final List<dynamic> itemsJson = data['result']['content'];
          final newProducts = itemsJson.map((json) => Fruit.fromJson(json)).toList();
          
          if (mounted) {
            setState(() {
              if (cursorId == null) {
                _products = newProducts;
              } else {
                _products.addAll(newProducts);
              }
              if (newProducts.length < 5) {
                _hasMore = false;
              }
            });
          }
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
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

          // 콘텐츠
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
                      '우리 농가 관리하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _products.isEmpty
                          ? const Center(child: Text('등록된 상품이 없습니다.'))
                          // ✨ 5. ListView.builder 수정
                          : ListView.builder(
                              controller: _scrollController, // 컨트롤러 연결
                              itemCount: _products.length + (_hasMore ? 1 : 0), // 로딩 인디케이터 공간 추가
                              itemBuilder: (context, index) {
                                if (index == _products.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return _ProductManageCard(
                                  product: _products[index],
                                  onProductEdited: () => _fetchMyProducts(),
                                );
                              },
                            ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ProductManageCard extends StatelessWidget {
  final Fruit product;
  final Future<void> Function() onProductEdited; 
  const _ProductManageCard({required this.product, required this.onProductEdited});

  @override
  Widget build(BuildContext context) {
    // 재고가 0이면 품절로 간주
    final bool isSoldOut = product.stock == 0;
    final formatter = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSoldOut ? Colors.red.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSoldOut ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // 이미지 섹션
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.squareImageUrl, // Fruit 모델의 이미지 URL 사용
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey[200]),
                ),
              ),
              // 농가 이름 태그
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(product.brandName!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              // 품절 오버레이
              if (isSoldOut)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                        SizedBox(height: 4),
                        Text('제품이 품절되었습니다.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // 상품 정보 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${formatter.format(product.price)}원', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // 버튼 섹션
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // 삭제 화면으로 이동하고 돌아올 때까지 기다립니다.
                      await Navigator.pushNamed(
                        context,
                        '/farmer/mypage/manage/product/delete',
                        arguments: product,
                      );
                      // ✅ 돌아오면 항상 새로고침 콜백을 호출합니다.
                      onProductEdited();
                    },

                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isSoldOut ? Colors.red.shade300 : Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('제품 삭제하기', style: TextStyle(color: isSoldOut ? Colors.red.shade300 : Colors.grey.shade600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 수정 화면으로 이동하고, 돌아올 때까지 기다림
                      await Navigator.pushNamed(
                        context,
                        '/farmer/mypage/manage/product/edit', // 수정 화면 라우트 경로
                        arguments: product, // product 객체를 arguments로 전달
                      );
                      // 수정 화면에서 돌아오면 onProductEdited 콜백을 실행하여 목록 새로고침
                      onProductEdited();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSoldOut ? Colors.red.shade300 : const Color(0xFF6FCF4B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('제품 수정하기', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}