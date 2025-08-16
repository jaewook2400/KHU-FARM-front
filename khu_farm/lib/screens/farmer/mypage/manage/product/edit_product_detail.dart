import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart' as quill_ext;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/fruit.dart';

class FarmerEditProductDetailScreen extends StatefulWidget {
  const FarmerEditProductDetailScreen({super.key});

  @override
  State<FarmerEditProductDetailScreen> createState() =>
      _FarmerEditProductDetailScreenState();
}

class _FarmerEditProductDetailScreenState
    extends State<FarmerEditProductDetailScreen> {
  quill.QuillController? _controller;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  // 이전 화면에서 받은 데이터를 저장할 변수
  late Map<String, dynamic> _arguments;
  late Fruit _originalFruit;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 데이터 초기화는 한 번만 실행
    if (!_isInitialized) {
      _arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _originalFruit = _arguments['originalFruit'] as Fruit;
      _initializeQuillController();
      _isInitialized = true;
    }
  }

  // --- 🔽 기존 상품 설명으로 Quill 에디터를 초기화하는 함수 🔽 ---
  void _initializeQuillController() {
    try {
      // description이 JSON(Delta) 형식일 경우 파싱하여 Document 생성
      final deltaJson = jsonDecode(_originalFruit.description);
      final doc = quill.Document.fromJson(deltaJson as List<dynamic>);
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // description이 일반 텍스트이거나 형식이 잘못된 경우
      final doc = quill.Document()..insert(0, _originalFruit.description);
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _insertImage() async {
    final XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final String? token = await StorageService.getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 정보가 없습니다.')));
      return;
    }

    final Uri uri = Uri.parse('$baseUrl/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          picked.path,
          filename: File(picked.path).uri.pathSegments.last,
        ),
      );

    final streamed = await request.send();
    if (streamed.statusCode == 200) {
      final String body = await streamed.stream.bytesToString();
      final Map<String, dynamic> data = jsonDecode(body);
      final String imagePath = data['result'] as String;

      final int index = _controller!.selection.baseOffset;
      final int length = _controller!.selection.extentOffset - index;
      _controller!.replaceText(
        index,
        length,
        quill.BlockEmbed.image(imagePath),
        null,
      );
      _controller!.updateSelection(
        TextSelection.collapsed(offset: index + 1),
        quill.ChangeSource.local,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 업로드 실패: \${streamed.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> prevArgs = ModalRoute.of(context)!
        .settings
        .arguments as Map<String, dynamic>;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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

          // 콘텐츠 영역
          Positioned.fill(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: bottomPadding + 48 + 30,
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
                    const Text('제품 수정하기',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('상세페이지 작성',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                // 툴바
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: quill.QuillSimpleToolbar(
                    controller: _controller!,
                    config: quill.QuillSimpleToolbarConfig(
                      showBoldButton: true,
                      showUnderLineButton: true,
                      showColorButton: true,

                      customButtons: [
                        quill.QuillToolbarCustomButtonOptions(
                          icon: Icon(Icons.image),
                          onPressed: () => _insertImage(),
                          tooltip: '이미지 삽입',
                        ),
                      ],

                      showFontFamily: false,
                      showFontSize: false,
                      showItalicButton: false,
                      showSmallButton: false,
                      showLineHeightButton: false,
                      showStrikeThrough: false,
                      showInlineCode: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showAlignmentButtons: false,
                      showHeaderStyle: false,
                      showListNumbers: false,
                      showListBullets: false,
                      showListCheck: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showIndent: false,
                      showLink: false,
                      showUndo: false,
                      showRedo: false,
                      showSearchButton: false,
                      showDirection: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showClipboardCut: false,
                      showClipboardCopy: false,
                      showClipboardPaste: false,
                    ),
                  ),
                ),

                // 에디터
                SizedBox(
                  height: screenHeight * 0.5,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: quill.QuillEditor(
                      focusNode: _focusNode,
                      scrollController: _scrollController,
                      controller: _controller!,
                      config: quill.QuillEditorConfig(
                        placeholder: '상품설명을 작성해 주세요.',
                        padding: EdgeInsets.zero,
                        expands: false,
                        embedBuilders: quill_ext.FlutterQuillEmbeds.editorBuilders(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 하단 고정 버튼
          Positioned(
            bottom: bottomPadding + 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6FCF4B)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      '이전',
                      style: TextStyle(color: Color(0xFF6FCF4B)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/farmer/mypage/manage/product/edit/preview',
                        arguments: {
                          ...prevArgs,
                          'content': jsonEncode(_controller!.document.toDelta().toJson()),
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FCF4B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('다음',
                    style: TextStyle(color: Colors.white),),
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