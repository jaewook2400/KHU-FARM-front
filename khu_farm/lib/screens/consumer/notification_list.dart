import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:khu_farm/screens/consumer/notification_detail.dart';
import 'package:khu_farm/model/notification.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart'; // JWT 토큰을 위해 필요
import 'package:khu_farm/screens/consumer/notification_detail.dart';
import 'package:khu_farm/constants.dart';

import '../../shared/widgets/top_norch_header.dart';

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
          ConsumerTopNotchHeader(),

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
                                  id: notification.notificationId.toString(),
                                ),
                              );
                            } else {
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
  final String id;
  const _NotificationCard({required this.title, required this.content, required this.id});

  _readNotification(BuildContext context) async {
    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');
      final headers = {'Authorization': 'Bearer $accessToken'};
      // 2. API 요청 준비 (GET 쿼리 파라미터 구성)
      final url = '$baseUrl/notification/$id';

      // 3. API 호출
      final response = await http.get(Uri.parse(url), headers: headers);

      // 5. 결과 처리
      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위해 utf8로 디코딩
        print('nofification API 성공!: ${response.statusCode}');
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        // 서버에서 내려주는 기본 구조 확인
        if (decodedBody['isSuccess'] == true &&
            decodedBody['result'] != null) {
          final result = decodedBody['result'];

          // 4. result 값 점검
          final notificationId = result['notificationId'];
          final title = result['title'];
          final content = result['content'];

          if (notificationId != null && title != null && content != null) {
            // 5. 정상 → 상세 화면 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConsumerNotificationDetailScreen(
                  title: title,
                  content: content,
                ),
              ),
            );
          } else {
            print('API 응답에 필수 값이 없습니다.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('알림 데이터를 불러올 수 없습니다.')),
            );
          }
        } else {
          print('API 응답이 실패 상태입니다.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('알림 요청이 실패했습니다.')),
          );
        }
      } else {
        print('Notification API Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Notification Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
    }
  }

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
                onPressed: () async {

                  _readNotification(context);

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder:
                  //         (_) => ConsumerNotificationDetailScreen(
                  //           title: title,
                  //           content: content,
                  //         ),
                  //   ),
                  // );
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
