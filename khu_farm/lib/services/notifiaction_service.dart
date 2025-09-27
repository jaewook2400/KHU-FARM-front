import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:khu_farm/constants.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    final data = message.data['data'];
    print('Background data: $data');
  }

  if (message.data.containsKey('notification')) {
    final notification = message.data['notification'];
    print('Background notification: $notification');
  }

  print('Handling a background message: ${message.messageId}');
}

Future<void> saveFcmTokenToServer() async {
  try {
    // 1. 기기의 FCM 토큰 가져오기
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      print('FCM 토큰 발급에 실패했습니다.');
      return;
    }
    print('FCM Token: $fcmToken');

    // 2. 스토리지에서 JWT 액세스 토큰 가져오기
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      print('로그인 토큰이 없습니다.');
      return;
    }

    // 3. API 요청 준비
    final uri = Uri.parse('$baseUrl/notification/saveToken');
    
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json', // JSON 데이터를 보낼 때 필수
    };

    final body = jsonEncode({
      'fcmToken': fcmToken,
    });

    // 4. 서버에 POST 요청 보내기
    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('FCM 토큰이 서버에 성공적으로 저장되었습니다.');
    } else {
      print('FCM 토큰 저장 실패: ${response.statusCode}');
      print('응답 내용: ${response.body}');
    }
  } catch (e) {
    print('FCM 토큰 저장 중 오류 발생: $e');
  }
}

class FCM {
  final streamCtrl = StreamController<String>.broadcast();
  final titleCtrl = StreamController<String>.broadcast();
  final bodyCtrl = StreamController<String>.broadcast();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FCM({required this.flutterLocalNotificationsPlugin});

  setNotifications() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    foregroundNotification();

    backgroundNotification();

    terminateNotification();

    // FCM 토큰 갱신 처리 추가
    //_listenTokenRefresh();
  }

  void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("🔄 새로운 FCM 토큰 발급됨: $newToken");
      await saveFcmTokenToServer(); // 서버에 갱신 저장
    });
  }

  foregroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("포그라운드에서 메시지 수신:");
      print("Message data: ${message.data}");

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        
        flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'fcm_default_channel', // main.dart에서 생성한 채널 ID
                'High Importance Notifications', // main.dart에서 생성한 채널 이름
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              )
            ),
          );
      }
    });
  }

  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("notification received");
      if (message.data.containsKey('data')) {
        streamCtrl.sink.add(message.data['data']);
      }
      if (message.data.containsKey('notification')) {
        streamCtrl.sink.add(message.data['notification']);
      }

      titleCtrl.sink.add(message.notification!.title!);
      bodyCtrl.sink.add(message.notification!.body!);
    });
  }

  terminateNotification()async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.data.containsKey('data')) {
        streamCtrl.sink.add(initialMessage.data['data']);
      }
      if (initialMessage.data.containsKey('notification')) {
        streamCtrl.sink.add(initialMessage.data['notification']);
      }

      titleCtrl.sink.add(initialMessage.notification!.title!);
      bodyCtrl.sink.add(initialMessage.notification!.body!);
    }
  }

  dispose() {
    streamCtrl.close();
    titleCtrl.close();
    bodyCtrl.close();
  }
}