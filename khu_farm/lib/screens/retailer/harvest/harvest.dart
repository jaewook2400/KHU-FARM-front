import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:khu_farm/services/pedometer_service.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';

class RetailerHarvestScreen extends StatefulWidget {
  const RetailerHarvestScreen({super.key});

  @override
  State<RetailerHarvestScreen> createState() => _RetailerHarvestScreenState();
}

class _RetailerHarvestScreenState extends State<RetailerHarvestScreen> {
  DateTime _focusedDay = DateTime.now();

  UserInfo? _userInfo;
  int _totalPoints = 0;
  int _totalDonation = 0;

  final Set<DateTime> _attendedDays = {};
  bool _isCalendarLoading = true;
  bool _isAttending = false;
  bool _hasAttendedToday = false; 

  @override
  void initState() {
    super.initState();
    _requestPermissionAndInitPedometer();
    _loadUserInfo();
    _fetchAttendance(_focusedDay);
  }

  void _showAttendanceSuccessDialog(int points) {
    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 영역을 탭해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 250, // 모달의 높이
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  '${points}point를 받았습니다.',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none, // Stack 밖으로 이미지가 나갈 수 있도록 설정
                  alignment: Alignment.center,
                  children: [
                    // '닫기' 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 모달 닫기
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FCF4B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('닫기', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    // 마스코트 이미지
                    Positioned(
                      bottom: 25, // 버튼 위로 살짝 올라오도록 위치 조정
                      child: Image.asset(
                        'assets/mascot/main_mascot.png', // TODO: 실제 마스코트 이미지 경로 확인
                        height: 80,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAttendance() async {
    setState(() => _isAttending = true);

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      setState(() => _isAttending = false);
      return;
    }

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/point/attend');

    try {
      final response = await http.post(uri, headers: headers);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        _showAttendanceSuccessDialog(10); 
        
        // 1. 달력 정보 새로고침
        await _fetchAttendance(_focusedDay);
        // 2. 유저 포인트/기부금 정보 새로고침
        await _updateUserValues();

      } else {
        // 이미 출석했거나 다른 에러 발생 시
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? '출석 처리 중 오류가 발생했습니다.')));
      }
    } catch (e) {
      print('Failed to attend: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('네트워크 오류가 발생했습니다.')));
    } finally {
      if(mounted) setState(() => _isAttending = false);
    }
  }

  // ✨ 유저의 포인트, 기부금 정보를 새로 가져오는 함수
  Future<void> _updateUserValues() async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/users/value');

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final result = data['result'];
          if (mounted) {
            setState(() {
              _totalPoints = result['totalPoint'];
              _totalDonation = result['totalDonation'];
            });
            // Storage의 UserInfo도 업데이트 (선택사항이지만 권장)
            if (_userInfo != null) {
              final updatedUserInfo = _userInfo!.copyWith(
                totalPoint: result['totalPoint'],
                totalDonation: result['totalDonation'],
              );
              await StorageService().saveUserInfo(updatedUserInfo);
            }
          }
        }
      }
    } catch (e) {
      print('Failed to update user values: $e');
    }
  }

  Future<void> _fetchAttendance(DateTime date) async {
    setState(() {
      _isCalendarLoading = true;
    });

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/point/attend/${date.year}/${date.month}');

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> history = data['result']['attendanceHistoryResponses'];
          _attendedDays.clear();
          for (var item in history) {
            _attendedDays.add(DateTime.utc(item['year'], item['month'], item['day']));
          }

          // ✨ 출석 데이터를 불러온 후 오늘 출석했는지 확인
          final now = DateTime.now();
          final today = DateTime.utc(now.year, now.month, now.day);
          _hasAttendedToday = _attendedDays.contains(today);
        }
      }
    } catch (e) {
      print('Failed to fetch attendance: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCalendarLoading = false;
        });
      }
    }
  }


  Future<void> _requestPermissionAndInitPedometer() async {
    // 1. 신체 활동 권한을 요청합니다.
    PermissionStatus status = await Permission.activityRecognition.request();

    // 2. 권한이 허용되었는지 확인합니다.
    if (status.isGranted) {
      print("[HarvestScreen] 신체 활동 권한이 허용되었습니다.");
      // 권한이 있으면 만보기 서비스를 초기화합니다.
      PedometerService().init();
    } else {
      print("[HarvestScreen] 신체 활동 권한이 거부되었습니다.");
    }
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await StorageService().getUserInfo();
    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
        _totalPoints = userInfo.totalPoint;
        _totalDonation = userInfo.totalDonation;
      });
    }
  }

  int _calculateLevel(int points) {
    if (points < 0) return 1;
    return (points / 100).floor() + 1;
  }

  /// 레벨에 맞는 이름을 반환합니다.
  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return '씨앗';
      case 2:
        return '줄기';
      default:
        return '열매';
    }
  }
  
  String _getLevelImagePath(int level) {
    switch (level) {
      case 1:
        return 'assets/harvest/seed.png';
      case 2:
        return 'assets/harvest/stem.png';
      case 3:
      default: // For level 3 and above
        return 'assets/harvest/fruit.png';
    }
  }

  /// 현재 레벨의 진행도를 0.0 ~ 1.0 사이의 값으로 계산합니다.
  double _calculateProgress(int points) {
    if (points < 0) return 0.0;
    return (points % 100) / 100.0;
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

    final int currentLevel = _calculateLevel(_totalPoints);
    final String levelName = _getLevelName(currentLevel);
    final double progressValue = _calculateProgress(_totalPoints);
    final String levelImagePath = _getLevelImagePath(currentLevel); 

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,

      bottomNavigationBar: Container(
        color: const Color(0xFFB6832B),
        padding: EdgeInsets.only(
          // top: 20,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/daily.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/daily',
                  ModalRoute.withName("/retailer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/stock.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/stock',
                  ModalRoute.withName("/retailer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/select/harvest.png',
              onTap: () {},
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/laicos.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/laicos',
                  ModalRoute.withName("/retailer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/mypage.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/mypage',
                  ModalRoute.withName("/retailer/main"),
                );
              },
            ),
          ],
        ),
      ),

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
                      '/retailer/main',
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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/retailer/notification/list',
                        );
                      },
                      child: Image.asset(
                        'assets/top_icons/notice.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/retailer/dib/list');
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
                        Navigator.pushNamed(context, '/retailer/cart/list');
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

          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: 0,
            child: DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 레벨 & 이름
                  Text(
                    'Lv.$currentLevel', // 동적으로 레벨 표시
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    levelName, // 동적으로 이름 표시
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // 진행바 & 포인트
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue, // 동적으로 진행도 표시
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF6FCF4B)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_totalPoints}point',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  // --- 여기까지 ---
                  const SizedBox(height: 16),

                  // 탭바
                  TabBar(
                    labelColor: Color(0xFF6FCF4B),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF6FCF4B),
                    tabs: const [
                      Tab(text: '만보기'),
                      Tab(text: '출석체크'),
                      Tab(text: '리뷰'),
                    ],
                  ),

                  // 탭뷰
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 만보기
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            StreamBuilder<int>(
                              stream: PedometerService().stepCountStream, // 서비스의 스트림을 구독
                              builder: (context, snapshot) {
                                // 데이터 상태에 따라 다른 UI 표시
                                print('[StreamBuilder] ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, HasError: ${snapshot.hasError}');

                                String steps = '0';
                                if (snapshot.hasError) {
                                  steps = '측정 불가';
                                } else if (snapshot.hasData) {
                                  steps = snapshot.data.toString();
                                }

                                return RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 18, color: Colors.black),
                                    children: [
                                      const TextSpan(text: '오늘은 총 '),
                                      TextSpan(
                                        text: steps,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                      const TextSpan(text: '보 걸었습니다.'),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                // --- This line is updated ---
                                levelImagePath, // Use the dynamic image path
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),

                        // 출석체크
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isAttending || _hasAttendedToday ? null : _handleAttendance,
                                // ✨ 버튼 스타일을 디자인 시안에 맞게 수정
                                style: ButtonStyle(
                                  // 버튼 상태에 따라 배경색 변경
                                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return Colors.white; // 비활성화 상태: 흰색
                                    }
                                    return const Color(0xFF6FCF4B); // 활성화 상태: 초록색
                                  }),
                                  // 버튼 상태에 따라 글자/아이콘 색상 변경
                                  foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return Colors.grey; // 비활성화 상태: 회색
                                    }
                                    return Colors.white; // 활성화 상태: 흰색
                                  }),
                                  // 비활성화 상태일 때만 테두리 추가
                                  side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return BorderSide(color: Colors.grey.shade300, width: 1);
                                    }
                                    return BorderSide.none;
                                  }),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  elevation: MaterialStateProperty.resolveWith<double>((states){
                                    if (states.contains(MaterialState.disabled)) return 0;
                                    return 2; // 활성화 상태일 때 약간의 그림자
                                  }),
                                ),
                                child: _isAttending
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                      )
                                    : Text(_hasAttendedToday ? '오늘의 포인트 수령 완료' : '출석하기'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              // ✨ 5. TableCalendar 위젯 수정
                              child: _isCalendarLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : TableCalendar(
                                      firstDay: DateTime.utc(2020, 1, 1),
                                      lastDay: DateTime.utc(2030, 12, 31),
                                      focusedDay: _focusedDay,
                                      calendarFormat: CalendarFormat.month,
                                      
                                      // 사용자가 날짜를 직접 선택할 수 없도록 onDaySelected를 비워둡니다.
                                      onDaySelected: (selectedDay, focusedDay) {},

                                      // 달력이 넘어갈 때마다 해당 월의 출석 데이터를 새로 불러옵니다.
                                      onPageChanged: (focusedDay) {
                                        setState(() {
                                          _focusedDay = focusedDay;
                                        });
                                        _fetchAttendance(focusedDay);
                                      },
                                      
                                      // _attendedDays에 포함된 날짜에만 선택된 스타일을 적용합니다.
                                      selectedDayPredicate: (day) {
                                        return _attendedDays.contains(day);
                                      },

                                      headerStyle: const HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                      ),
                                      calendarStyle: const CalendarStyle(
                                        // 오늘 날짜 스타일
                                        todayDecoration: BoxDecoration(
                                          color: Color(0xFFC8E6C9), // 연한 초록색
                                          shape: BoxShape.circle,
                                        ),
                                        // 출석한 날짜(선택된 날짜) 스타일
                                        selectedDecoration: BoxDecoration(
                                          color: Color(0xFF6FCF4B), // 진한 초록색
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        // 리뷰
                        SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 90),
                          child: Column(
                            children: const [
                              ReviewCard(
                                imagePath: 'assets/mascot/login_mascot.png',
                                title: '제품제목',
                                rating: 5.0,
                                content: '너무너무너무내용내용내용내용내용내용내용내용내용내용...',
                                claimed: false,
                              ),
                              SizedBox(height: 12),
                              ReviewCard(
                                imagePath: 'assets/mascot/login_mascot.png',
                                title: '제품제목',
                                rating: 5.0,
                                content: '너무너무너무내용내용내용내용내용내용내용내용내용내용...',
                                claimed: true,
                              ),
                              SizedBox(height: 12),
                              ReviewCard(
                                imagePath: 'assets/mascot/login_mascot.png',
                                title: '제품제목',
                                rating: 5.0,
                                content: '너무너무너무내용내용내용내용내용내용내용내용내용내용...',
                                claimed: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: Container(
              color: const Color(0xFF7AC833),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:  [
                  Text(
                    '내가 기부한 금액',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$_totalDonation 원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _NavItem({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.15;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Image.asset(iconPath, width: size, height: size)],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final double rating;
  final String content;
  final bool claimed;

  const ReviewCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.rating,
    required this.content,
    required this.claimed,
  });

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
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: claimed ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    claimed ? Colors.grey : const Color(0xFF6FCF4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                claimed ? '포인트 수령 완료' : '2point 받기',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
