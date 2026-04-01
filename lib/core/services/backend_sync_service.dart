import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class BackendSyncService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const String _deviceIdKey = 'devdp_device_id';

  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);

    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final newId = const Uuid().v4();
    await prefs.setString(_deviceIdKey, newId);
    return newId;
  }

  static Future<String> ensureUserExists() async {
    final deviceId = await getOrCreateDeviceId();

    final existing = await _supabase
        .from('devdp_users')
        .select('id')
        .eq('device_id', deviceId)
        .maybeSingle();

    if (existing != null && existing['id'] != null) {
      return existing['id'] as String;
    }

    final inserted = await _supabase
        .from('devdp_users')
        .insert({
          'device_id': deviceId,
        })
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  static Future<void> uploadConnection({
    required String issuerId,
    required String keyId,
    required String privateKey,
    required String vendorNumber,
    required bool isPro,
  }) async {
    final userId = await ensureUserExists();

    final existing = await _supabase
        .from('devdp_connections')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null && existing['id'] != null) {
      await _supabase
          .from('devdp_connections')
          .update({
            'issuer_id': issuerId,
            'key_id': keyId,
            'private_key': privateKey,
            'vendor_number': vendorNumber,
            'is_pro': isPro,
          })
          .eq('user_id', userId);
    } else {
      await _supabase.from('devdp_connections').insert({
        'user_id': userId,
        'issuer_id': issuerId,
        'key_id': keyId,
        'private_key': privateKey,
        'vendor_number': vendorNumber,
        'is_pro': isPro,
      });
    }
  }

  static Future<void> uploadApps(List<Map<String, String>> apps) async {
    final userId = await ensureUserExists();

    await _supabase.from('devdp_apps').delete().eq('user_id', userId);

    for (final app in apps) {
      await _supabase.from('devdp_apps').insert({
        'user_id': userId,
        'name': app['name'] ?? '',
        'icon_url': app['iconUrl'] ?? '',
        'app_store_id': app['appStoreId'] ?? '',
        'bundle_id': app['bundleId'] ?? '',
        'downloads': int.tryParse(app['downloads'] ?? '0') ?? 0,
        'impressions': int.tryParse(app['impressions'] ?? '0') ?? 0,
        'avg_play_time': double.tryParse(app['avgPlayTime'] ?? '0') ?? 0,
        'sessions': int.tryParse(app['sessions'] ?? '0') ?? 0,
      });
    }
  }

  static Future<List<Map<String, String>>> fetchAppsFromBackend() async {
    final userId = await ensureUserExists();

    final rows = await _supabase
        .from('devdp_apps')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (rows as List<dynamic>).map((item) {
      return {
        'name': (item['name'] ?? '').toString(),
        'iconUrl': (item['icon_url'] ?? '').toString(),
        'appStoreId': (item['app_store_id'] ?? '').toString(),
        'bundleId': (item['bundle_id'] ?? '').toString(),
        'downloads': (item['downloads'] ?? 0).toString(),
        'impressions': (item['impressions'] ?? 0).toString(),
        'avgPlayTime': (item['avg_play_time'] ?? 0).toString(),
        'sessions': (item['sessions'] ?? 0).toString(),
      };
    }).toList();
  }

  static Future<void> syncNowFromBackend({bool force = false}) async {
    final userId = await ensureUserExists();

    await _supabase.functions.invoke(
      'sync_apple_data',
      body: {
        'user_id': userId,
        'force': force,
      },
    );
  }

  static Future<void> savePushToken(String token) async {
    final userId = await ensureUserExists();

    final existing = await _supabase
        .from('devdp_device_tokens')
        .select('id')
        .eq('user_id', userId)
        .eq('token', token)
        .maybeSingle();

    if (existing != null && existing['id'] != null) return;

    await _supabase.from('devdp_device_tokens').insert({
      'user_id': userId,
      'token': token,
      'platform': 'ios',
    });
  }

  static Future<void> uploadNotificationPreferences(
    Map<String, dynamic> preferences,
  ) async {
    final userId = await ensureUserExists();

    final existing = await _supabase
        .from('devdp_notification_preferences')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    final payload = {
      'user_id': userId,
      'enabled': preferences['enabled'] == true,
      'generic_free_alert': preferences['genericFreeAlert'] == true,
      'pro_downloads': preferences['proDownloads'] == true,
      'pro_impressions': preferences['proImpressions'] == true,
      'pro_page_views': preferences['proPageViews'] == true,
      'pro_combined_totals': preferences['proCombinedTotals'] == true,
      'app_preferences': preferences['appPreferences'] ?? [],
    };

    if (existing != null && existing['id'] != null) {
      await _supabase
          .from('devdp_notification_preferences')
          .update(payload)
          .eq('user_id', userId);
    } else {
      await _supabase.from('devdp_notification_preferences').insert(payload);
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPendingNotificationEvents() async {
    final userId = await ensureUserExists();

    final rows = await _supabase
        .from('devdp_notification_events')
        .select()
        .eq('user_id', userId)
        .isFilter('sent_at', null)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> markNotificationEventSent(String id) async {
    await _supabase
        .from('devdp_notification_events')
        .update({'sent_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
}