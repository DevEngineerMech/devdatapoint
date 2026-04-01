import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:devdatapoint/core/services/backend_sync_service.dart';

class NotificationService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    try {
      final token = await messaging.getToken();
      if (token != null && token.trim().isNotEmpty) {
        debugPrint('FCM Token: $token');
        await BackendSyncService.savePushToken(token);
      }
    } catch (e) {
      debugPrint('Failed to get push token: $e');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await BackendSyncService.savePushToken(newToken);
      } catch (e) {
        debugPrint('Failed to refresh push token: $e');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground notification: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.notification?.title}');
    });
  }
}