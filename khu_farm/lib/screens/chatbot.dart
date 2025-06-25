import 'package:flutter/material.dart';

void showChatbotModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const ChatbotModal();
    },
  );
}

class ChatbotModal extends StatelessWidget {
  const ChatbotModal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.85, // ✅ 두 번째 이미지처럼 꽉 차게
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 닫기 버튼 + "챗봇"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '챗봇',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 챗봇 말풍선
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/chat/chatbot_icon.png',
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '나쿠',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCF7C5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '궁금한 것이 있으면 질문해 주세요!',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 버튼들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _ChatCategoryButton(label: '질문 내용'),
                _ChatCategoryButton(label: '과일 레시피'),
                _ChatCategoryButton(label: '일반 QnA'),
                _ChatCategoryButton(label: '과일 효능 & 보관법'),
              ],
            ),
            const Spacer(),

            // 입력창
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '채팅을 입력해 주세요.',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatCategoryButton extends StatelessWidget {
  final String label;

  const _ChatCategoryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: const BorderSide(color: Colors.black),
      ),
      onPressed: () {},
      child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
    );
  }
}