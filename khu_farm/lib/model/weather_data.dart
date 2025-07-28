// lib/models/weather_data.dart (새 파일)

class WeatherData {
  final String pty; // 강수형태
  final String sky; // 하늘상태
  final String tempMin; // 최저기온
  final String tempMax; // 최고기온

  WeatherData({
    required this.pty,
    required this.sky,
    required this.tempMin,
    required this.tempMax,
  });
}