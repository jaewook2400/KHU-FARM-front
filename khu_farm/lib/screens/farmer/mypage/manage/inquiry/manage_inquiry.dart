import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/inquiry.dart'; 
import 'package:khu_farm/model/fruit.dart';

class FarmerManageInquiryScreen extends StatefulWidget {
  const FarmerManageInquiryScreen({super.key});

  @override
  State<FarmerManageInquiryScreen> createState() =>
      _FarmerManageInquiryScreenState();
}

class _FarmerManageInquiryScreenState extends State<FarmerManageInquiryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;

  List<Inquiry> _unansweredInquiries = [];
  final ScrollController _unansweredScrollController = ScrollController();
  bool _isFetchingMoreUnanswered = false;
  bool _hasMoreUnanswered = true;

  List<Fruit> _allProducts = [];
  final ScrollController _allProductsScrollController = ScrollController();
  bool _isFetchingMoreProducts = false;
  bool _hasMoreProducts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _unansweredScrollController.addListener(_onUnansweredScroll);
    _allProductsScrollController.addListener(_onAllProductsScroll); 
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _unansweredScrollController.removeListener(_onUnansweredScroll);
    _unansweredScrollController.dispose();
    _allProductsScrollController.removeListener(_onAllProductsScroll); // ✨ 리스너 해제
    _allProductsScrollController.dispose();
    super.dispose();
  }

  void _onUnansweredScroll() {
    if (_unansweredScrollController.position.pixels >= _unansweredScrollController.position.maxScrollExtent - 50 &&
        _hasMoreUnanswered &&
        !_isFetchingMoreUnanswered) {
      if (_unansweredInquiries.isNotEmpty) {
        _fetchUnansweredInquiries(cursorId: _unansweredInquiries.last.inquiryId);
      }
    }
  }

  void _onAllProductsScroll() {
    if (_allProductsScrollController.position.pixels >= _allProductsScrollController.position.maxScrollExtent - 50 &&
        _hasMoreProducts &&
        !_isFetchingMoreProducts) {
      if (_allProducts.isNotEmpty) {
        _fetchAllProducts(cursorId: _allProducts.last.id);
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchUnansweredInquiries(),
      _fetchAllProducts(), // ✨ 전체 문의 -> 전체 상품 조회로 변경
    ]);
    if (mounted) setState(() => _isLoading = false);
  }
  
  // ✨ 두 종류의 문의 데이터를 모두 가져오는 통합 함수
  Future<void> _fetchUnansweredInquiries({int? cursorId}) async {
    if (_isFetchingMoreUnanswered) return;
    
    setState(() {
      if (cursorId != null) _isFetchingMoreUnanswered = true;
    });

    try {
      final token = await StorageService.getAccessToken();
      if (token == null) throw Exception('Token is missing');
      
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/inquiry/seller/notAnswered').replace(
        queryParameters: {
          'size': '10',
          if (cursorId != null) 'cursorId': cursorId.toString(),
        },
      );

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final items = (data['result']['content'] as List)
              .map((item) => Inquiry.fromJson(item))
              .toList();
          
          setState(() {
            if (cursorId == null) {
              _unansweredInquiries = items;
            } else {
              _unansweredInquiries.addAll(items);
            }
            if (items.length < 10) {
              _hasMoreUnanswered = false;
            }
          });
        }
      } else {
        throw Exception('Failed to fetch unanswered inquiries');
      }
    } catch (e) {
      print('Error fetching unanswered inquiries: $e');
    } finally {
      if (mounted) setState(() => _isFetchingMoreUnanswered = false);
    }
  }

  Future<void> _fetchAllProducts({int? cursorId}) async {
    if (_isFetchingMoreProducts) return;
    
    setState(() {
      if (cursorId != null) _isFetchingMoreProducts = true;
    });

    try {
      final token = await StorageService.getAccessToken();
      if (token == null) throw Exception('Token is missing');
      
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/fruits/seller').replace(
        queryParameters: {
          'size': '5',
          if (cursorId != null) 'cursorId': cursorId.toString(),
        },
      );

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final items = (data['result']['content'] as List)
              .map((item) => Fruit.fromJson(item))
              .toList();
          
          setState(() {
            if (cursorId == null) {
              _allProducts = items;
            } else {
              _allProducts.addAll(items);
            }
            if (items.length < 5) {
              _hasMoreProducts = false;
            }
          });
        }
      } else {
        throw Exception('Failed to fetch all products');
      }
    } catch (e) {
      print('Error fetching all products: $e');
    } finally {
      if (mounted) setState(() => _isFetchingMoreProducts = false);
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
                      '받은 문의',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(text: '답변 전'),
                    Tab(text: '전체 보기'),
                  ],
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUnansweredList(),
                      _buildAllProductsList(),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUnansweredList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_unansweredInquiries.isEmpty) {
      return const Center(child: Text('답변 전 문의가 없습니다.'));
    }
    return ListView.builder(
      controller: _unansweredScrollController, // 컨트롤러 연결
      padding: EdgeInsets.zero,
      itemCount: _unansweredInquiries.length + (_hasMoreUnanswered ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _unansweredInquiries.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final inquiry = _unansweredInquiries[index];
        return _InquiryCard(inquiry: inquiry);
      },
    );
  }

  /// "전체 보기" 탭을 위한 위젯
  Widget _buildAllProductsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allProducts.isEmpty) {
      return const Center(child: Text('등록된 상품이 없습니다.'));
    }
    return ListView.builder(
      controller: _allProductsScrollController,
      padding: EdgeInsets.zero,
      itemCount: _allProducts.length + (_hasMoreProducts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allProducts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final product = _allProducts[index];
        return _ProductInquiryCard(
          product: product,
          onTap: () {
            Navigator.pushNamed(context, '/farmer/mypage/manage/inquiry/detail', arguments: product);
          },
        );
      },
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final Inquiry inquiry;
  const _InquiryCard({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Q:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(inquiry.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              // TODO: '더보기' 클릭 시 상세 페이지로 이동하는 로직 추가
              const Text('더보기 >', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          // ✨ 답변 유무에 따라 분기 처리
          if (inquiry.reply != null)
            Text('A: ${inquiry.reply!.content}', style: const TextStyle(color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis,)
          else
            const Text('A: 답변 대기중', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/// A card for displaying a product in the "View All" list
class _ProductInquiryCard extends StatelessWidget {
  final Fruit product;
  final VoidCallback onTap;
  const _ProductInquiryCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.squareImageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey[200]),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.brandName ?? '브랜드 없음',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${formatter.format(product.price)}원', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}