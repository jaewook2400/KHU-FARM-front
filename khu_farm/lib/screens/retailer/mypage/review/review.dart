import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/review.dart'; // 새로 만든 Review 모델 임포트
import 'package:khu_farm/services/storage_service.dart';
import 'package:http/http.dart' as http;

class RetailerReviewListScreen extends StatefulWidget {
  const RetailerReviewListScreen({super.key});

  @override
  State<RetailerReviewListScreen> createState() =>
      _RetailerReviewListScreenState();
}

class _RetailerReviewListScreenState extends State<RetailerReviewListScreen> {
  bool _isLoading = true;
  List<Review> _reviews = []; // 상태 변수를 Review 모델 리스트로 변경

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
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
      if (_reviews.isNotEmpty) {
        // 마지막 리뷰의 reviewId를 cursor로 사용
        _fetchMyReviews(cursorId: _reviews.last.reviewResponse.reviewId);
      }
    }
  }

  // '내 리뷰 목록' API 호출 함수
  Future<void> _fetchMyReviews({int? cursorId}) async {
    if (_isFetchingMore) return;

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMore = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing');
      
      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/review/retrieve/my').replace(queryParameters: {
        'size': '10',
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final List<dynamic> itemsJson = data['result']['content'];
          final newReviews = itemsJson.map((json) => Review.fromJson(json)).toList();

          if (mounted) {
            setState(() {
              if (cursorId == null) {
                _reviews = newReviews;
              } else {
                _reviews.addAll(newReviews);
              }
              if (newReviews.length < 10) {
                _hasMore = false;
              }
            });
          }
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
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
          // 노치 배경 및 상단바 (기존과 동일)
          Positioned(
            top: 0, left: 0, right: 0,
            height: statusBarHeight + screenHeight * 0.06,
            child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 0, right: 0,
            height: statusBarHeight * 1.2,
            child: Image.asset('assets/notch/morning_right_up_cloud.png', fit: BoxFit.cover, alignment: Alignment.topRight),
          ),
          Positioned(
            top: statusBarHeight, left: 0,
            height: screenHeight * 0.06,
            child: Image.asset('assets/notch/morning_left_down_cloud.png', fit: BoxFit.cover, alignment: Alignment.topRight),
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
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/retailer/main', (route) => false),
                  child: const Text('KHU:FARM', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'LogoFont', fontSize: 22, color: Colors.white)),
                ),
                Row(
                  children: [
                    // GestureDetector(onTap: () => Navigator.pushNamed(context, '/retailer/notification/list'), child: Image.asset('assets/top_icons/notice.png', width: 24, height: 24)),
                    const SizedBox(width: 12),
                    GestureDetector(onTap: () => Navigator.pushNamed(context, '/retailer/dib/list'), child: Image.asset('assets/top_icons/dibs.png', width: 24, height: 24)),
                    const SizedBox(width: 12),
                    GestureDetector(onTap: () => Navigator.pushNamed(context, '/retailer/cart/list'), child: Image.asset('assets/top_icons/cart.png', width: 24, height: 24)),
                  ],
                ),
              ],
            ),
          ),

          // 콘텐츠 영역
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight + screenHeight * 0.06),
            child: Column(
              children: [
                // 뒤로가기 및 타이틀
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset('assets/icons/goback.png', width: 18, height: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text('작성한 리뷰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                // 리뷰 목록
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _reviews.isEmpty
                          ? const Center(child: Text('작성한 리뷰가 없습니다.'))
                          // ✨ 5. ListView.builder 수정
                          : ListView.builder(
                              controller: _scrollController, // 컨트롤러 연결
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                              itemCount: _reviews.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _reviews.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return _ReviewItem(review: _reviews[index]);
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
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final fruit = review.fruitResponse;
    final reviewInfo = review.reviewResponse;

    String formattedDate = '';
    try {
      formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(reviewInfo.createdAt));
    } catch (e) {
      formattedDate = reviewInfo.createdAt;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          // 날짜 및 개수
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('1개', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          // 1. 상품 정보 카드
          Container(
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
                      Text(fruit.brandName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      const Text('1박스', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('${formatter.format(fruit.price)}원 / ${fruit.weight}kg', style: const TextStyle(fontWeight: FontWeight.bold)),
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
          ),

          const SizedBox(height: 4),
          
          // 2. 리뷰 내용 카드 (상품 정보 카드와 분리)
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    reviewInfo.imageUrl,
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(reviewInfo.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis)),
                          _buildRatingStars(reviewInfo.rating.toDouble()),
                          Text(reviewInfo.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(reviewInfo.content,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 별점 표시 위젯
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.red, size: 16);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.red, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.red, size: 16);
        }
      }),
    );
  }
}