import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';


class ConsumerPersonalInquiryDetailScreen extends StatefulWidget {
  final int inquiryId;

  const ConsumerPersonalInquiryDetailScreen({
    super.key,
    required this.inquiryId,
  });

  @override
  State<ConsumerPersonalInquiryDetailScreen> createState() =>
      _ConsumerPersonalInquiryDetailScreenState();
}

class _ConsumerPersonalInquiryDetailScreenState
    extends State<ConsumerPersonalInquiryDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _inquiryDetail;

  @override
  void initState() {
    super.initState();
    _fetchInquiryDetail();
  }

  // 2. inquiryId로 상세 정보를 가져오는 API 호출 함수
  Future<void> _fetchInquiryDetail() async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null || !mounted) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    // API 명세에 따라 엔드포인트 구성
    final uri = Uri.parse('$baseUrl/inquiry/myInquiry/${widget.inquiryId}');

    try {
      final response = await http.get(uri, headers: headers);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          setState(() {
            _inquiryDetail = data['result'];
          });
        }
      } else {
        print('Failed to load inquiry detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching inquiry detail: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 시스템 UI 투명
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final double customHeaderHeight = statusBarHeight + screenHeight * 0.06;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 노치 배경
          // 노치 배경
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
                      '/consumer/main',
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
                    //       '/consumer/notification/list',
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
                        Navigator.pushNamed(context, '/consumer/dib/list');
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
                        Navigator.pushNamed(context, '/consumer/cart/list');
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
            padding: EdgeInsets.only(top: customHeaderHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 뒤로가기 및 타이틀 (스크롤되지 않는 상단 영역)
                Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.08, 20, screenWidth * 0.08, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset('assets/icons/goback.png', width: 18, height: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text('1대1 문의', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. 로딩 및 콘텐츠 표시 (스크롤되는 하단 영역)
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _inquiryDetail == null
                          ? const Center(child: Text('문의 내용을 불러오지 못했습니다.'))
                          : ListView(
                              padding: EdgeInsets.fromLTRB(screenWidth * 0.08, 0, screenWidth * 0.08, 20),
                              children: [
                                _ProductInfoCard(fruitData: _inquiryDetail!['fruitResponse']),
                                const SizedBox(height: 24),
                                _QASection(isQuestion: true, inquiryData: _inquiryDetail!['inquiryResponse']),
                                const SizedBox(height: 16),
                                if (_inquiryDetail!['inquiryResponse']['reply'] != null)
                                  _QASection(isQuestion: false, inquiryData: _inquiryDetail!['inquiryResponse']),
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
}

class _ProductInfoCard extends StatelessWidget {
  final Map<String, dynamic> fruitData;
  const _ProductInfoCard({required this.fruitData});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fruitData['title'] ?? '상품명 없음', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(fruitData['brandName'] ?? '브랜드 없음', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('${formatter.format(fruitData['price'] ?? 0)}원 / ${fruitData['weight'] ?? 0}kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // squareImageUrl이 null일 경우를 대비해 placeholder 이미지 표시
              child: Image.network(
                fruitData['squareImageUrl'] ?? 'https://via.placeholder.com/150',
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset('assets/logo/logo_without_text.png', width: double.infinity, height: 80, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 질문/답변 섹션
class _QASection extends StatelessWidget {
  final bool isQuestion;
  final Map<String, dynamic> inquiryData;

  const _QASection({required this.isQuestion, required this.inquiryData});

  @override
  Widget build(BuildContext context) {
    final content = isQuestion ? inquiryData['content'] : inquiryData['reply']?['content'];
    final date = isQuestion ? inquiryData['createdAt'] : inquiryData['reply']?['createdAt'];
    final author = isQuestion ? null : inquiryData['reply']?['sellerName'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: isQuestion ? null : BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isQuestion ? 'Q' : 'A',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: isQuestion ? Colors.black : Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(content ?? (isQuestion ? '내용 없음' : '답변 대기중'), style: const TextStyle(fontSize: 14))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (author != null) Text(author, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              const Spacer(),
              if (date != null) Text((date as String).split('T').first, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
