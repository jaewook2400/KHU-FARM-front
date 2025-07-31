import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/screens/product_detail.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/services/storage_service.dart';

class RetailerStockFruitScreen extends StatefulWidget {
  const RetailerStockFruitScreen({super.key});

  @override
  State<RetailerStockFruitScreen> createState() => _RetailerStockFruitScreenState();
}

class _RetailerStockFruitScreenState extends State<RetailerStockFruitScreen> {
  int? _fruitCategoryId;
  late final int wholesaleId;
  List<Fruit> _fruits = [];
  bool _isLoading = true;
  late final TextEditingController _searchController;

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  String? _currentSearchKeyword;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        _hasMore &&
        !_isFetchingMore) {
      if (_fruits.isEmpty) return;
      final cursorId = _fruits.last.id;
      
      if (_currentSearchKeyword != null && _currentSearchKeyword!.isNotEmpty) {
        _searchFruits(_currentSearchKeyword!, cursorId: cursorId);
      } else {
        _fetchFruits(wholesaleId, cursorId: cursorId);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fruitCategoryId == null) {
      try {
        final arguments = ModalRoute.of(context)!.settings.arguments;
        if (arguments is Map<String, dynamic> &&
            arguments.containsKey('fruitId') &&
            arguments.containsKey('wholesale')) {
          _fruitCategoryId = arguments['fruitId'] as int;
          wholesaleId = arguments['wholesale'] as int;
          _fetchFruits(wholesaleId);
        } else {
          throw const FormatException('Invalid arguments passed to the screen.');
        }
      } catch (e) {
        print('Failed to load fruit ID: ${e.toString()}');
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchFruits(int wholesale, {int? cursorId}) async {
    if (_isFetchingMore) return;

    if (cursorId == null) {
      _currentSearchKeyword = null;
      _searchController.clear();
      _hasMore = true;
    }

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMore = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');

      final headers = {'Authorization': 'Bearer $accessToken'};
      
      String uri = '$baseUrl/fruits/get/{wholesaleRetailCategoryId}/{fruitCategoryId}?wholesaleRetailCategoryId=$wholesale&fruitCategoryId=$_fruitCategoryId&size=5';
      if (cursorId != null) {
        uri += '&cursorId=$cursorId';
      }

      final response = await http.get(Uri.parse(uri), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic>? fruitListJson = data['result']['content'];

        if (fruitListJson != null) {
          final newFruits = fruitListJson.map((json) => Fruit.fromJson(json)).toList();
          setState(() {
            if (cursorId == null) {
              _fruits = newFruits;
            } else {
              _fruits.addAll(newFruits);
            }
            if (newFruits.length < 5) {
              _hasMore = false;
            }
          });
        }
      } else {
        throw Exception('Failed to load fruits: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred in _fetchFruits: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  Future<void> _searchFruits(String keyword, {int? cursorId}) async {
    if (_isFetchingMore) return;

    if (cursorId == null) {
      _fruits.clear();
      _currentSearchKeyword = keyword;
      _hasMore = true;
    }

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMore = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');
      
      final headers = {'Authorization': 'Bearer $accessToken'};
      
      // ✨ 5. API 명세서에 요청된 특정 URL 형식으로 구성
      final path = '$baseUrl/fruits/search/{wholesaleRetailCategoryId}/{fruitCategoryId}';
      final queryParameters = {
          'wholesaleRetailCategoryId': wholesaleId.toString(),
          'fruitCategoryId': _fruitCategoryId.toString(),
          'searchKeyword': keyword,
          'size': '5',
          if (cursorId != null) 'cursorId': cursorId.toString(),
      };

      final uri = Uri.parse(path).replace(queryParameters: queryParameters);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final newFruits = (data['result']['content'] as List)
            .map((json) => Fruit.fromJson(json))
            .toList();

        setState(() {
          _fruits.addAll(newFruits);
          if (newFruits.length < 5) {
            _hasMore = false;
          }
        });
      } else {
        throw Exception('Failed to search fruits: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred during search: $e');
    } finally {
      if(mounted) setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
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
            // _NavItem(
            //   iconPath: 'assets/bottom_navigator/unselect/laicos.png',
            //   onTap: () {
            //     Navigator.pushNamedAndRemoveUntil(
            //       context,
            //       '/retailer/laicos',
            //       ModalRoute.withName("/retailer/main"),
            //     );
            //   },
            // ),
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
                        _fetchFruits(wholesaleId);
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
            bottom: 0,
            child: Column(
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
                    Text(
                      _getFruitName(_fruitCategoryId),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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
                    controller: _searchController,
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
                        _fetchFruits(wholesaleId); // 검색어가 없으면 전체 목록 다시 로드
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _fruits.isEmpty
                          ? const Center(child: Text('해당 과일이 없습니다.'))
                          // ✨ 5. ListView.builder 수정
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _fruits.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _fruits.length) {
                                  return _hasMore
                                      ? const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(child: CircularProgressIndicator()),
                                        )
                                      : const SizedBox.shrink();
                                }
                                final fruit = _fruits[index];
                                return _buildProductItem(context, fruit: fruit);
                              },
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: screenWidth * 0.02,
            right: screenWidth * 0.02,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  // TODO: 챗봇 모달 열기
                },
                child: Image.asset(
                  'assets/chat/chatbot_icon.png',
                  width: 68,
                  height: 68,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFruitName(int? id) {
    // id가 null이면 기본값 반환
    if (id == null) {
      return '과일';
    }

    // fruitsCategory 리스트에서 일치하는 id를 찾습니다.
    for (var category in fruitsCategory) {
      if (category['fruitId'] == id) {
        // 일치하는 id를 찾으면 해당 fruitName을 반환합니다.
        return category['fruitName'] as String;
      }
    }

    // 리스트에서 일치하는 id를 찾지 못하면 기본값을 반환합니다.
    return '과일';
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
      child: Image.asset(iconPath, width: size, height: size),
    );
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