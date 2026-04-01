import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:devdatapoint/core/notifications/notification_models.dart';
import 'package:devdatapoint/core/services/api_connection_service.dart';
import 'package:devdatapoint/core/services/backend_sync_service.dart';

class NotificationPreferencesService {
  static const String _prefsKey = 'devdp_notification_preferences';

  static Future<NotificationPreferencesModel> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    NotificationPreferencesModel model;

    if (raw == null || raw.trim().isEmpty) {
      model = NotificationPreferencesModel.freeDefault();
    } else {
      try {
        model = NotificationPreferencesModel.fromMap(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
      } catch (_) {
        model = NotificationPreferencesModel.freeDefault();
      }
    }

    final apps = await ApiConnectionService.getSavedApps();

    final mergedApps = apps.map((app) {
      final appStoreId = (app['appStoreId'] ?? '').trim();
      final appName = (app['name'] ?? '').trim();

      final existing = model.appPreferences.where((e) => e.appStoreId == appStoreId);

      if (existing.isNotEmpty) {
        return existing.first.copyWith(appName: appName);
      }

      return AppNotificationPreference(
        appStoreId: appStoreId,
        appName: appName,
        enabled: false,
        downloads: true,
        impressions: false,
        pageViews: false,
      );
    }).toList();

    return model.copyWith(appPreferences: mergedApps);
  }

  static Future<void> savePreferences(NotificationPreferencesModel model) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_prefsKey, jsonEncode(model.toMap()));
    await BackendSyncService.uploadNotificationPreferences(model.toMap());
  }
}