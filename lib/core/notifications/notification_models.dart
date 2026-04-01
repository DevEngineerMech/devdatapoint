class AppNotificationPreference {
  final String appStoreId;
  final String appName;
  final bool enabled;
  final bool downloads;
  final bool impressions;
  final bool pageViews;

  const AppNotificationPreference({
    required this.appStoreId,
    required this.appName,
    required this.enabled,
    required this.downloads,
    required this.impressions,
    required this.pageViews,
  });

  factory AppNotificationPreference.fromMap(Map<String, dynamic> map) {
    return AppNotificationPreference(
      appStoreId: (map['appStoreId'] ?? '').toString(),
      appName: (map['appName'] ?? '').toString(),
      enabled: map['enabled'] == true,
      downloads: map['downloads'] == true,
      impressions: map['impressions'] == true,
      pageViews: map['pageViews'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appStoreId': appStoreId,
      'appName': appName,
      'enabled': enabled,
      'downloads': downloads,
      'impressions': impressions,
      'pageViews': pageViews,
    };
  }

  AppNotificationPreference copyWith({
    String? appStoreId,
    String? appName,
    bool? enabled,
    bool? downloads,
    bool? impressions,
    bool? pageViews,
  }) {
    return AppNotificationPreference(
      appStoreId: appStoreId ?? this.appStoreId,
      appName: appName ?? this.appName,
      enabled: enabled ?? this.enabled,
      downloads: downloads ?? this.downloads,
      impressions: impressions ?? this.impressions,
      pageViews: pageViews ?? this.pageViews,
    );
  }
}

class NotificationPreferencesModel {
  final bool enabled;
  final bool genericFreeAlert;
  final bool proDownloads;
  final bool proImpressions;
  final bool proPageViews;
  final bool proCombinedTotals;
  final List<AppNotificationPreference> appPreferences;

  const NotificationPreferencesModel({
    required this.enabled,
    required this.genericFreeAlert,
    required this.proDownloads,
    required this.proImpressions,
    required this.proPageViews,
    required this.proCombinedTotals,
    required this.appPreferences,
  });

  factory NotificationPreferencesModel.freeDefault() {
    return const NotificationPreferencesModel(
      enabled: true,
      genericFreeAlert: true,
      proDownloads: true,
      proImpressions: false,
      proPageViews: false,
      proCombinedTotals: true,
      appPreferences: [],
    );
  }

  factory NotificationPreferencesModel.fromMap(Map<String, dynamic> map) {
    final rawApps = (map['appPreferences'] as List?) ?? [];

    return NotificationPreferencesModel(
      enabled: map['enabled'] != false,
      genericFreeAlert: map['genericFreeAlert'] != false,
      proDownloads: map['proDownloads'] == true,
      proImpressions: map['proImpressions'] == true,
      proPageViews: map['proPageViews'] == true,
      proCombinedTotals: map['proCombinedTotals'] != false,
      appPreferences: rawApps
          .map((e) => AppNotificationPreference.fromMap(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'genericFreeAlert': genericFreeAlert,
      'proDownloads': proDownloads,
      'proImpressions': proImpressions,
      'proPageViews': proPageViews,
      'proCombinedTotals': proCombinedTotals,
      'appPreferences': appPreferences.map((e) => e.toMap()).toList(),
    };
  }

  NotificationPreferencesModel copyWith({
    bool? enabled,
    bool? genericFreeAlert,
    bool? proDownloads,
    bool? proImpressions,
    bool? proPageViews,
    bool? proCombinedTotals,
    List<AppNotificationPreference>? appPreferences,
  }) {
    return NotificationPreferencesModel(
      enabled: enabled ?? this.enabled,
      genericFreeAlert: genericFreeAlert ?? this.genericFreeAlert,
      proDownloads: proDownloads ?? this.proDownloads,
      proImpressions: proImpressions ?? this.proImpressions,
      proPageViews: proPageViews ?? this.proPageViews,
      proCombinedTotals: proCombinedTotals ?? this.proCombinedTotals,
      appPreferences: appPreferences ?? this.appPreferences,
    );
  }

  String summary({required bool isProUser}) {
    if (!enabled) return 'Notifications disabled';

    if (!isProUser) {
      return genericFreeAlert
          ? 'Generic daily updates enabled'
          : 'Free alerts disabled';
    }

    final selected = <String>[];

    if (proDownloads) selected.add('downloads');
    if (proImpressions) selected.add('impressions');
    if (proPageViews) selected.add('page views');

    if (selected.isEmpty) return 'Pro alerts configured';

    return 'Alerts for ${selected.join(', ')}';
  }
}