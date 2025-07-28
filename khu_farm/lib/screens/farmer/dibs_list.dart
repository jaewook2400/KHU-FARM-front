import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:khu_farm/constants.dart';
import '../product_detail.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/services/storage_service.dart';

// DibsItem 모델을 삭제하고 Fruit 모델을 사용합니다.

class FarmerDibsScreen extends StatefulWidget {
  const FarmerDibsScreen({super.key});

  @override
  State<FarmerDibsScreen> createState() => _FarmerDibsScreenState();
}

class _FarmerDibsScreenState extends State<FarmerDibsScreen> {
  // 상태 변수를 List<DibsItem>에서 List<Fruit>로 변경
  List<Fruit> _fruits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDibsItems();
  }

  Future<void> _fetchDibsItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('Error: Access token is missing.');
        return;
      }

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/wishList'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        if (data['isSuccess'] == true) {
          print("asdasasd");
          final List<dynamic> itemsJson = data['result']['fruitWithWishList']['content'];
          if (mounted) {
            setState(() {
              // DibsItem.fromJson 대신 Fruit.fromJson을 사용
              _fruits =
                  itemsJson.map((json) => Fruit.fromJson(json)).toList();
            });
          }
        } else {
          print('API Error: ${data['message']}');
        }
      } else {
        print('HTTP Error: Status Code ${response.statusCode}');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDibsItem(int wishListId) async {
    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('Error: Access token is missing.');
        return;
      }

      final headers = {'Authorization': 'Bearer $accessToken'};

      final response = await http.delete(
        Uri.parse('$baseUrl/wishList/$wishListId/delete'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchDibsItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('찜 목록에서 삭제되었습니다.')),
          );
        }
      } else {
      print('찜 삭제 실패: ${response.statusCode}');
      // 서버에서 보낸 응답 본문을 UTF-8로 디코딩하여 출력
      print('Response Body: ${utf8.decode(response.bodyBytes)}'); 
      // --- 여기까지 ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제에 실패했습니다. 다시 시도해주세요.')),
        );
      }
      }
    } catch (e) {
      print('찜 삭제 중 에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... Scaffold 및 상단 UI 코드는 변경 없음 ...
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 상단 UI (변경 없음)
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
                      onTap: () {},
                      child: Image.asset(
                        'assets/top_icons/dibs_selected_morning.png',
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
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: 20,
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
                      '찜 목록',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _fruits.isEmpty
                          ? const Center(child: Text('찜한 상품이 없습니다.'))
                          : ListView.builder(
                              itemCount: _fruits.length,
                              itemBuilder: (context, index) {
                                final fruit = _fruits[index];
                                return GestureDetector(
                                  onTap: () {
                                    // MaterialPageRoute로 상세 페이지 이동
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailScreen(fruit: fruit),
                                      ),
                                    );
                                  },
                                  child: _WishlistItem(
                                    fruit: fruit,
                                    onDelete: () => _deleteDibsItem(fruit.wishListId),
                                  ),
                                );
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

/// 찜 목록의 각 항목을 렌더링하는 별도의 위젯
class _WishlistItem extends StatelessWidget {
  final Fruit fruit;
  final VoidCallback onDelete;

  const _WishlistItem({required this.fruit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // 가격 포매팅
    final formatter = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  fruit.widthImageUrl, // fruit 모델의 이미지 URL 사용
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 140,
                      child: Icon(Icons.error, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                left: 12,
                child: Text(
                  fruit.brandName ?? '알 수 없음', // fruit 모델의 brandName 사용
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fruit.title, // fruit 모델의 title 사용
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  // 가격과 단위를 fruit 모델에서 가져와 포매팅
                  '${formatter.format(fruit.price)}원 / ${fruit.weight}kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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