import 'dart:async';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // For http calls
import 'package:pedometer/pedometer.dart';
import 'package:khu_farm/constants.dart'; // For baseUrl
import 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  int _todayStepBaseline = 0;
  String _lastSavedDate = '';

  /// 만보기 서비스 초기화
  void init() async {
    if (_pedometerSubscription != null) return;

    print("PedometerService 초기화 시작...");

    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    
    _lastSavedDate = prefs.getString('lastSavedDate') ?? '';

    // ✨ 앱 시작 시 날짜가 다르면, 저장된 기준점을 0으로 초기화
    if (_lastSavedDate != today) {
      _todayStepBaseline = 0;
      await prefs.setInt('todayStepBaseline', 0);
    } else {
      _todayStepBaseline = prefs.getInt('todayStepBaseline') ?? 0;
    }

    _pedometerSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        final currentTotalSteps = event.steps;
        final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());

        // 날짜가 바뀌었거나, 기준점이 아직 설정되지 않은 경우 (앱 설치 후 첫 실행 등)
        if (_lastSavedDate != todayStr) {
          print("날짜가 변경되었습니다. 걸음 수 기준점을 새로 설정합니다.");
          _todayStepBaseline = currentTotalSteps;
          _lastSavedDate = todayStr;

          await prefs.setInt('todayStepBaseline', _todayStepBaseline);
          await prefs.setString('lastSavedDate', _lastSavedDate);
        }
        
        // ✨ 휴대폰 재부팅으로 누적값이 초기화된 경우 처리
        if (currentTotalSteps < _todayStepBaseline) {
          print("재부팅이 감지되었습니다. 걸음 수 기준점을 재설정합니다.");
          _todayStepBaseline = currentTotalSteps;
          await prefs.setInt('todayStepBaseline', _todayStepBaseline);
        }

        int todaySteps = currentTotalSteps - _todayStepBaseline;

        print('[PedometerService] 원본: $currentTotalSteps, 기준점: $_todayStepBaseline, 오늘 걸음: $todaySteps');
        
        _stepCountController.add(todaySteps);
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