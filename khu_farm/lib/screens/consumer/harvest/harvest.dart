import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:khu_farm/services/pedometer_service.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/services/storage_service.dart';

class ConsumerHarvestScreen extends StatefulWidget {
  const ConsumerHarvestScreen({super.key});

  @override
  State<ConsumerHarvestScreen> createState() => _ConsumerHarvestScreenState();
}

class _ConsumerHarvestScreenState extends State<ConsumerHarvestScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  UserInfo? _userInfo;
  int _totalPoints = 0;
  int _totalDonation = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    PedometerService().init();
    _loadUserInfo();
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
                  '/consumer/daily',
                  ModalRoute.withName("/consumer/main"),
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
                  '/consumer/laicos',
                  ModalRoute.withName("/consumer/main"),
                );
              },
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/mypage.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/consumer/mypage',
                  ModalRoute.withName("/consumer/main"),
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
                      '/consumer/main',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'KHU:FARM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
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
                          '/consumer/notification/list',
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
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: 출석 기록 로직
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6FCF4B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('출석하기'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: CalendarFormat.month,
                                selectedDayPredicate:
                                    (day) => isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                ),
                                calendarStyle: const CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: Color(0xFF6FCF4B),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: Color(0xFF7AC833),
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
