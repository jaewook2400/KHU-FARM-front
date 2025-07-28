import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/inquiry.dart'; 

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
  List<Inquiry> _allInquiries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ✨ 두 API를 한 번에 호출하도록 수정
    _fetchData();
  }
  
  // ✨ 두 종류의 문의 데이터를 모두 가져오는 통합 함수
  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final String? token = await StorageService.getAccessToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final headers = {'Authorization': 'Bearer $token'};

    try {
      // Future.wait를 사용하여 두 API를 병렬로 호출
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/inquiry/seller/notAnswered?size=1000'), headers: headers),
        http.get(Uri.parse('$baseUrl/inquiry/seller/all?size=1000'), headers: headers),
      ]);

      // 답변 전 문의 처리
      if (responses[0].statusCode == 200) {
        final data = json.decode(utf8.decode(responses[0].bodyBytes));
        final List<dynamic> content = data['result']['content'];
        _unansweredInquiries = content.map((item) => Inquiry.fromJson(item)).toList();
      } else {
        print('Error fetching unanswered inquiries: ${responses[0].statusCode}');
      }

      // 전체 문의 처리
      if (responses[1].statusCode == 200) {
        final data = json.decode(utf8.decode(responses[1].bodyBytes));
        final List<dynamic> content = data['result']['content'];
        _allInquiries = content.map((item) => Inquiry.fromJson(item)).toList();
      } else {
        print('Error fetching all inquiries: ${responses[1].statusCode}');
      }
    } catch (e) {
      print('An error occurred during fetch: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                      _buildAllInquiriesList(),
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
      padding: EdgeInsets.zero,
      itemCount: _unansweredInquiries.length,
      itemBuilder: (context, index) {
        final inquiry = _unansweredInquiries[index];
        return _InquiryCard(inquiry: inquiry);
      },
    );
  }

  /// "전체 보기" 탭을 위한 위젯
  Widget _buildAllInquiriesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_allInquiries.isEmpty) {
      return const Center(child: Text('문의 내역이 없습니다.'));
    }

    return Column(
      children: [
        // 검색 바 (기능은 추후 구현)
        TextField(
          decoration: InputDecoration(
            hintText: '검색하기',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 전체 문의 목록
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _allInquiries.length,
            itemBuilder: (context, index) {
              final inquiry = _allInquiries[index];
              return _InquiryCard(inquiry: inquiry);
            },
          ),
        ),
      ],
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
class _ProductCard extends StatelessWidget {
  final String imagePath, producer, title, price;
  const _ProductCard({
    required this.imagePath,
    required this.producer,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imagePath,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey[200]),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 12,
                child: Text(producer, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2)])),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}