import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/model/inquiry.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/model/review.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart' as quill_ext;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/shared/widgets/top_norch_header.dart';

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

  List<ReviewInfo> _reviews = [];
  bool _isReviewsLoading = true;

  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _isWishList = widget.fruit.isWishList;
    _loadInitialData();
    _fetchInquiries();
    _fetchReviews();

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
    
    // --- 이 부분이 수정되었습니다 ---
    // API 명세에 따라 size=1000 쿼리 파라미터를 추가합니다.
    final uri = Uri.parse('$baseUrl/inquiry/${widget.fruit.id}?size=1000');
    // --- 여기까지 ---

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        // API 응답 구조에 맞춰 'result' 객체 안의 'content' 리스트를 가져옵니다.
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
    // 문의 목록 모달을 띄우고, 새로운 문의가 등록되었는지 결과(true)를 기다립니다.
    final inquiryAdded = await showModalBottomSheet<bool>(
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

    // 새로운 문의가 성공적으로 추가되었다면 (결과가 true라면)
    if (inquiryAdded == true && mounted) {
      // 1. 서버로부터 전체 문의 목록을 다시 불러와 갱신합니다.
      await _fetchInquiries();
      
      // 2. 갱신된 문의 목록을 보여주기 위해 모달을 다시 엽니다.
      //    (사용자 경험상 모달이 닫혔다가 다시 열리는 흐름입니다)
      _showInquiryModal();
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

  Future<void> _fetchReviews() async {
    setState(() => _isReviewsLoading = true);
    // 이 API는 토큰이 필요 없을 수 있으나, 일관성을 위해 추가합니다.
    // 필요 없다면 headers 부분을 제거해도 됩니다.
    final accessToken = await StorageService.getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};
    
    final uri = Uri.parse('$baseUrl/review/${widget.fruit.id}/retrieve/all?size=1000');

    try {
      final response = await http.get(uri, headers: headers);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result']?['content'] != null) {
          final List<dynamic> itemsJson = data['result']['content'];
          setState(() {
            _reviews = itemsJson.map((json) => ReviewInfo.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isReviewsLoading = false;
        });
      }
    }
  }

  void _showReviewModal() {
    // DraggableScrollableSheet을 사용하여 모달을 띄웁니다.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (_, controller) => _ReviewModal(
          reviews: _reviews,
          scrollController: controller,
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
    print(widget.fruit);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double buttonHeight = 50;

    final int maxDelivery = widget.fruit.deliveryDay;
    final DateTime now = DateTime.now();
    final DateTime estimatedShipDate = now.add(Duration(days: maxDelivery));
    final String formattedDate = DateFormat('MM.dd(E)', 'ko_KR').format(estimatedShipDate);

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
          FarmerTopNotchHeader(),

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
                      widget.fruit.squareImageUrl,
                      width: double.infinity,
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
                                  Text('$formattedDate 이내 판매자 발송 예정', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                         _buildReviewSection(),

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

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('리뷰', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _showReviewModal,
                child: const Text('더보기 >', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isReviewsLoading
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
                  ? const Text('작성된 리뷰가 없습니다.')
                  : SizedBox(
                      // --- 🔽 카드 높이에 맞춰 영역 높이 수정 🔽 ---
                      height: 110, 
                      // --- 🔼 수정 끝 🔼 ---
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          return _ReviewCard(review: _reviews[index]);
                        },
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의 내용을 입력해주세요.')),
      );
      return;
    }

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      print('[API Error] Access Token is missing. User might not be logged in.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
      }
      return;
    }

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
      // 응답 본문은 한 번만 디코딩하여 재사용합니다.
      final data = json.decode(utf8.decode(response.bodyBytes));

      // 요청이 성공적으로 처리된 경우 (isSuccess: true)
      if (response.statusCode >= 200 && response.statusCode < 300 && data['isSuccess'] == true) {
        print('[API Success] Inquiry submitted successfully.');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // 서버 로직상 실패 또는 HTTP 에러인 경우
        print('[API Error] Failed to submit inquiry.');
        print('   - Status Code: ${response.statusCode}');
        print('   - Server Message: ${data['message']}');
        print('   - Full Response: $data');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('문의 등록 실패: ${data['message'] ?? '알 수 없는 오류'}' )),
          );
        }
      }
    } catch (e) {
      // 네트워크 오류 등 예외가 발생한 경우
      print('[Exception] An exception occurred while submitting inquiry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오류가 발생했습니다. 네트워크 연결을 확인해주세요.')),
        );
      }
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


class _ReviewCard extends StatelessWidget {
  final ReviewInfo review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 리뷰 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              review.imageUrl,
              width: 95,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 95, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 12),
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // --- 🔽 mainAxisAlignment.center 속성 제거 🔽 ---
              // mainAxisAlignment: MainAxisAlignment.center, // 이 라인을 삭제하여 상단 정렬로 변경
              // --- 🔼 수정 끝 🔼 ---
              children: [
                // 제목 및 별점
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildRatingStars(review.rating.toDouble()),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 내용
                Text(
                  review.content,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.red,
          size: 16,
        );
      }),
    );
  }
}

class _ReviewModal extends StatelessWidget {
  final List<ReviewInfo> reviews;
  final ScrollController scrollController;

  const _ReviewModal({required this.reviews, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더 (닫기 버튼, 타이틀)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text('리뷰', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 48), // 중앙 정렬을 위한 공간
              ],
            ),
          ),
          // 리뷰 목록
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: reviews.length,
              // itemBuilder는 각 리뷰 아이템을 생성합니다.
              itemBuilder: (context, index) {
                return _ReviewModalItem(review: reviews[index]);
              },
              // separatorBuilder는 각 아이템 사이에 들어갈 위젯(구분선)을 생성합니다.
              // 마지막 아이템 다음에는 자동으로 추가되지 않습니다.
              separatorBuilder: (context, index) => const Divider(
                height: 48, // 위아래 여백을 포함한 높이
                thickness: 1, // 구분선 두께
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// --- 🔽 모달에 들어갈 개별 리뷰 아이템 위젯 🔽 ---
class _ReviewModalItem extends StatelessWidget {
  final ReviewInfo review;
  const _ReviewModalItem({required this.review});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(review.createdAt));
    } catch (e) {
      formattedDate = review.createdAt;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 이미지 (있을 경우에만 표시)
          if (review.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  review.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey[200]),
                ),
              ),
            ),
          
          // 리뷰 제목
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(review.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              _buildRatingStars(review.rating.toDouble()),
              const SizedBox(width: 4),
              Text(review.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),

          // Row 2: 작성자와 날짜
          Row(
            children: [
              Text('ID:${review.userId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          // --- 🔼 수정 끝 🔼 ---

          const SizedBox(height: 12),
          // 리뷰 내용
          Text(review.content),
          const SizedBox(height: 16),

          // --- 🔽 판매자 답변 UI 수정 🔽 ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('판매자 답변', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  review.replyContent != null && review.replyContent!.isNotEmpty
                      ? review.replyContent!
                      : '답변 대기중',
                  style: TextStyle(
                    color: review.replyContent != null && review.replyContent!.isNotEmpty
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // --- 🔼 수정 끝 🔼 ---
        ],
      ),
    );
  }
  
  // 별점 표시 헬퍼 위젯
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.red,
          size: 16,
        );
      }),
    );
  }
}