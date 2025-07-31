import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/inquiry.dart'; 
import 'package:khu_farm/model/fruit.dart';

class FarmerManageInquiryDetailScreen extends StatefulWidget {
  const FarmerManageInquiryDetailScreen({super.key});

  @override
  State<FarmerManageInquiryDetailScreen> createState() =>
      _FarmerManageInquiryDetailScreenState();
}

class _FarmerManageInquiryDetailScreenState extends State<FarmerManageInquiryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final Fruit _fruit;
  late final Inquiry _inquiry;
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
      _fruit = args['fruit'] as Fruit;
      _inquiry = args['inquiry'] as Inquiry;
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
      final uri = Uri.parse('$baseUrl/inquiry/${_inquiry.inquiryId}/reply');
      final body = jsonEncode({'content': _replyController.text.trim()});

      final response = await http.post(uri, headers: headers, body: body);

      if (mounted) Navigator.of(context).pop(); // 로딩 모달창 닫기

      if (response.statusCode == 200 || response.statusCode == 201) {
      // ✨ 수정된 부분: 성공 화면으로 이동하고, 결과를 기다림
        final result = await Navigator.pushNamed(
          context,
          '/farmer/mypage/manage/inquiry/reply/success',
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
    final fruit = args['fruit'] as Fruit;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _inquiry.reply == null
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
                _ProductInfoCard(fruit: _fruit),
                const SizedBox(height: 24),
                _QuestionCard(inquiry: _inquiry),
                const SizedBox(height: 12),
                
                // 답변이 있으면 답변 카드를, 없으면 답변 입력 필드를 (조건부로) 표시
                if (_inquiry.reply != null)
                  _AnswerCard(reply: _inquiry.reply!)
                else if (_isReplyFieldVisible)
                  _ReplyInputCard(
                    controller: _replyController,
                    showError: _showErrorAnimation,
                  ),
              ],
            ),
          )
        ],
      ),
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
                Text(fruit.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(fruit.brandName ?? '농가 불명',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
            child: Image.network(fruit.squareImageUrl,
                width: 80, height: 80, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Inquiry inquiry;
  const _QuestionCard({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(inquiry.createdAt));
    } catch (e) {/* fallback */}
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Q :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(child: Text(inquiry.content, style: const TextStyle(fontSize: 16))),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final InquiryReply reply;
  const _AnswerCard({required this.reply});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(reply.createdAt));
    } catch (e) {/* fallback */}

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('A :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(width: 8),
              Expanded(child: Text(reply.content, style: TextStyle(fontSize: 16, color: Colors.grey[800]))),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${reply.sellerName} | $formattedDate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
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
        const SizedBox(height: 32),
        const Text('판매자 답변', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
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