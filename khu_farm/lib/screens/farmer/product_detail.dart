import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/fruit.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart' as quill_ext;
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/storage_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Fruit fruit;

  const ProductDetailScreen({
    Key? key,
    required this.fruit,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late quill.QuillController _previewController;

  @override
  void initState() {
    super.initState();
    final dynamic deltaJson = jsonDecode(widget.fruit.description);
    final doc = quill.Document.fromJson(deltaJson as List<dynamic>);
    _previewController = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(int fruitId, int quantity) async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print("Access Token is missing.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
      }
      return;
    }

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/cart/$fruitId/add?count=$quantity');

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('장바구니에 상품을 추가했습니다.')),
          );
        }
      } else {
        // --- 이 부분이 수정되었습니다 ---
        print('장바구니 추가 실패: ${response.statusCode}');
        // 서버에서 보낸 전체 응답 본문을 UTF-8로 디코딩하여 출력합니다.
        print('Response Body: ${utf8.decode(response.bodyBytes)}');
        // --- 여기까지 ---
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('장바구니 추가에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      print('장바구니 추가 중 에러 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
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

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double buttonHeight = 50;

    void _showPurchaseModal() {
      final int unitPrice = widget.fruit.price;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          int quantity = 1;
          String formatPrice(int value) {
            final s = value.toString();
            return s.replaceAllMapped(
              RegExp(r"\B(?=(\d{3})+(?!\d))"),
              (m) => ',',
            );
          }

          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () {},
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: StatefulBuilder(
                    builder: (context, setModalState) {
                      final int total = unitPrice * quantity;
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: bottomPadding + 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.fruit.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1) {
                                      setModalState(() => quantity--);
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setModalState(() => quantity++),
                                  icon: const Icon(Icons.add),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '박스',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '총 상품금액(무료배송)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${formatPrice(total)}원',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    // --- '장바구니' 버튼 기능 연결 ---
                                    onPressed: () {
                                      _addToCart(widget.fruit.id, quantity);
                                    },
                                    // --- 여기까지 ---
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.green.shade400,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      '장바구니',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: 구매하기 로직 구현
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      '구매하기',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

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
                          '/farmer/notification/list',
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

          // Content
          Positioned(
            top: statusBarHeight + screenHeight * 0.06,
            left: 0,
            right: 0,
            bottom: bottomPadding + buttonHeight + 50,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.network(
                      widget.fruit.widthImageUrl,
                      width: double.infinity,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // The container below is where the components below the image are located
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.fruit.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Rating and action icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // rating 만큼 빨간색 채워진 별
                                for (int i = 0; i < widget.fruit.ratingSum.floor(); i++)
                                  const Icon(Icons.star, size: 20, color: Colors.red),
                                
                                // 0.5 이상일 경우 반쪽짜리 별 추가
                                if (widget.fruit.ratingSum - widget.fruit.ratingSum.floor() >= 0.5)
                                  const Icon(Icons.star_half, size: 20, color: Colors.red),

                                // 남은 별 만큼 빈 별 추가
                                for (int i = 0; i < (5 - widget.fruit.ratingSum.ceil()); i++)
                                  const Icon(Icons.star_border, size: 20, color: Colors.grey),

                                const SizedBox(width: 4),
                                Text(
                                  widget.fruit.ratingSum.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Icon(
                                    widget.fruit.liked ? Icons.favorite : Icons.favorite_border,
                                    size: 24,
                                    color: widget.fruit.liked ? Colors.red : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Icon(Icons.share, size: 24),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Price and tag
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.fruit.price}원',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ' / ${widget.fruit.weight}kg',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.fruit.brandName ?? '알 수 없음',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Review header
                        const Text(
                          '리뷰',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('리뷰 데이터가 없습니다.'),
                        const SizedBox(height: 24),
                        // 상세 정보
                        const Text(
                          '상세 정보',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(0),
                          child: quill.QuillEditor(
                            controller: _previewController,
                            focusNode: FocusNode(),
                            scrollController: ScrollController(),
                            config: quill.QuillEditorConfig(
                              padding: EdgeInsets.zero,
                              expands: false,
                              embedBuilders: quill_ext.FlutterQuillEmbeds.editorBuilders(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '상품 문의',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('상품 문의 데이터가 없습니다.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating back button
          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/icons/goback.png',
                  width: 18,
                  height: 18,
                ),
              ),
            ),
          ),
          // Purchase button
          Positioned(
            bottom: bottomPadding + 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: _showPurchaseModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '구매하기',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}