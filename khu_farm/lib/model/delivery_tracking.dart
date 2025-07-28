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
  final String? deliveryNumber;
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
    this.deliveryNumber,
  });

  factory DeliveryTrackingData.fromJson(Map<String, dynamic> json) {
    // API 응답 전체('result')가 들어왔는지,
    // 기존처럼 'deliveryStatus' 객체만 들어왔는지 확인
    final bool isNewStructure = json.containsKey('deliveryStatus');

    // 실제 배송 정보가 담긴 JSON 부분을 선택
    final deliveryStatusJson = isNewStructure ? json['deliveryStatus'] : json;

    // progresses 리스트 파싱
    var progressList = (deliveryStatusJson['progresses'] as List?) ?? [];
    List<DeliveryProgress> progresses =
        progressList.map((i) => DeliveryProgress.fromJson(i)).toList();

    return DeliveryTrackingData(
      // 새로운 구조일 경우에만 deliveryNumber를 할당
      deliveryNumber: isNewStructure ? json['deliveryNumber'] : null,
      carrierName: deliveryStatusJson['carrier']?['name'] ?? 'N/A',
      fromName: deliveryStatusJson['from']?['name'] ?? '',
      toName: deliveryStatusJson['to']?['name'] ?? '',
      currentStateText: deliveryStatusJson['state']?['text'] ?? '알 수 없음',
      progresses: progresses,
    );
  }

  
  // 👇 DeliveryTrackingData의 toString() 메서드
  @override
  String toString() {
    return 'DeliveryTrackingData(deliveryNumber: $deliveryNumber, carrierName: $carrierName, fromName: $fromName, toName: $toName, currentStateText: $currentStateText, progresses: $progresses)';
  }
}