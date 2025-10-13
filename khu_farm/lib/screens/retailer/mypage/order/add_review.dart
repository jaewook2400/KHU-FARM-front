import 'dart:convert';
import 'dart:io'; // File 클래스를 사용하기 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // image_picker 임포트
import 'package:intl/intl.dart';
import 'package:khu_farm/model/order.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';

import '../../../../shared/widgets/top_norch_header.dart';


class RetailerAddReviewScreen extends StatefulWidget {
  const RetailerAddReviewScreen({super.key});

  @override
  State<RetailerAddReviewScreen> createState() =>
      _RetailerAddReviewScreenState();
}

class _RetailerAddReviewScreenState extends State<RetailerAddReviewScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  double _rating = 5.0; // 별점 상태 변수

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage; // 선택된 단일 이미지 파일
  String? _uploadedImageUrl; // 업로드 후 받은 단일 URL
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    // 1. 갤러리에서 단일 이미지 선택
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _isUploading = true;
      });

      // 2. 선택된 이미지를 서버에 업로드
      final imageUrl = await _uploadImage(pickedFile);
      if (imageUrl != null) {
        _uploadedImageUrl = imageUrl;
      }

      setState(() {
        _isUploading = false;
      });
      print('업로드된 URL: $_uploadedImageUrl');
    }
  }

  // 3. 단일 이미지를 서버에 업로드하고 URL을 반환하는 함수
  Future<String?> _uploadImage(XFile imageFile) async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return null;

    final uri = Uri.parse('$baseUrl/image/upload');
    final request = http.MultipartRequest('POST', uri);
    
    // 헤더 추가
    request.headers['Authorization'] = 'Bearer $accessToken';
    
    // 'image'라는 키로 파일 추가
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    try {
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true) {
          return data['result']; // result에 담긴 URL 반환
        }
      }
    } catch (e) {
      print('이미지 업로드 실패: $e');
    }
    return null;
  }

  Future<void> _submitReview(Order order) async {
    // 1. 유효성 검사
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    // 2. API 요청 준비 (URI, 헤더, 바디)
    final uri = Uri.parse('$baseUrl/review/${order.orderDetailId}/add'); // API 명세에 따른 엔드포인트
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'rating': _rating.toInt(), // API는 정수형 별점을 요구
      'imageUrl': _uploadedImageUrl ?? '', // 이미지가 없으면 빈 문자열 전송
      'title': _titleController.text,
      'content': _contentController.text,
    });

    try {
      // 3. POST 요청
      final response = await http.post(uri, headers: headers, body: body);
      if (!mounted) return;

      final data = json.decode(utf8.decode(response.bodyBytes));
      
      // 4. 응답 처리
      if (response.statusCode >= 200 && response.statusCode < 300 && data['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 성공적으로 등록되었습니다.')),
        );
        // TODO: 추후 리뷰 목록 화면으로 이동하도록 수정해야 합니다.
        Navigator.pushReplacementNamed(
          context,
          '/retailer/mypage/review',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 등록 실패: ${data['message']}')),
        );
      }
    } catch (e) {
      print('리뷰 등록 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
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

    final Order order = ModalRoute.of(context)!.settings.arguments as Order;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          RetailerTopNotchHeader(),
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
                // ← 내 정보 타이틀
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
                      '리뷰 작성',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProductInfoCard(order),
                        const SizedBox(height: 24),
                        _buildInputRow('제목', _titleController, '제목을 입력해 주세요.'),
                        const SizedBox(height: 16),
                        _buildInputRow('내용', _contentController, '내용을 입력해 주세요.', maxLines: 8),
                        const SizedBox(height: 16),
                        
                        // --- 🔽 사진 업로드 UI 수정 🔽 ---
                        _buildPhotoUploadSection(),
                        // --- 🔼 사진 업로드 UI 수정 끝 🔼 ---

                        const SizedBox(height: 16),
                        _buildRatingRow(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: MediaQuery.of(context).size.width * 0.08,
            right: MediaQuery.of(context).size.width * 0.08,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                // onPressed에 _submitReview 함수 연결
                onPressed: () => _submitReview(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('리뷰 업로드하기', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    // 버튼과 이미지를 수평으로 배치하기 위해 Row를 사용합니다.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // 위젯들을 수직 중앙 정렬
      children: [
        const SizedBox(width: 40, child: Text('사진', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isUploading ? null : _pickAndUploadImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6FCF4B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isUploading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('사진 업로드하기'),
        ),

        // 선택된 이미지가 있을 경우에만 미리보기를 표시
        if (_selectedImage != null) ...[
          const SizedBox(width: 16), // 버튼과 이미지 사이 간격
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_selectedImage!.path),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                      _uploadedImageUrl = null;
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildProductInfoCard(Order order) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(order.brandName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Text('${order.orderCount}박스', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('${formatter.format(order.price)}원 / ${order.weight}kg', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              order.squareImageUrl,
              width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey[200]),
            ),
          ),
        ],
      ),
    );
  }

  // 텍스트 입력 필드 행 위젯
  Widget _buildInputRow(String label, TextEditingController controller, String hintText, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: maxLines > 1 ? 12.0 : 0),
          child: SizedBox(width: 40, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  // 사진 업로드 행 위젯
  Widget _buildPhotoUploadRow() {
    return Row(
      children: [
        const SizedBox(width: 40, child: Text('사진', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: 이미지 피커 기능 구현
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6FCF4B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('사진 업로드하기'),
        ),
      ],
    );
  }

  // 별점 행 위젯
  Widget _buildRatingRow() {
    return Row(
      children: [
        const SizedBox(width: 40, child: Text('별점', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 16),
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _rating = index + 1.0;
              });
            },
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: Colors.red,
              size: 32,
            ),
          );
        }),
      ],
    );
  }
}
