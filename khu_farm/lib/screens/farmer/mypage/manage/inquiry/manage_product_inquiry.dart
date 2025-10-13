import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/inquiry.dart'; 
import 'package:khu_farm/model/fruit.dart';

import '../../../../../shared/widgets/top_norch_header.dart';

class FarmerManageProductInquiryScreen extends StatefulWidget {
  const FarmerManageProductInquiryScreen({super.key});

  @override
  State<FarmerManageProductInquiryScreen> createState() =>
      _FarmerManageProductInquiryScreenState();
}

class _FarmerManageProductInquiryScreenState extends State<FarmerManageProductInquiryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Fruit _fruit;
  bool _isInitialized = false;
  bool _isLoading = true;

  List<Inquiry> _unansweredInquiries = [];
  final ScrollController _unansweredScrollController = ScrollController();
  bool _isFetchingMoreUnanswered = false;
  bool _hasMoreUnanswered = true;

  List<Inquiry> _answeredInquiries = [];
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
      if (_unansweredInquiries.isNotEmpty) {
        _fetchUnansweredInquiries(cursorId: _unansweredInquiries.last.inquiryId);
      }
    }
  }

  void _onAnsweredScroll() {
    if (_answeredScrollController.position.pixels >= _answeredScrollController.position.maxScrollExtent - 50 &&
        _hasMoreAnswered &&
        !_isFetchingMoreAnswered) {
      if (_answeredInquiries.isNotEmpty) {
        _fetchAnsweredInquiries(cursorId: _answeredInquiries.last.inquiryId);
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchUnansweredInquiries(),
      _fetchAnsweredInquiries(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchUnansweredInquiries({int? cursorId}) async {
    if (_isFetchingMoreUnanswered) return;
    if (cursorId == null) _hasMoreUnanswered = true;

    setState(() {
      if (cursorId != null) _isFetchingMoreUnanswered = true;
    });

    try {
      final token = await StorageService.getAccessToken();
      if (token == null) throw Exception('Token is missing');
      
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/inquiry/seller/${_fruit.id}/notAnswered').replace(
        queryParameters: {'size': '5', if (cursorId != null) 'cursorId': cursorId.toString()},
      );

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final items = (data['result']['content'] as List).map((i) => Inquiry.fromJson(i)).toList();
          setState(() {
            if (cursorId == null) _unansweredInquiries = items;
            else _unansweredInquiries.addAll(items);
            if (items.length < 5) _hasMoreUnanswered = false;
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

  Future<void> _fetchAnsweredInquiries({int? cursorId}) async {
    if (_isFetchingMoreAnswered) return;
    if (cursorId == null) _hasMoreAnswered = true;

    setState(() {
      if (cursorId != null) _isFetchingMoreAnswered = true;
    });

    try {
      final token = await StorageService.getAccessToken();
      if (token == null) throw Exception('Token is missing');

      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/inquiry/seller/${_fruit.id}/answered').replace(
        queryParameters: {'size': '5', if (cursorId != null) 'cursorId': cursorId.toString()},
      );
      
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final items = (data['result']['content'] as List).map((i) => Inquiry.fromJson(i)).toList();
          setState(() {
            if (cursorId == null) _answeredInquiries = items;
            else _answeredInquiries.addAll(items);
            if (items.length < 5) _hasMoreAnswered = false;
          });
        }
      } else {
        throw Exception('Failed to fetch answered inquiries');
      }
    } catch (e) {
      print('Error fetching answered inquiries: $e');
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
          FarmerTopNotchHeader(),

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
                      _buildUnansweredInquiriesTab(screenWidth),
                      _buildAnsweredInquiriesTab(screenWidth),
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

  /// '답변 전' 탭 위젯
  Widget _buildUnansweredInquiriesTab(double screenWidth) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    // ✨ 1. 데이터가 비어있는지 먼저 확인합니다.
    if (_unansweredInquiries.isEmpty) {
      return const Center(child: Text('답변 전 문의가 없습니다.'));
    }

    // 데이터가 있을 경우에만 ListView를 생성합니다.
    return ListView.builder(
      controller: _unansweredScrollController,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      itemCount: 1 + _unansweredInquiries.length + (_hasMoreUnanswered ? 1 : 0),
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
        if (index == _unansweredInquiries.length + 1) {
          return const Center(child: CircularProgressIndicator());
        }
        final inquiry = _unansweredInquiries[index - 1];
        return _InquiryItemCard(
          inquiry: inquiry, 
          fruit: _fruit, 
          onRefresh: _loadInitialData, 
        );
      },
    );
  }

  /// '답변 완료' 탭 위젯
  Widget _buildAnsweredInquiriesTab(double screenWidth) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // ✨ 2. 데이터가 비어있는지 먼저 확인합니다.
    if (_answeredInquiries.isEmpty) {
      return const Center(child: Text('답변 완료된 문의가 없습니다.'));
    }

    // 데이터가 있을 경우에만 ListView를 생성합니다.
    return ListView.builder(
      controller: _answeredScrollController,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      itemCount: 1 + _answeredInquiries.length + (_hasMoreAnswered ? 1 : 0),
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
        if (index == _answeredInquiries.length + 1) {
          return const Center(child: CircularProgressIndicator());
        }
        final inquiry = _answeredInquiries[index - 1];
        return _InquiryItemCard(
          inquiry: inquiry, 
          fruit: _fruit, 
          onRefresh: _loadInitialData,
        );
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
class _InquiryItemCard extends StatelessWidget {
  final Inquiry inquiry;
  final Fruit fruit; // ✨ fruit 객체를 받도록 추가
  final VoidCallback onRefresh;
  const _InquiryItemCard({required this.inquiry, required this.fruit, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // ✨ GestureDetector로 감싸서 탭 이벤트 처리
    return GestureDetector(
      onTap: () async { // ✨ 3. async 추가
        // 상세 화면으로 이동하고, 결과를 기다립니다.
        final result = await Navigator.pushNamed(
          context,
          '/farmer/mypage/manage/inquiry/detail',
          arguments: { 'fruit': fruit, 'inquiry': inquiry },
        );

        // ✨ 4. 상세 화면에서 true를 반환받으면, 새로고침 콜백을 실행합니다.
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Q:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(inquiry.content,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                const Text('더보기 >',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              inquiry.reply != null ? 'A: ${inquiry.reply!.content}' : 'A: 답변 대기중',
              style: TextStyle(
                color: inquiry.reply != null ? Colors.black87 : Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}