import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/screens/consumer/mypage/csc/personal_inquiry/personal_inquiry_detail.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/inquiry.dart';
import 'package:khu_farm/screens/consumer/mypage/csc/personal_inquiry/personal_inquiry_detail.dart';
import 'package:khu_farm/services/storage_service.dart';

class ConsumerPersonalInquiryListScreen extends StatefulWidget {
  const ConsumerPersonalInquiryListScreen({super.key});

  @override
  State<ConsumerPersonalInquiryListScreen> createState() =>
      _ConsumerPersonalInquiryListScreenState();
}

class _ConsumerPersonalInquiryListScreenState
    extends State<ConsumerPersonalInquiryListScreen> {
  bool _isLoading = true;
  List<Inquiry> _inquiries = [];

  @override
  void initState() {
    super.initState();
    _fetchMyInquiries();
  }

  // 2. '내 문의 내역' API 호출 함수
  Future<void> _fetchMyInquiries() async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null || !mounted) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/inquiry/myInquiry?size=1000'); //

    try {
      final response = await http.get(uri, headers: headers);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final List<dynamic> itemsJson = data['result']['content'];
          setState(() {
            _inquiries =
                itemsJson.map((json) => Inquiry.fromJson(json)).toList();
          });
        }
      } else {
        print('Failed to load inquiries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching inquiries: $e');
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
    // 상태바, 화면 크기 변수 고정
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // 시스템 UI 투명
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

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
          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: 84, // 버튼 영역 확보
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
                      '1대1 문의',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 내 문의 내역 텍스트 (가로 중앙)
                Center(
                  child: const Text(
                    '내 문의 내역',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _inquiries.isEmpty
                          ? const Center(child: Text('작성된 문의 내역이 없습니다.'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 16),
                              itemCount: _inquiries.length,
                              itemBuilder: (context, index) {
                                final inquiry = _inquiries[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _InquiryCard(inquiry: inquiry),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),

          // ── 하단 버튼 ────────────────────────────
          // Positioned(
          //   left: screenWidth * 0.08,
          //   right: screenWidth * 0.08,
          //   bottom: 20 + MediaQuery.of(context).padding.bottom,
          //   child: SizedBox(
          //     height: 48,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         Navigator.pushNamed(
          //           context,
          //           '/consumer/mypage/inquiry/personal/add',
          //         );
          //       },
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: const Color(0xFF6FCF4B),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30),
          //         ),
          //       ),
          //       child: const Text(
          //         '새 1:1 문의하기',
          //         style: TextStyle(fontSize: 16, color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final Inquiry inquiry;
  const _InquiryCard({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Q: ${inquiry.content}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // inquiryId를 생성자로 전달합니다.
                      builder: (_) => ConsumerPersonalInquiryDetailScreen(
                        inquiryId: inquiry.inquiryId,
                      ),
                    ),
                  );
                },
                child: Text(
                  '더보기 >',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A: ${inquiry.reply?.content ?? '답변대기중'}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}