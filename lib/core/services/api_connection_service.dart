import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'backend_sync_service.dart';

class ApiConnectionService {
  static const String _issuerIdKey = 'api_issuer_id';
  static const String _keyIdKey = 'api_key_id';
  static const String _privateKeyKey = 'api_private_key';
  static const String _vendorNumberKey = 'api_vendor_number';
  static const String _linkedAtKey = 'api_linked_at';
  static const String _appsKey = 'api_saved_apps';

  static Future<bool> isLinked() async {
    final prefs = await SharedPreferences.getInstance();
    final issuerId = prefs.getString(_issuerIdKey)?.trim() ?? '';
    final keyId = prefs.getString(_keyIdKey)?.trim() ?? '';
    final privateKey = prefs.getString(_privateKeyKey)?.trim() ?? '';
    return issuerId.isNotEmpty && keyId.isNotEmpty && privateKey.isNotEmpty;
  }

  static Future<Map<String, dynamic>> getConnection() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'issuerId': prefs.getString(_issuerIdKey) ?? '',
      'keyId': prefs.getString(_keyIdKey) ?? '',
      'privateKey': prefs.getString(_privateKeyKey) ?? '',
      'vendorNumber': prefs.getString(_vendorNumberKey) ?? '',
      'linkedAt': prefs.getString(_linkedAtKey) ?? '',
    };
  }

  static Future<void> saveConnection({
    required String issuerId,
    required String keyId,
    required String privateKey,
    String vendorNumber = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalisedPrivateKey = _normalisePrivateKey(privateKey);

    await prefs.setString(_issuerIdKey, issuerId.trim());
    await prefs.setString(_keyIdKey, keyId.trim());
    await prefs.setString(_privateKeyKey, normalisedPrivateKey);
    await prefs.setString(_vendorNumberKey, vendorNumber.trim());
    await prefs.setString(_linkedAtKey, DateTime.now().toIso8601String());

    final isPro = await isProUser();

    await BackendSyncService.uploadConnection(
      issuerId: issuerId.trim(),
      keyId: keyId.trim(),
      privateKey: normalisedPrivateKey,
      vendorNumber: vendorNumber.trim(),
      isPro: isPro,
    );
  }

  static Future<void> saveApps(List<Map<String, String>> apps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appsKey, jsonEncode(apps));
    await BackendSyncService.uploadApps(apps);
  }

  static Future<List<Map<String, String>>> getSavedApps() async {
    try {
      final backendApps = await BackendSyncService.fetchAppsFromBackend();
      if (backendApps.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_appsKey, jsonEncode(backendApps));
        return backendApps;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_appsKey);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => {
              'name': (item['name'] ?? '').toString(),
              'iconUrl': (item['iconUrl'] ?? '').toString(),
              'appStoreId': (item['appStoreId'] ?? '').toString(),
              'bundleId': (item['bundleId'] ?? '').toString(),
              'downloads': (item['downloads'] ?? '0').toString(),
              'impressions': (item['impressions'] ?? '0').toString(),
              'avgPlayTime': (item['avgPlayTime'] ?? '0').toString(),
              'sessions': (item['sessions'] ?? '0').toString(),
            },
          )
          .where((app) => (app['name'] ?? '').trim().isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addApp(Map<String, String> app) async {
    final apps = await getSavedApps();
    apps.add(app);
    await saveApps(apps);
  }

  static Future<void> removeAppAt(int index) async {
    final apps = await getSavedApps();
    if (index >= 0 && index < apps.length) {
      apps.removeAt(index);
      await saveApps(apps);
    }
  }

  static Future<void> clearConnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_issuerIdKey);
    await prefs.remove(_keyIdKey);
    await prefs.remove(_privateKeyKey);
    await prefs.remove(_vendorNumberKey);
    await prefs.remove(_linkedAtKey);
    await prefs.remove(_appsKey);
  }

  static Future<bool> isProUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_pro_user') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<int> getAppLimit() async {
    final isPro = await isProUser();
    return isPro ? 5 : 1;
  }

  static Future<bool> canAddAnotherApp() async {
    final apps = await getSavedApps();
    final limit = await getAppLimit();
    return apps.length < limit;
  }

  static Future<Map<String, dynamic>> getDashboardTotals() async {
    final apps = await getSavedApps();

    int totalDownloads = 0;
    int totalImpressions = 0;
    int totalSessions = 0;
    double weightedPlayTimeSum = 0;

    for (final app in apps) {
      final downloads = int.tryParse(app['downloads'] ?? '0') ?? 0;
      final impressions = int.tryParse(app['impressions'] ?? '0') ?? 0;
      final avgPlayTime = double.tryParse(app['avgPlayTime'] ?? '0') ?? 0;
      final sessions = int.tryParse(app['sessions'] ?? '0') ?? 0;

      totalDownloads += downloads;
      totalImpressions += impressions;
      totalSessions += sessions;
      weightedPlayTimeSum += avgPlayTime * sessions;
    }

    final conversionRate = totalImpressions == 0
        ? 0.0
        : (totalDownloads / totalImpressions) * 100;

    final averagePlayTime = totalSessions == 0
        ? 0.0
        : weightedPlayTimeSum / totalSessions;

    return {
      'linkedAppsCount': apps.length,
      'downloads': totalDownloads,
      'impressions': totalImpressions,
      'conversionRate': conversionRate,
      'averagePlayTime': averagePlayTime,
    };
  }

  static Future<void> syncNow() async {
    await BackendSyncService.syncNowFromBackend(force: true);
  }

  static String _normalisePrivateKey(String value) {
    final trimmed = value.trim();

    if (trimmed.contains('BEGIN PRIVATE KEY')) {
      return trimmed;
    }

    return [
      '-----BEGIN PRIVATE KEY-----',
      trimmed,
      '-----END PRIVATE KEY-----',
    ].join('\n');
  }
}