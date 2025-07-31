import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/model/review.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/fruit.dart';

class FarmerManageReviewDetailScreen extends StatefulWidget {
  const FarmerManageReviewDetailScreen({super.key});

  @override
  State<FarmerManageReviewDetailScreen> createState() =>
      _FarmerManageReviewDetailScreenState();
}

class _FarmerManageReviewDetailScreenState extends State<FarmerManageReviewDetailScreen>
    with SingleTickerProviderStateMixin {
  late final Fruit _fruit;
  late final ReviewInfo _review;
  bool _isInitialized = false;

  final TextEditingController _replyController = TextEditingController();
  bool _isReplyFieldVisible = false;
  bool _showErrorAnimation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // arguments를 한 번만 초기화하기 위한 플래그
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _review = args['review'] as ReviewInfo;
      print(_review);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("답변 등록 중입니다..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing');

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final uri = Uri.parse('$baseUrl/review/${_review.reviewId}/reply');
      final body = jsonEncode({'content': _replyController.text.trim()});

      final response = await http.post(uri, headers: headers, body: body);

      if (mounted) Navigator.of(context).pop(); // 로딩 모달창 닫기

      if (response.statusCode == 200 || response.statusCode == 201) {
      // ✨ 수정된 부분: 성공 화면으로 이동하고, 결과를 기다림
        final result = await Navigator.pushNamed(
          context,
          '/farmer/mypage/manage/review/reply/success',
        );

        // ✨ 성공 화면에서 '돌아가기'를 눌러 true 값을 받으면,
        // ✨ 현재 상세 화면도 닫으면서 이전 화면에 true를 전달
        if (result == true && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to submit reply: ${response.body}');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // 에러 시에도 로딩 모달창 닫기
      print('Error submitting reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변 등록에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _handleReplyButtonPress() {
    if (!_isReplyFieldVisible) {
      setState(() {
        _isReplyFieldVisible = true;
      });
      return;
    }

    if (_replyController.text.trim().isEmpty) {
      setState(() => _showErrorAnimation = true);
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showErrorAnimation = false);
      });
    } else {
      // ✨ 2. 내용이 있을 경우 API 호출
      _submitReply();
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

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _review.replyContent == null
          ? Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding + 8),
              child: ElevatedButton(
                onPressed: _handleReplyButtonPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('답변하기', style: TextStyle(fontSize: 16)),
              ),
            )
          : null,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset('assets/icons/goback.png', width: 18, height: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text('리뷰 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ✨ 2. 리뷰 카드 위젯으로 UI 재구성
                  _ReviewDetailCard(review: _review),
                  const SizedBox(height: 12),
                  
                  // 답변이 있거나, 답변 필드가 보여야 할 경우
                  if (_review.replyContent != null || _isReplyFieldVisible)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text('판매자 답변', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (_review.replyContent != null)
                            _AnswerCard(replyContent: _review.replyContent!)
                          else if (_isReplyFieldVisible)
                            _ReplyInputCard(
                              controller: _replyController,
                              showError: _showErrorAnimation,
                            ),
                        ],
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

class _ReviewDetailCard extends StatelessWidget {
  final ReviewInfo review;
  const _ReviewDetailCard({required this.review});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(review.createdAt));
    } catch (e) {/* fallback */}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (review.imageUrl.isNotEmpty)
          Image.network(
            review.imageUrl,
            width: double.infinity,
            height: MediaQuery.of(context).size.width, // 정사각형에 가까운 비율
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              height: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.error)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      review.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          color: i < review.rating ? Colors.amber : Colors.grey.shade300,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'ID: ${review.userId}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                review.content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String replyContent;
  const _AnswerCard({required this.replyContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        replyContent,
        style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
      ),
    );
  }
}

class _ReplyInputCard extends StatefulWidget {
  final TextEditingController controller;
  final bool showError;
  const _ReplyInputCard({required this.controller, required this.showError});

  @override
  State<_ReplyInputCard> createState() => _ReplyInputCardState();
}

class _ReplyInputCardState extends State<_ReplyInputCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: const Offset(0, 0), end: const Offset(-0.05, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.05, 0), end: const Offset(0, 0)), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant _ReplyInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // showError가 true로 변경되는 순간에만 애니메이션을 실행
    if (widget.showError && !oldWidget.showError) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✨ SlideTransition으로 TextField를 감싸서 흔들리는 효과 적용
        SlideTransition(
          position: _animation,
          child: TextField(
            controller: widget.controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '내용을 입력해 주세요.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.showError ? Colors.red : Colors.grey.shade300,
                  width: widget.showError ? 2.0 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.showError ? Colors.red : Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}