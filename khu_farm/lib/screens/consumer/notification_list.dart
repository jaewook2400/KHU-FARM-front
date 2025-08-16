import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:khu_farm/screens/consumer/notification_detail.dart';
import 'package:khu_farm/model/notification.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart'; // JWT 토큰을 위해 필요
import 'package:khu_farm/screens/consumer/notification_detail.dart';
import 'package:khu_farm/constants.dart';

class ConsumerNotificationListScreen extends StatefulWidget {
  const ConsumerNotificationListScreen({super.key});

  @override
  State<ConsumerNotificationListScreen> createState() =>
      _ConsumerNotificationListScreenState();
}

class _ConsumerNotificationListScreenState
    extends State<ConsumerNotificationListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasMore = true; // 더 불러올 데이터가 있는지 여부
  int? _cursorId; // 다음 페이지를 불러오기 위한 마지막 알림 ID

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // 첫 페이지 데이터 불러오기

    // 스크롤 리스너 추가
    _scrollController.addListener(() {
      // 스크롤이 맨 끝에 도달했고, 로딩 중이 아니며, 더 불러올 데이터가 있을 때
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 3. API 호출 함수
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('로그인 토큰이 없습니다.');

      final headers = {'Authorization': 'Bearer $accessToken'};
      
      final queryParameters = {
        'size': '5',
        if (_cursorId != null) 'cursorId': _cursorId.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/notification').replace(queryParameters: queryParameters);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> content = body['result']['content'];
        final bool isLastPage = body['result']['last'];

        final List<NotificationModel> newNotifications =
            content.map((item) => NotificationModel.fromJson(item)).toList();

        setState(() {
          _notifications.addAll(newNotifications);
          if (newNotifications.isNotEmpty) {
            _cursorId = newNotifications.last.notificationId;
          }
          _hasMore = !isLastPage; // 마지막 페이지이면 _hasMore를 false로 설정
        });
      } else {
        throw Exception('알림 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      // 에러 처리 (예: SnackBar 표시)
      print('Error fetching notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/top_icons/notice_selected_morning.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
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

          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: 20,
            ),
            child: Column(
              children: [
                // ◀ 뒤로가기 + 타이틀
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
                      '알림',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 알림 리스트
                Expanded(
                  child: _isLoading && _notifications.isEmpty
                      ? const Center(child: CircularProgressIndicator()) // 최초 로딩
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _notifications.length + (_hasMore ? 1 : 0), // 로딩 인디케이터 공간
                          itemBuilder: (context, index) {
                            if (index < _notifications.length) {
                              final notification = _notifications[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _NotificationCard(
                                  title: notification.title,
                                  content: notification.content,
                                ),
                              );
                            } else {
                              // 마지막 아이템 이후에는 로딩 인디케이터 표시
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
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

class _NotificationCard extends StatelessWidget {
  final String title;
  final String content;
  const _NotificationCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 더보기
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ConsumerNotificationDetailScreen(
                            title: title,
                            content: content,
                          ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('더보기'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 내용 스니펫
          Text(
            content,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
