import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/model/inquiry.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart' as quill_ext;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';

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
  late bool _isWishList; // 찜 상태를 관리할 상태 변수

  List<Inquiry> _inquiries = [];
  bool _isInquiriesLoading = true;

  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _isWishList = widget.fruit.isWishList;
    _loadInitialData();
    _fetchInquiries();

    try {
      final dynamic deltaJson = jsonDecode(widget.fruit.description);
      final doc = quill.Document.fromJson(deltaJson as List<dynamic>);
      _previewController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    } catch (e) {
      final doc = quill.Document()..insert(0, widget.fruit.description);
      _previewController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    }
  }

  Future<void> _loadInitialData() async {
    final userInfo = await StorageService().getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  Future<void> _fetchInquiries() async {
    setState(() => _isInquiriesLoading = true);
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      setState(() => _isInquiriesLoading = false);
      return;
    }
    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/inquiry/${widget.fruit.id}');

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> itemsJson = data['result']['content'];
          if (mounted) {
            setState(() {
              _inquiries = itemsJson.map((json) => Inquiry.fromJson(json)).toList();
            });
          }
        }
      }
    } catch (e) {
      print('Failed to fetch inquiries: $e');
    } finally {
      if (mounted) setState(() => _isInquiriesLoading = false);
    }
  }

  void _showInquiryModal() async {
    // Wait for a result from the inquiry list modal.
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (_, controller) => _InquiryModal(
          fruit: widget.fruit,
          inquiries: _inquiries,
          scrollController: controller,
        ),
      ),
    );

    // If the result is true, a new inquiry was added.
    if (result == true) {
      // 1. Refresh the entire inquiry list.
      await _fetchInquiries();
      // 2. If the list is not empty, show the detail view for the newest item (the first one).
      if (_inquiries.isNotEmpty && mounted) {
        _showDetailModal(context, _inquiries.first);
      }
    }
  }

  void _showDetailModal(BuildContext context, Inquiry inquiry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (_, controller) => _InquiryDetailModal(
          fruit: widget.fruit,
          scrollController: controller,
          inquiry: inquiry,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentFruitStatus() async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/fruits/${widget.fruit.id}'); //

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final updatedFruit = Fruit.fromJson(data['result']);
          if (mounted) {
            setState(() {
              _isWishList = updatedFruit.isWishList;
            });
          }
        }
      } else {
        print('Failed to fetch fruit status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fruit status: $e');
    }
  }

  Future<void> _toggleWishlist() async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;
    final headers = {'Authorization': 'Bearer $accessToken'};

    // 현재 _isWishList 상태에 따라 API 분기
    if (_isWishList) {
      // 찜 추가 API 호출
      final uri = Uri.parse('$baseUrl/wishList/${widget.fruit.id}/add');
      try {
        final response = await http.post(uri, headers: headers);
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('찜 추가 성공');
        } else {
          print('찜 추가 실패: ${response.statusCode}');
          print('Response Body: ${utf8.decode(response.bodyBytes)}');
        }
      } catch (e) {
        print('찜 추가 에러: $e');
      }
    } else {
      // 찜 삭제 API 호출
      final uri = Uri.parse('$baseUrl/wishList/${widget.fruit.wishListId}/delete');
      try {
        final response = await http.delete(uri, headers: headers);
        if (response.statusCode == 200 || response.statusCode == 204) {
          print('찜 삭제 성공');
        } else {
          print('찜 삭제 실패: ${response.statusCode}');
          print('Response Body: ${utf8.decode(response.bodyBytes)}');
        }
      } catch (e) {
        print('찜 삭제 에러: $e');
      }
    }
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

  void _navigateToMainPage() {
    String route = '/login'; // 기본값은 로그인 화면
    if (_userInfo != null) {
      switch (_userInfo!.userType) {
        case 'ROLE_INDIVIDUAL':
          route = '/consumer/main';
          break;
        case 'ROLE_BUSINESS':
          route = '/retailer/main';
          break;
        case 'ROLE_FARMER':
          route = '/farmer/main';
          break;
        case 'ADMIN':
          route = '/admin/daily';
          break;
      }
    }
    // 모든 화면 스택을 제거하고 해당 라우트로 이동합니다.
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
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
                                      Navigator.pushNamed(
                                        context,
                                        '/order/direct',
                                        arguments: {
                                          'fruit': widget.fruit,
                                          'quantity': quantity,
                                        },
                                      );
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
                  onTap: _navigateToMainPage,
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
                      onTap: () async {
                        // Navigate to the wishlist screen and wait for it to be popped
                        await Navigator.pushNamed(context, '/farmer/dib/list');
                        // When the user returns, call the new function to get the latest data
                        _fetchCurrentFruitStatus();
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
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
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
                                  onTap: () {
                                    // 1. UI 상태 즉시 변경
                                    setState(() {
                                      _isWishList = !_isWishList;
                                    });
                                    // 2. 백그라운드에서 API 호출
                                    _toggleWishlist();
                                  },
                                  child: Icon(
                                    // UI는 _isLiked 상태 변수를 따름
                                    _isWishList ? Icons.favorite : Icons.favorite_border,
                                    size: 24,
                                    color: _isWishList ? Colors.red : Colors.black,
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700]),
                                      children: [
                                        const TextSpan(text: '택배배송 | '),
                                        const TextSpan(
                                          text: '무료배송 ',
                                          style: TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                            text: widget.fruit.deliveryCompany ?? ''),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.fruit.deliveryDay ?? ''} 이내 판매자 발송 예정',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              Text(
                                '남은 재고 : ${widget.fruit.stock}박스',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12,),
                        
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
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12,),
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
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 이 부분이 추가되었습니다.
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '상품 문의',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showInquiryModal,
                              child: const Text(
                                '더보기 >',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
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

class _InquiryModal extends StatelessWidget {
  final Fruit fruit;
  final List<Inquiry> inquiries;
  final ScrollController scrollController;

  const _InquiryModal({
    required this.fruit,
    required this.inquiries,
    required this.scrollController,
  });

  void _showDetailModal(BuildContext context, Inquiry inquiry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (_, controller) => _InquiryDetailModal(
          fruit: fruit,
          scrollController: controller,
          inquiry: inquiry,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          '문의',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                _ProductInfoCard(fruit: fruit),
                const SizedBox(height: 16),
                Expanded(
                  child: inquiries.isEmpty
                      ? const Center(child: Text('작성된 문의가 없습니다.'))
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: inquiries.length,
                          itemBuilder: (context, index) {
                            final item = inquiries[index];
                            return _InquiryListItem(
                              inquiry: item,
                              onMoreTap: () => _showDetailModal(context, item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _NewInquiryModal(fruit: fruit),
                  );

                  // If the result is true, it means an inquiry was successfully added.
                  // Pop this list modal as well and pass the 'true' signal up.
                  if (result == true && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                // --- End of update ---
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '새 문의하기',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InquiryListItem extends StatelessWidget {
  final Inquiry inquiry;
  final VoidCallback onMoreTap;

  const _InquiryListItem({required this.inquiry, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Q: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  inquiry.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMoreTap,
                child: const Text('더보기 >', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A: ', style: TextStyle(fontWeight: FontWeight.bold, color: inquiry.reply != null ? Colors.blueAccent : Colors.grey)),
              Expanded(
                child: Text(
                  inquiry.reply?.content ?? '답변 대기중',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: inquiry.reply != null ? Colors.black : Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A card that shows a summary of the product inside the modal
class _ProductInfoCard extends StatelessWidget {
  final Fruit fruit;
  const _ProductInfoCard({required this.fruit});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      // --- This part is updated ---
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate image size based on available width
          final imageSize = constraints.maxWidth * 0.33;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fruit.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(fruit.brandName ?? '알 수 없음',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text('1박스',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${formatter.format(fruit.price)}원 / ${fruit.weight}kg',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fruit.squareImageUrl,
                  // Use the dynamic imageSize
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
        },
      ),
      // --- End of update ---
    );
  }
}

class _InquiryDetailModal extends StatelessWidget {
  final Fruit fruit;
  final ScrollController scrollController;
  final Inquiry inquiry;

  const _InquiryDetailModal({
    required this.fruit,
    required this.scrollController,
    required this.inquiry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    '문의',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _ProductInfoCard(fruit: fruit),
                const SizedBox(height: 24),
                _buildSection(
                  isQuestion: true,
                  content: inquiry.content,
                  date: inquiry.createdAt.split('T').first,
                ),
                const SizedBox(height: 16),
                if (inquiry.reply != null)
                  _buildSection(
                    isQuestion: false,
                    content: inquiry.reply!.content,
                    date: inquiry.reply!.createdAt.split('T').first,
                    author: inquiry.reply!.sellerName,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isQuestion,
    required String content,
    required String date,
    String? author,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: isQuestion
          ? null
          : BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isQuestion ? 'Q' : 'A',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isQuestion ? Colors.black : Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(content, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // If there is an author, display it on the left
              if (author != null)
                Text(author,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              
              const Spacer(), // Pushes the date to the far right
              
              // Always display the date
              Text(date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewInquiryModal extends StatefulWidget {
  final Fruit fruit;

  const _NewInquiryModal({required this.fruit});

  @override
  State<_NewInquiryModal> createState() => _NewInquiryModalState();
}

class _NewInquiryModalState extends State<_NewInquiryModal> {
  final TextEditingController _contentController = TextEditingController();
  bool _isPrivate = false; // State for the "Hide" checkbox

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (_contentController.text.trim().isEmpty) {
      // ...
      return;
    }

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('$baseUrl/inquiry/${widget.fruit.id}/add');
    final body = jsonEncode({
      'content': _contentController.text,
      'private': _isPrivate,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          print('Inquiry submitted successfully.');
          if (mounted) {
            // On success, pop and return true to signal a change was made.
            Navigator.of(context).pop(true);
          }
        }
      } else {
        print('Failed to submit inquiry: ${response.statusCode}');
        print('Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('문의 등록에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      print('An error occurred while submitting inquiry: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final modalHeight = MediaQuery.of(context).size.height * 0.9;
    final textFieldHeight = modalHeight * 0.5;

    return Container(
      height: modalHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    '문의',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          // Content Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: textFieldHeight,
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: '내용을 입력해주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- This is the new part ---
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min, // To keep the Row's width minimal
              children: [
                const Text('숨기기'),
                Checkbox(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  side: MaterialStateBorderSide.resolveWith(
                    (states) => BorderSide(
                      width: 1.5,
                      color: states.contains(MaterialState.selected)
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- End of new part ---
          
          const Spacer(), // Pushes the button to the bottom

          // Bottom Button
          Padding(
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitInquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '문의 업로드하기',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}