// lib/models/delivery_tracking.dart

class DeliveryProgress {
  final String time;
  final String statusText;
  final String locationName;
  final String description;

  DeliveryProgress({
    required this.time,
    required this.statusText,
    required this.locationName,
    required this.description,
  });

  factory DeliveryProgress.fromJson(Map<String, dynamic> json) {
    return DeliveryProgress(
      time: json['time'] ?? '',
      statusText: json['status']?['text'] ?? 'N/A',
      locationName: json['location']?['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  // 👇 DeliveryProgress의 toString() 메서드
  @override
  String toString() {
    return 'DeliveryProgress(time: $time, statusText: $statusText, locationName: $locationName, description: $description)';
  }
}

class DeliveryTrackingData {
  final String carrierName;
  final String fromName;
  final String toName;
  final String currentStateText;
  final List<DeliveryProgress> progresses;

  DeliveryTrackingData({
    required this.carrierName,
    required this.fromName,
    required this.toName,
    required this.currentStateText,
    required this.progresses,
  });

  factory DeliveryTrackingData.fromJson(Map<String, dynamic> json) {
    var progressList = json['progresses'] as List;
    List<DeliveryProgress> progresses =
        progressList.map((i) => DeliveryProgress.fromJson(i)).toList();

    return DeliveryTrackingData(
      carrierName: json['carrier']?['name'] ?? 'N/A',
      fromName: json['from']?['name'] ?? '',
      toName: json['to']?['name'] ?? '',
      currentStateText: json['state']?['text'] ?? '알 수 없음',
      progresses: progresses,
    );
  }
  
  // 👇 DeliveryTrackingData의 toString() 메서드
  @override
  String toString() {
    return 'DeliveryTrackingData(carrierName: $carrierName, fromName: $fromName, toName: $toName, currentStateText: $currentStateText, progresses: $progresses)';
  }
}