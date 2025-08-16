import 'dart:async';
import 'dart:convert'; // for jsonEncode/Decode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http package
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:khu_farm/constants.dart'; // baseUrl
import 'package:khu_farm/services/storage_service.dart';

// 메시지 데이터를 관리하기 위한 간단한 모델 클래스
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

// 모달을 표시하는 함수 (daily.dart에서 이 함수를 호출)
void showChatbotModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 키보드가 올라올 때 UI가 가려지지 않도록 설정
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8, // 초기 모달 높이
        minChildSize: 0.4,     // 최소 모달 높이
        maxChildSize: 0.9,     // 최대 모달 높이
        builder: (_, controller) {
          return ChatbotScreen(scrollController: controller);
        },
      );
    },
  );
}

class ChatbotScreen extends StatefulWidget {
  final ScrollController scrollController;
  const ChatbotScreen({super.key, required this.scrollController});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 메시지 설정 (디자인 시안과 동일하게)
    _messages.addAll([
      ChatMessage(text: '궁금한 것이 있으면 질문해 주세요!', isUser: false),
    ]);
  }

  // 메시지를 전송하는 함수
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: '나쿠가 입력 중...', isUser: false)); // 로딩 메시지
      _isLoading = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing.');
      final headers = {'Authorization': 'Bearer $accessToken'};
      // 2. API 요청 준비 (GET 쿼리 파라미터 구성)
      final requestParams = {'question': text};
      final encodedParams = Uri.encodeComponent(jsonEncode(requestParams));
      final url= '$baseUrl/chatBot?question=$encodedParams';

      // 3. API 호출
      final response = await http.get(Uri.parse(url), headers: headers);

      if (!mounted) return;

      // 4. 로딩 인디케이터 제거
      setState(() {
        _messages.removeWhere((msg) => msg.text == '나쿠가 입력 중...');
      });

      // 5. 결과 처리
      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위해 utf8로 디코딩
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        final botAnswer = decodedBody['result'];

        setState(() {
          _messages.add(ChatMessage(text: botAnswer, isUser: false));
        });
      } else {
        // API 에러 처리
        print('Chatbot API Error: ${response.statusCode}');
        setState(() {
          _messages.add(ChatMessage(text: '죄송해요, 오류가 발생했어요.', isUser: false));
        });
      }
    } catch (e) {
      // 네트워크 등 기타 에러 처리
      print('Chatbot Error: $e');

      if (!mounted) return;

      setState(() {
        _messages.removeWhere((msg) => msg.text == '나쿠가 입력 중...');
        _messages.add(ChatMessage(text: '네트워크에 문제가 있어요. 다시 시도해주세요.', isUser: false));
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 상단 핸들 및 닫기 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40), // 중앙 정렬을 위한 여백
                const Text('챗봇', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          
          // 1. 채팅 메시지 영역 (하단 정렬 및 스크롤)
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController, // DraggableScrollableSheet의 스크롤 컨트롤러 사용
              reverse: true, // 리스트를 뒤집어서 항상 최신 메시지가 하단에 오도록 함
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // reverse이므로 최신 메시지가 0번 인덱스가 됨
                final message = _messages.reversed.toList()[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // 2. 추천 질문 버튼 영역 (가로 스크롤)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSuggestionChip('과일 레시피'),
                  _buildSuggestionChip('일반 QnA'),
                  _buildSuggestionChip('과일 효능'),
                  // 필요시 다른 버튼 추가
                ],
              ),
            ),
          ),
          
          // 3. 메시지 입력 영역
          _buildTextComposer(),
        ],
      ),
    );
  }

  // 추천 질문 버튼 위젯
  Widget _buildSuggestionChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        onPressed: _isLoading ? null : () => _handleSubmitted(label),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(color: Colors.grey),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  // 메시지 버블 위젯
  Widget _buildMessageBubble(ChatMessage message) {
    // 사용자 메시지는 왼쪽 여백, 봇 메시지는 오른쪽 여백을 주어 너비를 제한
    Widget messageContent = message.isUser
        ? _userMessage(message)
        : Container(
            margin: const EdgeInsets.only(right: 40.0), // 오른쪽 여백 40 추가
            child: _botMessage(message),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: messageContent,
      ),
    );
  }

  // 봇 메시지 스타일
  Widget _botMessage(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/chat/chatbot_icon.png', width: 40, height: 40),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('나쿠', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4EDDA), // 연한 초록색
                  borderRadius: BorderRadius.circular(16),
                ),
                // Text 위젯을 MarkdownBody 위젯으로 변경
                child: MarkdownBody(
                  data: message.text,
                  // 선택적: 기본 텍스트 스타일을 앱의 테마와 일치시키기
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontSize: 18, // 필요시 폰트 사이즈 조정
                        ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // 사용자 메시지 스타일
  Widget _userMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 60),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(message.text, style: const TextStyle(color: Colors.black87, fontSize: 18)),
    );
  }

  // 메시지 입력창 위젯
  Widget _buildTextComposer() {
    // 키보드를 제외한 시스템 UI(하단 네비게이션 바 등)의 크기를 가져옵니다.
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // 기존 padding에 시스템 하단 네비게이션 바 높이만큼 추가합니다.
      padding: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 8.0,
        bottom: 8.0 + bottomPadding, // 시스템 여백 추가
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: _isLoading ? '답변을 기다리는 중...' : '채팅을 입력해 주세요.',
                fillColor: Colors.grey.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}