import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/screens/product_detail.dart';
import 'package:khu_farm/screens/chatbot.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/model/farm.dart';

class RetailerStockScreen extends StatefulWidget {
  const RetailerStockScreen({super.key});

  @override
  State<RetailerStockScreen> createState () => _RetailerStockScreenState();
}

class _RetailerStockScreenState extends State<RetailerStockScreen> {
  List<Fruit> _fruits = [];
  final ScrollController _fruitScrollController = ScrollController();
  bool _isFetchingMoreFruits = false;
  bool _hasMoreFruits = true;
  String? _currentFruitSearchKeyword;
  late final TextEditingController _searchFruitController;

  // 농가 목록 상태
  List<Farm> _farms = [];
  final ScrollController _farmScrollController = ScrollController();
  bool _isFetchingMoreFarms = false;
  bool _hasMoreFarms = true;
  String? _currentFarmSearchKeyword;
  late final TextEditingController _searchFarmController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchFruitController = TextEditingController();
    _searchFarmController = TextEditingController();
    
    _fruitScrollController.addListener(_onFruitScroll);
    _farmScrollController.addListener(_onFarmScroll);

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchFruits(),
      _fetchFarms(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  void _onFruitScroll() {
    if (_fruitScrollController.position.pixels >= _fruitScrollController.position.maxScrollExtent - 50 &&
        _hasMoreFruits &&
        !_isFetchingMoreFruits) {
      final cursorId = _fruits.isNotEmpty ? _fruits.last.id : null;
      if (cursorId == null) return;

      if (_currentFruitSearchKeyword != null && _currentFruitSearchKeyword!.isNotEmpty) {
        _searchFruits(_currentFruitSearchKeyword!, cursorId: cursorId);
      } else {
        _fetchFruits(cursorId: cursorId);
      }
    }
  }

  void _onFarmScroll() {
    if (_farmScrollController.position.pixels >= _farmScrollController.position.maxScrollExtent - 50 &&
        _hasMoreFarms &&
        !_isFetchingMoreFarms) {
      final cursorId = _farms.isNotEmpty ? _farms.last.id : null;
      if (cursorId == null) return;
      
      if (_currentFarmSearchKeyword != null && _currentFarmSearchKeyword!.isNotEmpty) {
        _searchFarms(_currentFarmSearchKeyword!, cursorId: cursorId);
      } else {
        _fetchFarms(cursorId: cursorId);
      }
    }
  }


  Future<void> _fetchFruits({int? cursorId}) async {
    if (_isFetchingMoreFruits) return;
    
    if (cursorId == null) {
      _currentFruitSearchKeyword = null;
      _searchFruitController.clear();
      _hasMoreFruits = true;
    }

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMoreFruits = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');
      final headers = {'Authorization': 'Bearer $accessToken'};
      
      // ✨ wholesaleRetailCategoryId를 1로 설정
      String url = '$baseUrl/fruits/get/1?size=5';
      if (cursorId != null) url += '&cursorId=$cursorId';

      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final newFruits = (data['result']['content'] as List)
            .map((json) => Fruit.fromJson(json))
            .toList();

        setState(() {
          if (cursorId == null) {
            _fruits = newFruits;
          } else {
            _fruits.addAll(newFruits);
          }
          if (newFruits.length < 5) {
            _hasMoreFruits = false;
          }
        });
      } else {
        throw Exception('Failed to load fruits');
      }
    } catch (e) {
      print('An error occurred in _fetchFruits: $e');
    } finally {
      if (mounted) setState(() {
        if (cursorId == null) _isLoading = false;
        _isFetchingMoreFruits = false;
      });
    }
  }

  Future<void> _searchFruits(String keyword, {int? cursorId}) async {
    if (_isFetchingMoreFruits) return;

    if (cursorId == null) {
      _fruits.clear();
      _currentFruitSearchKeyword = keyword;
      _hasMoreFruits = true;
    }

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMoreFruits = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');
      
      final headers = {'Authorization': 'Bearer $accessToken'};
      
      // ✨ wholesaleRetailCategoryId를 1로 설정
      final uri = Uri.parse('$baseUrl/fruits/search/1').replace(
        queryParameters: {
          'searchKeyword': keyword,
          'size': '5',
          if (cursorId != null) 'cursorId': cursorId.toString(),
        },
      );
      
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final newFruits = (data['result']['content'] as List)
            .map((json) => Fruit.fromJson(json))
            .toList();

        setState(() {
          _fruits.addAll(newFruits);
          if (newFruits.length < 5) {
            _hasMoreFruits = false;
          }
        });
      } else {
        throw Exception('Failed to search fruits');
      }
    } catch (e) {
      print('An error occurred during search: $e');
    } finally {
      if(mounted) setState(() {
        if(cursorId == null) _isLoading = false;
        _isFetchingMoreFruits = false;
      });
    }
  }

  Future<void> _fetchFarms({int? cursorId}) async {
    if (_isFetchingMoreFarms) return;

    if (cursorId == null) {
      _currentFarmSearchKeyword = null;
      _searchFarmController.clear();
      _hasMoreFarms = true;
    }

    setState(() {
      if (cursorId != null) _isFetchingMoreFarms = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');
      
      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/seller').replace(queryParameters: {
        'size': '5',
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });
      
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final newFarms = (data['result']['content'] as List)
            .map((json) => Farm.fromJson(json))
            .toList();
        
        setState(() {
          if (cursorId == null) {
            _farms = newFarms;
          } else {
            _farms.addAll(newFarms);
          }
          if (newFarms.length < 5) {
            _hasMoreFarms = false;
          }
        });
      } else {
        throw Exception('Failed to load farms');
      }
    } catch (e) {
      print('An error occurred during farm fetch: $e');
    } finally {
      if (mounted) setState(() => _isFetchingMoreFarms = false);
    }
  }

  // ✨ 4. 농가 검색 함수에 페이지네이션 적용
  Future<void> _searchFarms(String keyword, {int? cursorId}) async {
    if (_isFetchingMoreFarms) return;

    if (cursorId == null) {
      _farms.clear();
      _currentFarmSearchKeyword = keyword;
      _hasMoreFarms = true;
    }

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMoreFarms = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');

      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/seller/search').replace(queryParameters: {
        'searchKeyword': keyword,
        'size': '5',
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final newFarms = (data['result']['content'] as List)
            .map((json) => Farm.fromJson(json))
            .toList();
        
        setState(() {
          _farms.addAll(newFarms);
          if (newFarms.length < 5) {
            _hasMoreFarms = false;
          }
        });
      } else {
        throw Exception('Failed to search farms');
      }
    } catch (e) {
      print('An error occurred during farm search: $e');
    } finally {
      if (mounted) {
        if (cursorId == null) _isLoading = false;
        _isFetchingMoreFarms = false;
      }
    }
  }

  Future<void> _addToWishlist(int fruitId) async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/wishList/$fruitId/add');

    try {
      final response = await http.post(uri, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // API 성공 시, 응답에서 새로운 wishListId를 파싱
        final data = json.decode(utf8.decode(response.bodyBytes));
        final newWishListId = data['result'] as int;

        // 로컬 _fruits 리스트에서 해당 과일을 찾아 상태 업데이트
        setState(() {
          final index = _fruits.indexWhere((fruit) => fruit.id == fruitId);
          if (index != -1) {
            _fruits[index] = _fruits[index].copyWith(
              isWishList: true,
              wishListId: newWishListId,
            );
          }
        });
        print('찜 추가 성공 (로컬 업데이트)');
      } else {
        print('찜 추가 실패: ${response.statusCode}');
        print('Response Body: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('찜 추가 에러: $e');
    }
  }

  Future<void> _removeFromWishlist(int wishListId) async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/wishList/$wishListId/delete');

    try {
      final response = await http.delete(uri, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 204) {
        // API 성공 시, 로컬 _fruits 리스트에서 해당 과일을 찾아 상태 업데이트
        setState(() {
          final index = _fruits.indexWhere((fruit) => fruit.wishListId == wishListId);
          if (index != -1) {
            _fruits[index] = _fruits[index].copyWith(
              isWishList: false,
              wishListId: -1, // 기본값으로 초기화
            );
          }
        });
        print('찜 삭제 성공 (로컬 업데이트)');
      } else {
        print('찜 삭제 실패: ${response.statusCode}');
        print('Response Body: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('찜 삭제 에러: $e');
    }
  }

  @override
  void dispose() {
    _fruitScrollController.removeListener(_onFruitScroll);
    _fruitScrollController.dispose();
    _farmScrollController.removeListener(_onFarmScroll);
    _farmScrollController.dispose();
    _searchFruitController.dispose();
    _searchFarmController.dispose();
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
              iconPath: 'assets/bottom_navigator/select/stock.png',
              onTap: () {},
            ),
            _NavItem(
              iconPath: 'assets/bottom_navigator/unselect/harvest.png',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/retailer/harvest',
                  ModalRoute.withName("/retailer/main"),
                );
              },
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
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       '/retailer/notification/list',
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
                      onTap: () async {
                        // 찜 화면으로 이동하고, 돌아올 때까지 기다립니다.
                        await Navigator.pushNamed(
                          context,
                          '/retailer/dib/list',
                        );
                        // 찜 화면에서 돌아온 후 목록을 새로고침합니다.
                        _fetchFruits();
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
                        Navigator.pushNamed(
                          context,
                          '/retailer/cart/list',
                        );
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
            top: statusBarHeight + screenHeight * 0.06 + 16,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: 0, // 하단 내비바 높이
            child: DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 탭바
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: const [Tab(text: '과일별'), Tab(text: '농가별')],
                  ),
                  const SizedBox(height: 16),

                  // 탭뷰: Expanded로 감싸기
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 과일별 탭
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (var category in fruitsCategory)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/retailer/stock/fruit',
                                        arguments: {
                                          // category 맵에서 fruitId를 가져옵니다.
                                          'fruitId': category['fruitId'],
                                          // wholesale 값은 1로 고정합니다.
                                          'wholesale': 1,
                                        },
                                      );
                                    },
                                    child: _CategoryIcon(
                                      // category 맵에서 icon 경로를 가져옵니다.
                                      iconPath: category['fruitIcon'] as String,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchFruitController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  hintText: '검색하기',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _searchFruits(value);
                                  } else {
                                    _fetchFruits(); // 검색어가 없으면 전체 목록 다시 로드
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : _fruits.isEmpty
                                      ? const Center(child: Text('해당 과일이 없습니다.'))
                                      : ListView.builder(
                                          controller: _fruitScrollController, // ✨ 컨트롤러 연결
                                          itemCount: _fruits.length + (_hasMoreFruits ? 1 : 0), // ✨ 아이템 카운트 수정
                                          itemBuilder: (context, index) {
                                            if (index == _fruits.length) {
                                              return const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Center(child: CircularProgressIndicator()),
                                              );
                                            }
                                            final fruit = _fruits[index];
                                            return _buildProductItem(context, fruit: fruit);
                                          },
                                        ),
                            ),
                          ],
                        ),

                        // 농가별 탭
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 검색 필드
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchFarmController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  hintText: '검색하기',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _searchFarms(value);
                                  } else {
                                    _fetchFarms(); // 검색어가 없으면 전체 목록 다시 로드
                                  }
                                },
                              ),
                            ),
                            // 농가 리스트
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : _farms.isEmpty
                                      ? const Center(child: Text('해당 농가가 없습니다.'))
                                      : ListView.builder(
                                          controller: _farmScrollController, // ✨ 컨트롤러 연결
                                          itemCount: _farms.length + (_hasMoreFarms ? 1 : 0), // ✨ 아이템 카운트 수정
                                          itemBuilder: (context, index) {
                                            if (index == _farms.length) {
                                              return const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Center(child: CircularProgressIndicator()),
                                              );
                                            }
                                            final farm = _farms[index];
                                            return _FarmItem(
                                              imagePath: farm.imageUrl,
                                              producer: farm.brandName,
                                              subtitle: farm.description,
                                            );
                                          },
                                        ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 채팅 모달 버튼 (고정)
          // Positioned(
          //   bottom: screenWidth * 0.02,
          //   right: screenWidth * 0.02,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.white,
          //       border: Border.all(color: Colors.grey.shade300),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 4,
          //           offset: const Offset(0, 2),
          //         ),
          //       ],
          //     ),
          //     child: GestureDetector(
          //       onTap: () {
          //         showChatbotModal(context);
          //       },
          //       child: Image.asset(
          //         'assets/chat/chatbot_icon.png',
          //         width: 68,
          //         height: 68,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, {required Fruit fruit}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(fruit: fruit),
          ),
        );
      },
      child: _ProductItem(
        imagePath: fruit.widthImageUrl,
        producer: fruit.brandName ?? '알 수 없음',
        title: fruit.title,
        price: fruit.price,
        unit: fruit.weight,
        liked: fruit.isWishList, // isWishList 대신 fruit 모델의 liked 사용
        onLikeToggle: () {
          // liked 상태에 따라 다른 API 호출
          if (fruit.isWishList) {
            _removeFromWishlist(fruit.wishListId);
          } else {
            _addToWishlist(fruit.id);
          }
        },
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

class _CategoryIcon extends StatelessWidget {
  final String iconPath;
  const _CategoryIcon({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Image.asset(iconPath, width: 48, height: 48)]);
  }
}

