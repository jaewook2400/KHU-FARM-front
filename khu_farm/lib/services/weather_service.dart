// lib/services/weather_service.dart (새 파일)

import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khu_farm/model/weather_data.dart'; // 방금 만든 모델

class WeatherService {
  // ⚠️ 1단계에서 발급받은 본인의 일반 인증키(Decoding)를 여기에 입력하세요.
  final String _apiKey = 'CL3o%2Bj7cJRtr8SimUvjVKv881sSWxo0tCNkos6aJN02lgtakIG7kzNOmihmo6eYY4N9sxjo0RKYKfFxRIz8Zmg%3D%3D';
  final String _baseUrl = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst';

  Future<WeatherData> getWeatherData() async {
    try {
      Position position = await _getCurrentLocation();
      final gridCoords = _convertToGrid(position.latitude, position.longitude);

      // ✨ [수정] base_date와 base_time을 안정적인 값으로 고정
      final baseDate = DateFormat('yyyyMMdd').format(DateTime.now());
      const baseTime = '0200'; // 오늘의 최저/최고 기온이 모두 포함된 02시 발표 데이터 사용

      // ✨ [수정] numOfRows를 300으로 줄여 속도 개선
      final uri = Uri.parse(
          '$_baseUrl?serviceKey=$_apiKey&pageNo=1&numOfRows=300&dataType=JSON&base_date=$baseDate&base_time=$baseTime&nx=${gridCoords['x']}&ny=${gridCoords['y']}');

      print('--- Requesting Weather API URL ---\n$uri\n---------------------------------');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('--- Full API Response Body ---\n${response.body}\n------------------------------');

        if (jsonData['response']['header']['resultCode'] != '00') {
           final code = jsonData['response']['header']['resultCode'];
           final msg = jsonData['response']['header']['resultMsg'];
           throw Exception('API Error: [$code] $msg');
        }

        final items = jsonData['response']['body']['items']['item'];
        return _parseWeatherData(items);
      } else {
        print('--- HTTP Request Failed ---');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('---------------------------');
        throw Exception('HTTP ${response.statusCode} 에러: 날씨 정보를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('--- An Exception Occurred ---');
      print('Error Type: ${e.runtimeType}');
      print('Error Details: $e');
      print('-----------------------------');
      throw Exception('날씨 정보를 처리하는 중 오류가 발생했습니다.');
    }
  }

  // API 응답 데이터를 파싱하여 필요한 정보(TMN, TMX, SKY, PTY)를 추출하는 함수
  WeatherData _parseWeatherData(List<dynamic> items) {
    String tempMin = '';
    String tempMax = '';
    String sky = '';
    String pty = '';

    // 오늘 날짜를 'YYYYMMDD' 형식으로 가져옴
    String today = DateFormat('yyyyMMdd').format(DateTime.now());

    for (var item in items) {
      // 오늘 예보(fcstDate) 중에서
      if (item['fcstDate'] == today) {
        switch (item['category']) {
          case 'TMN': // 일 최저기온
            tempMin = item['fcstValue'];
            break;
          case 'TMX': // 일 최고기온
            tempMax = item['fcstValue'];
            break;
          case 'SKY': // 하늘 상태 (가장 최근 데이터 사용을 위해 덮어씀)
            sky = item['fcstValue'];
            break;
          case 'PTY': // 강수 형태 (가장 최근 데이터 사용을 위해 덮어씀)
            pty = item['fcstValue'];
            break;
        }
      }
    }

    return WeatherData(pty: pty, sky: sky, tempMin: tempMin, tempMax: tempMax);
  }

  // 기상청 단기예보 API의 발표 시간에 맞춰 base_date와 base_time을 계산
  (String, String) _getBaseDateTime() {
    var now = DateTime.now();
    // API 발표 시간: 02:00, 05:00, 08:00, 11:00, 14:00, 17:00, 20:00, 23:00
    // 각 시간의 10분 이후부터 데이터 조회 가능
    final availableTimes = [2, 5, 8, 11, 14, 17, 20, 23];
    var baseTime = 23; // 기본값은 전날 23시

    for (var time in availableTimes.reversed) {
      if (now.hour > time || (now.hour == time && now.minute >= 10)) {
        baseTime = time;
        break;
      }
    }

    DateTime baseDateTime = DateTime(now.year, now.month, now.day, baseTime);
    // 현재 시간과 가장 가까운 유효한 발표 시간을 찾지 못했다면 전날 23시로 설정
    if (now.hour < 2 || (now.hour == 2 && now.minute < 10)) {
      baseDateTime = baseDateTime.subtract(const Duration(days: 1));
      baseTime = 23;
    }

    return (
      DateFormat('yyyyMMdd').format(baseDateTime),
      '${baseTime.toString().padLeft(2, '0')}00'
    );
  }

  // 위도, 경도를 기상청 격자 X, Y 좌표로 변환하는 함수
  Map<String, int> _convertToGrid(double lat, double lon) {
    // ✨ [디버깅] 함수에 입력된 위도와 경도를 직접 확인합니다.
    print('--- Converting Coordinates ---');
    print('Input Latitude: $lat, Input Longitude: $lon');
    print('----------------------------');

    const double RE = 6371.00877; // 지구 반경(km)
    const double GRID = 5.0; // 격자 간격(km)
    const double SLAT1 = 30.0; // 투영 위도1(도)
    const double SLAT2 = 60.0; // 투영 위도2(도)
    const double OLON = 126.0; // 기준점 경도(도)
    const double OLAT = 38.0; // 기준점 위도(도)
    const int XO = 43; // 기준점 X좌표(격자)
    const int YO = 136; // 기준점 Y좌표(격자)

    const double DEGRAD = pi / 180.0;
    const double RADDEG = 180.0 / pi;

    double re = RE / GRID;
    double slat1 = SLAT1 * DEGRAD;
    double slat2 = SLAT2 * DEGRAD;
    double olon = OLON * DEGRAD;
    double olat = OLAT * DEGRAD;

    double sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
    sn = log(cos(slat1) / cos(slat2)) / log(sn);
    double sf = tan(pi * 0.25 + slat1 * 0.5);
    sf = pow(sf, sn) * cos(slat1) / sn;
    double ro = tan(pi * 0.25 + olat * 0.5);
    ro = re * sf / pow(ro, sn);

    double ra = tan(pi * 0.25 + (lat) * DEGRAD * 0.5);
    ra = re * sf / pow(ra, sn);
    double theta = lon * DEGRAD - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;

    int x = (ra * sin(theta) + XO + 0.5).floor();
    int y = (ro - ra * cos(theta) + YO + 0.5).floor();

    return {'x': x, 'y': y};
  }


  // 위치 권한 처리 및 현재 위치 반환 (이전과 동일)
  Future<Position> _getCurrentLocation() async {
    // ... (이전 답변의 _getCurrentLocation 함수 내용과 동일)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 정보 접근 권한이 거부되었습니다.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 정보 접근 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}