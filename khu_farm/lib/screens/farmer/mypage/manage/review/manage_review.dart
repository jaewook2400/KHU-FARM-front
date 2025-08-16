import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/review.dart';
import 'package:khu_farm/model/fruit.dart';

class FarmerManageReviewScreen extends StatefulWidget {
  const FarmerManageReviewScreen({super.key});

  @override
  State<FarmerManageReviewScreen> createState() =>
      _FarmerManageReviewScreenState();
}

class _FarmerManageReviewScreenState extends State<FarmerManageReviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // '답변 전' 리뷰 상태
  List<ReviewInfo> _unansweredReviews = [];
  final ScrollController _unansweredScrollController = ScrollController();
  bool _isFetchingMoreUnanswered = false;
  bool _hasMoreUnanswered = true;

  // '전체 보기' 리뷰 상태 (기존 로직 유지)
  List<Fruit> _allProducts = [];
  final ScrollController _allProductsScrollController = ScrollController();
  bool _isFetchingMoreProducts = false;
  bool _hasMoreProducts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _unansweredScrollController.addListener(_onUnansweredScroll);
    _allProductsScrollController.addListener(_onAllProductsScroll); // ✨ 리스너 추가
    _fetchData();
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
      if (_unansweredReviews.isNotEmpty) {
        _fetchUnansweredReviews(
            _unansweredReviews.last.reviewId as String, // Assuming reviewId is String
            cursorId: _unansweredReviews.last.reviewId);
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

  Future<void> _fetchData() async {
    if (mounted) setState(() => _isLoading = true);
    final String? token = await StorageService.getAccessToken();
    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    await Future.wait([
      _fetchUnansweredReviews(token),
      _fetchAllProducts(token: token), // ✨ 전체 리뷰 -> 전체 상품 조회로 변경
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  // '답변 전' 리뷰를 가져오는 API 호출
  Future<void> _fetchUnansweredReviews(String token, {int? cursorId}) async {
    if (_isFetchingMoreUnanswered) return;
    if (cursorId == null) _hasMoreUnanswered = true;

    setState(() {
      if (cursorId != null) _isFetchingMoreUnanswered = true;
    });

    try {
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/review/seller/notAnswered').replace(
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
              .map((item) => ReviewInfo.fromJson(item))
              .toList();
          setState(() {
            if (cursorId == null) {
              _unansweredReviews = items;
            } else {
              _unansweredReviews.addAll(items);
            }
            if (items.length < 5) {
              _hasMoreUnanswered = false;
            }
          });
        }
      } else {
        throw Exception('Failed to fetch unanswered reviews');
      }
    } catch (e) {
      print('Error fetching unanswered reviews: $e');
    } finally {
      if(mounted) setState(() => _isFetchingMoreUnanswered = false);
    }
  }

  // ✨ '전체' 리뷰를 가져오는 API 호출
  Future<void> _fetchAllProducts({String? token, int? cursorId}) async {
    if (_isFetchingMoreProducts) return;
    if (cursorId == null) _hasMoreProducts = true;

    setState(() {
      if (cursorId != null) _isFetchingMoreProducts = true;
    });

    try {
      final accessToken = token ?? await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing');
      
      final headers = {'Authorization': 'Bearer $accessToken'};
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
                      '리뷰 관리',
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
    if (_unansweredReviews.isEmpty) {
      return const Center(child: Text('답변을 기다리는 리뷰가 없습니다.'));
    }
    return ListView.builder(
      controller: _unansweredScrollController,
      padding: EdgeInsets.zero,
      itemCount: _unansweredReviews.length + (_hasMoreUnanswered ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _unansweredReviews.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _ReviewCard(review: _unansweredReviews[index], onRefresh: _fetchData);
      },
    );
  }

  /// "전체 보기" 탭 UI
  Widget _buildAllProductsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allProducts.isEmpty) {
      return const Center(child: Text('등록된 상품이 없습니다.'));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
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
              // ✨ 2. onTap 콜백에 내비게이션 및 새로고침 로직 추가
              return _ProductReviewCard(
                product: product,
                onTap: () async {
                  // 상세 화면으로 이동하고, 결과를 기다립니다.
                  final result = await Navigator.pushNamed(
                    context,
                    '/farmer/mypage/manage/review/product',
                    arguments: product,
                  );
                  // 상세 화면에서 돌아왔을 때 결과가 true이면, 데이터 새로고침
                  if (result == true) {
                    _fetchData();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 리뷰 카드 위젯 (답변 표시 기능 추가)
class _ReviewCard extends StatelessWidget {
  final ReviewInfo review;
  final VoidCallback onRefresh;

  const _ReviewCard({
    required this.review,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/farmer/mypage/manage/review/detail', // 상세 화면 라우트
          arguments: {'review': review},
        );
        // 상세 화면에서 돌아왔을 때, 결과가 true이면 목록 새로고침
        if (result == true) {
          onRefresh();
        }
      },
      child: Container(
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
            // --- 메인 레이아웃: 이미지 | 정보 ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 리뷰 이미지 (있을 경우에만 표시)
                if (review.imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(width: 80, height: 80, color: Colors.grey[200]),
                      ),
                    ),
                  ),
                
                // 오른쪽: 텍스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목과 별점
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              review.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  color: i < review.rating ? Colors.red : Colors.grey.shade300,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                review.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 리뷰 내용
                      Text(
                        review.content,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

class _ProductReviewCard extends StatelessWidget {
  final Fruit product;
  final VoidCallback onTap; // ✨ onTap 콜백 추가

  const _ProductReviewCard({required this.product, required this.onTap});

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.widthImageUrl,
                    height: 140,
                    width: double.infinity, // ✨ 1. 이 줄을 추가하여 가로를 꽉 채웁니다.
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        Container(height: 140, color: Colors.grey[200]),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 12,
                  child: Text(
                    product.brandName ?? '알 수 없음',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 2)]),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${formatter.format(product.price)}원',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}