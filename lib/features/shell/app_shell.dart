import 'package:flutter/material.dart';

import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/features/apps/apps_page.dart';
import 'package:devdatapoint/features/dashboard/dashboard_page.dart';
import 'package:devdatapoint/features/pro/pro_page.dart';
import 'package:devdatapoint/features/settings/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  late final List<Widget> _pages = [
    const DashboardPage(),
    const AppsPage(),
    const ProPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              indicatorColor: AppTheme.primary.withValues(alpha: 0.16),
              elevation: 0,
              selectedIndex: currentIndex,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: (index) {
                setState(() => currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_rounded),
                  selectedIcon: Icon(Icons.dashboard_customize_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.apps_rounded),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Apps',
                ),
                NavigationDestination(
                  icon: Icon(Icons.workspace_premium_rounded),
                  selectedIcon: Icon(Icons.star_rounded),
                  label: 'Pro',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  selectedIcon: Icon(Icons.tune_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}