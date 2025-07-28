import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart' as quill_ext;
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';

class FarmerAddProductPreviewScreen extends StatefulWidget {
  const FarmerAddProductPreviewScreen({super.key});

  @override
  State<FarmerAddProductPreviewScreen> createState() =>
      _FarmerAddProductPreviewScreen();
}

class _FarmerAddProductPreviewScreen
    extends State<FarmerAddProductPreviewScreen> {

  late quill.QuillController _previewController;
  bool _initialized = false;

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

  Future<void> _addFruit() async {
    // Route args 에서 path 꺼내기
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int    fruitCategoryId = args['category']   as int;
    final int    wholesaleRetailCategoryId = args['type']       as int;
    final String hPath = args['horizontalImagePath'] as String;
    final String sPath = args['squareImagePath']     as String;
    final String title = args['title']     as String;
    final int    price = int.parse(args['price'] as String);
    final int weight = int.parse(args['weight'] as String);
    final String deliveryCompany = args['courier']   as String;
    final int    deliveryDay = int.parse(args['normalShipping'] as String);
    final int    stock = int.parse(args['stock'] as String);
    final dynamic contentArg = args['content'];
    final String description = contentArg is String
        ? contentArg
        : jsonEncode(contentArg as List<dynamic>);
      
    try {
      final String horizontalUrl = await _uploadImage(hPath);
      final String squareUrl = await _uploadImage(sPath);

      final String? token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final uri = Uri.parse('$baseUrl/fruits/add');
      final payload = {
        'fruitCategoryId':             fruitCategoryId,
        'wholesaleRetailCategoryId':   wholesaleRetailCategoryId,
        'widthImage':                  horizontalUrl,
        'squareImage':                 squareUrl,
        'title':                       title,
        'price':                       price,
        'weight':                      weight,
        'deliveryCompany':             deliveryCompany,
        'deliveryDay':                 deliveryDay,
        'description':                 description,
        'stock':                       stock,
      };

// 1) print it
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      print(jsonEncode(payload));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('상품 등록 실패 ${response.statusCode}: ${response.body}');
      }

      Navigator.popUntil(context, ModalRoute.withName('/farmer/main'));
    } catch (e) {
      // 업로드 또는 등록 실패 시 사용자에게 알림
      print('업로드 실패: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final dynamic contentArg = args['content'];
      final List<dynamic> deltaJson = contentArg is String
          ? jsonDecode(contentArg) as List<dynamic>
          : contentArg as List<dynamic>;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String hPath = args['horizontalImagePath'] as String;
    final String sPath = args['squareImagePath'] as String;
    final String title = args['title'] as String;
    final String price = args['price'] as String;
    final String weight = args['weight'] as String;
    final String stock = args['stock'] as String;
    final String courier = args['courier'] as String;

    final mediaQuery = MediaQuery.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                    const Text('제품 추가하기 (미리보기)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
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
                  if (hPath.isNotEmpty) Image.file(File(sPath), width: mediaQuery.size.width, fit: BoxFit.cover),
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
                      onPressed: _addFruit,
                      // {
                        
                        // Navigator.popUntil(context, ModalRoute.withName('/farmer/main'));
                      // },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCF4B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('완료하기', style: TextStyle(color: Colors.white)),
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