import 'package:flutter/material.dart';

import 'package:devdatapoint/core/notifications/notification_preferences_service.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/core/services/api_connection_service.dart';
import 'package:devdatapoint/features/settings/widgets/settings_tile.dart';
import 'package:devdatapoint/features/settings/widgets/devdatapoint_about_card.dart';
import 'package:devdatapoint/features/settings/pages/notification_preferences_page.dart';
import 'package:devdatapoint/features/settings/pages/workspace_share_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String notificationSubtitle = 'Choose which alerts you want to receive';

  @override
  void initState() {
    super.initState();
    _loadNotificationSummary();
  }

  Future<void> _loadNotificationSummary() async {
    final isPro = await ApiConnectionService.isProUser();
    final prefs = await NotificationPreferencesService.loadPreferences();

    if (!mounted) return;

    setState(() {
      notificationSubtitle = prefs.summary(isProUser: isPro);
    });
  }

  Future<void> _openNotificationPreferences() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationPreferencesPage(),
      ),
    );

    await _loadNotificationSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Customize your experience and manage how DevDatapoint works for you.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              const DevDatapointAboutCard(),
              const SizedBox(height: 20),
              SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Notification Preferences',
                subtitle: notificationSubtitle,
                onTap: _openNotificationPreferences,
              ),
              const SizedBox(height: 12),
              SettingsTile(
                icon: Icons.groups_rounded,
                title: 'Workspace Sharing',
                subtitle: 'Invite collaborators and share access',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkspaceSharePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & Security',
                subtitle: 'Manage local app privacy options',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Troubleshooting, guides and contact options',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}