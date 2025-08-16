import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/review.dart'; 
import 'package:khu_farm/model/fruit.dart';

class FarmerManageProductReviewScreen extends StatefulWidget {
  const FarmerManageProductReviewScreen({super.key});

  @override
  State<FarmerManageProductReviewScreen> createState() =>
      _FarmerManageProductReviewScreenState();
}

class _FarmerManageProductReviewScreenState extends State<FarmerManageProductReviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Fruit _fruit;
  bool _isInitialized = false;
  bool _isLoading = true;

  // ✨ 1. 상태 변수를 Inquiry -> ReviewInfo로 변경
  List<ReviewInfo> _unansweredReviews = [];
  final ScrollController _unansweredScrollController = ScrollController();
  bool _isFetchingMoreUnanswered = false;
  bool _hasMoreUnanswered = true;

  List<ReviewInfo> _answeredReviews = [];
  final ScrollController _answeredScrollController = ScrollController();
  bool _isFetchingMoreAnswered = false;
  bool _hasMoreAnswered = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _unansweredScrollController.addListener(_onUnansweredScroll);
    _answeredScrollController.addListener(_onAnsweredScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _fruit = ModalRoute.of(context)!.settings.arguments as Fruit;
      _loadInitialData();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _unansweredScrollController.dispose();
    _answeredScrollController.dispose();
    super.dispose();
  }

  void _onUnansweredScroll() {
    if (_unansweredScrollController.position.pixels >= _unansweredScrollController.position.maxScrollExtent - 50 &&
        _hasMoreUnanswered &&
        !_isFetchingMoreUnanswered) {
      if (_unansweredReviews.isNotEmpty) {
        _fetchUnansweredReviews(cursorId: _unansweredReviews.last.reviewId);
      }
    }
  }

  void _onAnsweredScroll() {
    if (_answeredScrollController.position.pixels >= _answeredScrollController.position.maxScrollExtent - 50 &&
        _hasMoreAnswered &&
        !_isFetchingMoreAnswered) {
      if (_answeredReviews.isNotEmpty) {
        _fetchAnsweredReviews(cursorId: _answeredReviews.last.reviewId);
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchUnansweredReviews(),
      _fetchAnsweredReviews(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  // ✨ 2. API 호출 함수를 '답변 전 리뷰' 조회로 변경
  Future<void> _fetchUnansweredReviews({int? cursorId}) async {
    if (_isFetchingMoreUnanswered) return;
    if (cursorId == null) _hasMoreUnanswered = true;

    setState(() {
      if (cursorId != null) _isFetchingMoreUnanswered = true;
    });

    try {
      final token = await StorageService.getAccessToken();
      if (token == null) throw Exception('Token is missing');
      
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/review/seller/${_fruit.id}/notAnswered').replace(
        queryParameters: {'size': '5', if (cursorId != null) 'cursorId': cursorId.toString()},
      );

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final items = (data['result']['content'] as List).map((i) => ReviewInfo.fromJson(i)).toList();
          setState(() {
            if (cursorId == null) _unansweredReviews = items;
            else _unansweredReviews.addAll(items);
            if (items.length < 5) _hasMoreUnanswered = false;
          });
        }
      } else {
        throw Exception('Failed to fetch unanswered reviews');
      }
    } catch (e) {
      print('Error fetching unanswered reviews: $e');
    } finally {
      if (mounted) setState(() => _isFetchingMoreUnanswered = false);
    }
  }

  // ✨ 3. API 호출 함수를 '답변 완료 리뷰' 조회로 변경
  Future<void> _fetchAnsweredReviews({int? cursorId}) async {
    if (_isFetchingMoreAnswered) return;
    if (cursorId == null) _hasMoreAnswered = true;

    setState(() {
      if (cursorId != null) _isFetchingMoreAnswered = true;
    });

    try {
      final token = await StorageService.getAccessToken();
      if (token == null) throw Exception('Token is missing');

      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/review/seller/${_fruit.id}/answered').replace(
        queryParameters: {'size': '5', if (cursorId != null) 'cursorId': cursorId.toString()},
      );
      
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final items = (data['result']['content'] as List).map((i) => ReviewInfo.fromJson(i)).toList();
          setState(() {
            if (cursorId == null) _answeredReviews = items;
            else _answeredReviews.addAll(items);
            if (items.length < 5) _hasMoreAnswered = false;
          });
        }
      } else {
        throw Exception('Failed to fetch answered reviews');
      }
    } catch (e) {
      print('Error fetching answered reviews: $e');
    } finally {
      if (mounted) setState(() => _isFetchingMoreAnswered = false);
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

    final fruit = ModalRoute.of(context)!.settings.arguments as Fruit;

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
                      '받은 문의',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: _ProductInfoCard(fruit: fruit),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(text: '답변 전'),
                    Tab(text: '답변 완료'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUnansweredReviewsTab(screenWidth), 
                      _buildAnsweredReviewsTab(screenWidth),
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

  Widget _buildUnansweredReviewsTab(double screenWidth) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_unansweredReviews.isEmpty) {
      return const Center(child: Text('답변 전 리뷰가 없습니다.'));
    }
    return ListView.builder(
      controller: _unansweredScrollController,
      padding: EdgeInsets.symmetric(
          horizontal: 0, vertical: 24),
      itemCount:
          1 + _unansweredReviews.length + (_hasMoreUnanswered ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SectionHeader(title: '답변 전', color: Colors.red.shade400),
              ],
            ),
          );
        }
        if (index == _unansweredReviews.length + 1) {
          return const Center(child: CircularProgressIndicator());
        }
        final review = _unansweredReviews[index - 1];
        // ✨ 상세 화면으로 이동하는 로직을 포함한 카드 생성
        return _ReviewItemCard(
            review: review,
            fruit: _fruit,
            onRefresh: _loadInitialData);
      },
    );
  }

  // ✨ 5. '답변 완료 리뷰' 탭 위젯으로 변경
  Widget _buildAnsweredReviewsTab(double screenWidth) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_answeredReviews.isEmpty) {
      return const Center(child: Text('답변 완료된 리뷰가 없습니다.'));
    }
    return ListView.builder(
      controller: _answeredScrollController,
      padding: EdgeInsets.symmetric(
          horizontal: 0, vertical: 24),
      itemCount: 1 + _answeredReviews.length + (_hasMoreAnswered ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SectionHeader(title: '답변 완료', color: Colors.green.shade400),
              ],
            ),
          );
        }
        if (index == _answeredReviews.length + 1) {
          return const Center(child: CircularProgressIndicator());
        }
        final review = _answeredReviews[index - 1];
        // ✨ 상세 화면으로 이동하는 로직을 포함한 카드 생성
        return _ReviewItemCard(
            review: review,
            fruit: _fruit,
            onRefresh: _loadInitialData);
      },
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  final Fruit fruit;
  const _ProductInfoCard({required this.fruit});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fruit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(fruit.brandName ?? '농가 불명', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Text(
                  '${formatter.format(fruit.price)}원 / ${fruit.weight}kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(fruit.squareImageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}

/// '답변 전', '답변 완료' 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

/// 문의/답변 카드
class _ReviewItemCard extends StatelessWidget {
  final ReviewInfo review;
  final Fruit fruit;
  final VoidCallback onRefresh;

  const _ReviewItemCard({
    required this.review,
    required this.fruit,
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
                                  color: i < review.rating ? Colors.amber : Colors.grey.shade300,
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