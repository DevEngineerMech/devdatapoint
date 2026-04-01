import 'package:flutter/material.dart';

import 'package:devdatapoint/core/notifications/notification_models.dart';
import 'package:devdatapoint/core/notifications/notification_preferences_service.dart';
import 'package:devdatapoint/core/services/api_connection_service.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool isLoading = true;
  bool isSaving = false;
  bool isProUser = false;
  NotificationPreferencesModel preferences =
      NotificationPreferencesModel.freeDefault();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pro = await ApiConnectionService.isProUser();
    final loaded = await NotificationPreferencesService.loadPreferences();

    if (!mounted) return;

    setState(() {
      isProUser = pro;
      preferences = loaded;
      isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => isSaving = true);

    await NotificationPreferencesService.savePreferences(preferences);

    if (!mounted) return;

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved.')),
    );
  }

  void _updateAppPreference(
    String appStoreId,
    AppNotificationPreference Function(AppNotificationPreference current)
        transform,
  ) {
    final updated = preferences.appPreferences.map((app) {
      if (app.appStoreId == appStoreId) {
        return transform(app);
      }
      return app;
    }).toList();

    setState(() {
      preferences = preferences.copyWith(appPreferences: updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Notification Preferences',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                _sectionCard(
                  title: 'General',
                  children: [
                    SwitchListTile.adaptive(
                      value: preferences.enabled,
                      onChanged: (value) {
                        setState(() {
                          preferences = preferences.copyWith(enabled: value);
                        });
                      },
                      title: const Text(
                        'Enable notifications',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      subtitle: const Text(
                        'Master toggle for all DevDatapoint alerts',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isProUser) _buildFreeSection(),
                if (isProUser) _buildProSection(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    isSaving ? 'Saving...' : 'Save Preferences',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFreeSection() {
    return _sectionCard(
      title: 'Free Notifications',
      children: [
        SwitchListTile.adaptive(
          value: preferences.genericFreeAlert,
          onChanged: preferences.enabled
              ? (value) {
                  setState(() {
                    preferences =
                        preferences.copyWith(genericFreeAlert: value);
                  });
                }
              : null,
          title: const Text(
            'Generic latest data alerts',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          subtitle: const Text(
            'Examples: "Your latest downloads data is now available"',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildProSection() {
    return Column(
      children: [
        _sectionCard(
          title: 'Pro Combined Alerts',
          children: [
            SwitchListTile.adaptive(
              value: preferences.proDownloads,
              onChanged: preferences.enabled
                  ? (value) {
                      setState(() {
                        preferences =
                            preferences.copyWith(proDownloads: value);
                      });
                    }
                  : null,
              title: const Text(
                'Downloads',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
            SwitchListTile.adaptive(
              value: preferences.proImpressions,
              onChanged: preferences.enabled
                  ? (value) {
                      setState(() {
                        preferences =
                            preferences.copyWith(proImpressions: value);
                      });
                    }
                  : null,
              title: const Text(
                'Impressions',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
            SwitchListTile.adaptive(
              value: preferences.proPageViews,
              onChanged: preferences.enabled
                  ? (value) {
                      setState(() {
                        preferences =
                            preferences.copyWith(proPageViews: value);
                      });
                    }
                  : null,
              title: const Text(
                'Page Views',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
            SwitchListTile.adaptive(
              value: preferences.proCombinedTotals,
              onChanged: preferences.enabled
                  ? (value) {
                      setState(() {
                        preferences =
                            preferences.copyWith(proCombinedTotals: value);
                      });
                    }
                  : null,
              title: const Text(
                'Send totals across all connected apps',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: const Text(
                'Example: "Your apps got 12 downloads yesterday"',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Per-App Pro Alerts',
          children: preferences.appPreferences.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No apps added yet.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ]
              : preferences.appPreferences
                  .map((app) => _appPreferenceCard(app))
                  .toList(),
        ),
      ],
    );
  }

  Widget _appPreferenceCard(AppNotificationPreference app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: app.enabled,
            onChanged: preferences.enabled
                ? (value) {
                    _updateAppPreference(
                      app.appStoreId,
                      (current) => current.copyWith(enabled: value),
                    );
                  }
                : null,
            title: Text(
              app.appName.isEmpty ? 'Unnamed App' : app.appName,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            subtitle: Text(
              app.appStoreId.isEmpty
                  ? 'No App Store ID added'
                  : 'App Store ID: ${app.appStoreId}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          if (app.enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: app.downloads,
                    onChanged: preferences.enabled
                        ? (value) {
                            _updateAppPreference(
                              app.appStoreId,
                              (current) =>
                                  current.copyWith(downloads: value ?? false),
                            );
                          }
                        : null,
                    title: const Text(
                      'Downloads',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: app.impressions,
                    onChanged: preferences.enabled
                        ? (value) {
                            _updateAppPreference(
                              app.appStoreId,
                              (current) => current.copyWith(
                                impressions: value ?? false,
                              ),
                            );
                          }
                        : null,
                    title: const Text(
                      'Impressions',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: app.pageViews,
                    onChanged: preferences.enabled
                        ? (value) {
                            _updateAppPreference(
                              app.appStoreId,
                              (current) =>
                                  current.copyWith(pageViews: value ?? false),
                            );
                          }
                        : null,
                    title: const Text(
                      'Page Views',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}