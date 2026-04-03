import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground notification received: ${message.notification?.title}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification opened app: ${message.notification?.title}');
      });
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }
}