class _ProductItem extends StatelessWidget {
  final String imagePath;
  final String producer;
  final String title;
  final int price;
  final int unit;
  final bool liked;
  final VoidCallback onLikeToggle;

  const _ProductItem({
    required this.imagePath,
    required this.producer,
    required this.title,
    required this.price,
    required this.unit,
    required this.liked,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imagePath,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/mascot/main_mascot.png',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onLikeToggle, // 탭 시 콜백 함수 호출
                  child: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : Colors.white,
                    size: 28, // 아이콘 크기 약간 키움
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    producer,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Text(
                  '$price원',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' / $unit' 'kg',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmItem extends StatelessWidget {
  final String imagePath;
  final String producer;
  final String subtitle;
  final bool liked;

  const _FarmItem({
    required this.imagePath,
    required this.producer,
    required this.subtitle,
    this.liked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Stack(
        children: [
          // 1. 배경 이미지
          Image.network(
            imagePath,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/farm/temp_farm.jpg',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              );
            },
          ),
          
          // 2. 하단 텍스트 및 아이콘 버튼
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // --- 🖼️ 이 부분이 수정되었습니다 ---
                // 텍스트를 감싸는 반투명 컨테이너
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // 반투명 배경
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Column이 자식 크기만큼만 차지하도록 설정
                    children: [
                      Text(
                        producer,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(), // 텍스트와 아이콘 사이의 공간을 모두 차지
                // --- 여기까지 ---
                
                // 찜 아이콘 버튼
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: const BoxDecoration(
                //     color: Colors.white,
                //     shape: BoxShape.circle,
                //   ),
                //   child: Icon(
                //     liked ? Icons.favorite : Icons.favorite_border,
                //     color: liked ? Colors.red : Colors.grey.shade700,
                //     size: 24,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}