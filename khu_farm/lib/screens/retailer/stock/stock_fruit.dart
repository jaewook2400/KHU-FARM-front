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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchFruits(int wholesale) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        print('Authentication token is missing. Please log in.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/fruits/search/{wholesaleRetailCategoryId}/{fruitCategoryId}?wholesaleRetailCategoryId=1&fruitCategoryId=$_fruitCategoryId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final Map<String, dynamic> result = data['result'];
        final List<dynamic>? fruitList = result['content'];

        if (fruitList != null) {
          setState(() {
            _fruits = fruitList.map((json) => Fruit.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          print("The 'content' field in the server response is null.");
          setState(() {
            _fruits = [];
            _isLoading = false;
          });
        }
      } else {
        print('API Error - Status Code: ${response.statusCode}');
        print('API Error - Response Body: ${utf8.decode(response.bodyBytes)}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('An error occurred: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchFruits(String keyword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        print('Authentication token is missing. Please log in.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      // API 명세서에 따라 검색 키워드를 포함한 URL 구성
      final response = await http.get(
        Uri.parse('$baseUrl/fruits/search/{wholesaleRetailCategoryId}/{fruitCategoryId}?wholesaleRetailCategoryId=1&fruitCategoryId=$_fruitCategoryId&searchKeyword=$keyword'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final Map<String, dynamic> result = data['result'];
        final List<dynamic>? fruitList = result['content'];

        if (fruitList != null) {
          setState(() {
            _fruits = fruitList.map((json) => Fruit.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          print("The 'content' field in the server response is null.");
          setState(() {
            _fruits = [];
            _isLoading = false;
          });
        }
      } else {
        print('Search API Error - Status Code: ${response.statusCode}');
        print('Search API Error - Response Body: ${utf8.decode(response.bodyBytes)}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('An error occurred during search: $e');
      setState(() {
        _isLoading = false;
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
        print('찜 추가 성공');
        // On success, refetch the entire list from the server
        await _fetchFruits(wholesaleId);
      } else {
        print('찜 추가 실패: ${response.statusCode}');
        print('Response Body: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('찜 추가 에러: $e');
    }
  }

  Future<void> _removeFromWishlist(int fruitId) async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/wishList/$fruitId/delete');

    try {
      final response = await http.delete(uri, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('찜 삭제 성공');
        // On success, refetch the entire list from the server
        await _fetchFruits(wholesaleId);
      } else {
        print('찜 삭제 실패: ${response.statusCode}');
        print('Response Body: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('찜 삭제 에러: $e');
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
                          : ListView.builder(
                              itemCount: _fruits.length,
                              itemBuilder: (context, index) {
                                final fruit = _fruits[index];
                                return _buildProductItem(
                                  context,
                                  fruit: fruit,
                                );
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
    switch (id) {
      case 1:
        return '사과';
      case 2:
        return '감귤';
      case 3:
        return '딸기';
      default:
        return '과일';
    }
  }

  Widget _buildProductItem(BuildContext context, {required Fruit fruit}) {
    return GestureDetector(
      onTap: () {
        // TODO: 상품 상세 화면으로 이동
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