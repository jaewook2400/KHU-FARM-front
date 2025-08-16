class NotificationModel {
  final int notificationId;
  final String title;
  final String content;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.content,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'],
      title: json['title'],
      content: json['content'],
    );
  }
}