import 'dart:async';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // For http calls
import 'package:pedometer/pedometer.dart';
import 'package:khu_farm/constants.dart'; // For baseUrl
import 'storage_service.dart';

/// 만보기 데이터 관리를 위한 서비스 클래스 (싱글턴)
class PedometerService {
  // 싱글턴 인스턴스 생성
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  // 외부에서 걸음 수 데이터를 구독할 수 있는 스트림
  final _stepCountController = StreamController<int>.broadcast();
  Stream<int> get stepCountStream => _stepCountController.stream;

  // pedometer 패키지의 스트림 구독 객체
  StreamSubscription<StepCount>? _pedometerSubscription;

  /// 만보기 서비스 초기화
  void init() {
    if (_pedometerSubscription != null) return; // 중복 초기화 방지

    print("PedometerService 초기화 시작...");

    _pedometerSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        // 센서에서 새로운 걸음 수 데이터가 오면 스트림에 추가
        _stepCountController.add(event.steps);
      },
      onError: (error) {
        print("PedometerService 에러: $error");
        _stepCountController.addError('센서 오류');
      },
      cancelOnError: true,
    );
  }

  Future<void> updateStepCount(int steps) async {
    // 1. Get authentication token
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      print('Cannot send steps: User is not logged in.');
      return;
    }

    // 2. Prepare the request (headers, URI, body)
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    
    // TODO: Replace with your actual API endpoint
    final uri = Uri.parse('$baseUrl/users/steps'); 
    
    final body = jsonEncode({
      'steps': steps,
      'date': DateTime.now().toIso8601String(), // Sending the date is good practice
    });

    // 3. Make the API call
    try {
      // Typically, you'd use a POST or PUT request to send data
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Successfully sent step count to server.');
      } else {
        print('Failed to send step count. Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('An error occurred while sending step count: $e');
    }
  }

  /// 서비스 종료 (앱 종료 시 호출 가능)
  void dispose() {
    _pedometerSubscription?.cancel();
    _pedometerSubscription = null;
    print("PedometerService 종료.");
  }
}