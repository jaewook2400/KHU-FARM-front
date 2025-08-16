import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart' as quill_ext;
import 'package:http/http.dart' as http;
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';

class FarmerEditProductPreviewScreen extends StatefulWidget {
  const FarmerEditProductPreviewScreen({super.key});

  @override
  State<FarmerEditProductPreviewScreen> createState() =>
      _FarmerEditProductPreviewScreen();
}

class _FarmerEditProductPreviewScreen
    extends State<FarmerEditProductPreviewScreen> {

  late quill.QuillController _previewController;
  bool _initialized = false;
  bool _isProcessing = false;

  Future<String> _uploadImage(String imagePath) async {
    final String? token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('로그인 정보가 없습니다.');
    }

    final uri = Uri.parse('$baseUrl/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: File(imagePath).uri.pathSegments.last,
      ));

    final response = await request.send();
    if (response.statusCode == 200) {
      final bodyString = await response.stream.bytesToString();
      final decoded = jsonDecode(bodyString) as Map<String, dynamic>;
      // assume your API returns something like { "url": "https://..." }
      return decoded['result'] as String;
    } else {
      final err = await response.stream.bytesToString();
      throw Exception('Image upload failed (${response.statusCode}): $err');
    }
  }

  Future<void> _updateFruit() async {
    setState(() => _isProcessing = true);

    // 이전 화면들에서 전달받은 arguments 파싱
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Fruit originalFruit = args['originalFruit'] as Fruit;
    final Map<String, dynamic> editedData = args['editedData'] as Map<String, dynamic>;

    try {
      final String hPath = editedData['horizontalImagePath'] as String;
      final String sPath = editedData['squareImagePath'] as String;

      // 이미지가 로컬 경로일 경우(새로 선택)에만 업로드, 아니면 기존 URL 사용
      final String horizontalUrl = hPath.startsWith('http') ? hPath : await _uploadImage(hPath);
      final String squareUrl = sPath.startsWith('http') ? sPath : await _uploadImage(sPath);
      final String description = args['content'] as String;

      final String? token = await StorageService.getAccessToken();
      if (token == null) throw Exception('로그인 정보가 없습니다.');
      
      // API 명세에 따라 PATCH 메서드와 fruitId를 포함한 URI로 변경
      final uri = Uri.parse('$baseUrl/fruits/seller/${originalFruit.id}');
      final payload = {
        'fruitCategoryId': editedData['category'],
        'wholesaleRetailCategoryId': editedData['type'],
        'widthImage': horizontalUrl,
        'squareImage': squareUrl,
        'title': editedData['title'],
        'price': int.parse(editedData['price'] as String),
        'weight': int.parse(editedData['weight'] as String),
        // courier 이름으로 id를 찾아 변환
        'deliveryCompany': editedData['courier'] as String,
        'deliveryDay': int.parse(editedData['maxDelivery'] as String),
        'description': description,
        'stock': int.parse(editedData['stock'] as String),
      };
      
      print('상품 수정 API 요청 페이로드: ${jsonEncode(payload)}');

      // http.post를 http.patch로 변경
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('상품 수정 실패 ${response.statusCode}: ${response.body}');
      }
      
      // 수정 완료 후 관리 목록 화면으로 이동
      Navigator.popUntil(context, ModalRoute.withName('/farmer/mypage/manage/product'));

    } catch (e) {
      print('상품 수정 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      // --- 🔽 arguments 구조 변경에 따라 'content' 키에서 description 로드 🔽 ---
      final dynamic contentArg = args['content']; 
      final List<dynamic> deltaJson = jsonDecode(contentArg as String) as List<dynamic>;
      final doc = quill.Document.fromJson(deltaJson);
      _previewController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final editedData = args['editedData'] as Map<String, dynamic>;
    
    final String hPath = editedData['horizontalImagePath'] as String;
    final String sPath = editedData['squareImagePath'] as String;
    final String title = editedData['title'] as String;
    final String price = editedData['price'] as String;
    final String weight = editedData['weight'] as String;
    final String stock = editedData['stock'] as String;
    final String courier = editedData['courier'] as String;

    final mediaQuery = MediaQuery.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    Widget imagePreviewWidget;
    if (hPath.startsWith('http')) {
      imagePreviewWidget = Image.network(hPath, width: MediaQuery.of(context).size.width, fit: BoxFit.cover);
    } else {
      imagePreviewWidget = Image.file(File(hPath), width: MediaQuery.of(context).size.width, fit: BoxFit.cover);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 상단 노치 배경
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

          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 뒤로가기 + 제목
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/icons/goback.png',
                          width: 18, height: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('제품 수정하기 (미리보기)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ]
            )
          ),

          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 60,
            left: 0,
            right: 0,
            bottom: bottomPadding + 20,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 65),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 미리보기
                  if (hPath.isNotEmpty) imagePreviewWidget,
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.red, size: 16)),
                            ),
                            const SizedBox(width: 8),
                            const Text('5.0', style: TextStyle(fontSize: 16)),
                            const Spacer(),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('$price원 / ${weight}kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text('한우리영농조합', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('택배배송', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 4),
                            const Text('무료배송', style: TextStyle(fontSize: 12, color: Colors.red)),
                            const SizedBox(width: 4),
                            Text(courier, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('01.01(월)이내 판매자 발송 예정', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const Spacer(),
                            Text('남은 재고 : $stock 박스', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('리뷰', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const Align(alignment: Alignment.centerRight, child: Text('더보기 >', style: TextStyle(color: Colors.grey))),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text('상세 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      ],
                    )
                  ),
                ],
              ),
            ),
          ),
          // 하단 버튼
          Positioned(
            bottom: bottomPadding,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6FCF4B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('이전', style: TextStyle(color: Color(0xFF6FCF4B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      // --- 🔽 _updateFruit 함수 호출 및 로딩 상태 반영 🔽 ---
                      onPressed: _isProcessing ? null : _updateFruit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCF4B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isProcessing 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text('수정 완료', style: TextStyle(color: Colors.white)),
                      // --- 🔼 수정 끝 🔼 ---
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