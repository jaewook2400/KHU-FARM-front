class InquiryReply {
  final String content;
  final String sellerName;
  final String createdAt;

  InquiryReply({
    required this.content,
    required this.sellerName,
    required this.createdAt,
  });

  factory InquiryReply.fromJson(Map<String, dynamic> json) {
    return InquiryReply(
      content: json['content'] ?? '',
      sellerName: json['sellerName'] ?? '판매자',
      createdAt: json['createdAt'] ?? '',
    );
  }

  // ✨ toString() 메서드 추가
  @override
  String toString() {
    return 'InquiryReply(content: $content, sellerName: $sellerName, createdAt: $createdAt)';
  }
}

class Inquiry {
  final int inquiryId;
  final String content;
  final String createdAt;
  final InquiryReply? reply;
  final bool isPrivate;

  Inquiry({
    required this.inquiryId,
    required this.content,
    required this.createdAt,
    this.reply,
    required this.isPrivate,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      inquiryId: json['inquiryId'] ?? 0,
      content: json['content'] ?? '내용 없음',
      createdAt: json['createdAt'] ?? '',
      reply: json['reply'] != null ? InquiryReply.fromJson(json['reply']) : null,
      isPrivate: json['private'] ?? false,
    );
  }

  // ✨ toString() 메서드 추가
  @override
  String toString() {
    return 'Inquiry(inquiryId: $inquiryId, content: $content, createdAt: $createdAt, reply: $reply, isPrivate: $isPrivate)';
  }
}