import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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
  List<ReviewInfo> _unansweredReviews = [];
  List<ReviewInfo> _allReviews = []; // ✨ 전체 리뷰 목록을 담을 리스트

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => _isLoading = true);

    final String? token = await StorageService.getAccessToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      // 답변 전 리뷰와 전체 리뷰 API를 병렬로 호출
      await Future.wait([
        _fetchUnansweredReviews(token),
        _fetchAllReviews(token), // ✨ 전체 리뷰 호출 함수 추가
      ]);
    } catch (e) {
      print('An error occurred during fetch: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // '답변 전' 리뷰를 가져오는 API 호출
  Future<void> _fetchUnansweredReviews(String token) async {
    final headers = {'Authorization': 'Bearer $token'};
    final uri = Uri.parse('$baseUrl/review/seller/notAnswered?size=1000');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> content = data['result']['content'];
      _unansweredReviews = content.map((item) => ReviewInfo.fromJson(item)).toList();
      print("unanswered: $_unansweredReviews");
    } else {
      print('Error fetching unanswered reviews: ${response.statusCode}');
    }
  }

  // ✨ '전체' 리뷰를 가져오는 API 호출
  Future<void> _fetchAllReviews(String token) async {
    final headers = {'Authorization': 'Bearer $token'};
    final uri = Uri.parse('$baseUrl/review/seller/all?size=1000');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> content = data['result']['content'];
      print(data['result']);
      _allReviews = content.map((item) => ReviewInfo.fromJson(item)).toList();
      print("all: $_allReviews");
    } else {
      print('Error fetching all reviews: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                      _buildAllReviewsList(),
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
      padding: EdgeInsets.zero,
      itemCount: _unansweredReviews.length,
      itemBuilder: (context, index) {
        return _ReviewCard(review: _unansweredReviews[index]);
      },
    );
  }

  /// "전체 보기" 탭 UI
  Widget _buildAllReviewsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allReviews.isEmpty) {
      return const Center(child: Text('작성된 리뷰가 없습니다.'));
    }
    // ✨ 전체 리뷰 목록을 `_ReviewCard`를 사용하여 표시
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _allReviews.length,
      itemBuilder: (context, index) {
        return _ReviewCard(review: _allReviews[index]);
      },
    );
  }
}

/// 리뷰 카드 위젯 (답변 표시 기능 추가)
class _ReviewCard extends StatelessWidget {
  final ReviewInfo review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    review.imageUrl,
                    width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 80, height: 80, color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(Icons.star, color: i < review.rating ? Colors.amber : Colors.grey.shade300, size: 16)),
                              const SizedBox(width: 4),
                              Text(review.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
            // ✨ 답변이 있는 경우에만 답변 내용 표시
            if (review.replyContent != null && review.replyContent!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('A. ', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(review.replyContent!, style: TextStyle(color: Colors.grey.shade800)))
                      ],
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}