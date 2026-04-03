import 'package:flutter/material.dart';

import 'package:devdatapoint/core/services/api_connection_service.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/features/apps/pages/app_detail_page.dart';
import 'package:devdatapoint/features/apps/pages/link_api_page.dart';
import 'package:devdatapoint/features/apps/pages/add_app_page.dart';
import 'package:devdatapoint/features/apps/widgets/app_card.dart';
import 'package:devdatapoint/features/apps/widgets/empty_apps_state.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  bool isGridView = true;
  bool apiLinked = false;
  List<Map<String, String>> apps = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadApps(syncFirst: true);
  }

  Future<void> _loadApps({bool syncFirst = false, bool forceRefresh = false}) async {
    final connection = await ApiConnectionService.getConnection();

    final issuerId = (connection['issuerId'] ?? '').trim();
    final keyId = (connection['keyId'] ?? '').trim();
    final privateKey = (connection['privateKey'] ?? '').trim();

    final linked =
        issuerId.isNotEmpty && keyId.isNotEmpty && privateKey.isNotEmpty;

    if (linked && syncFirst) {
      try {
        await ApiConnectionService.syncNow();
      } catch (_) {}
    }

    final savedApps =
        await ApiConnectionService.getSavedApps(forceRefresh: forceRefresh);

    if (!mounted) return;

    setState(() {
      apiLinked = linked;
      apps = savedApps;
      isLoading = false;
    });
  }

  Future<void> _openLinkApi() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const LinkApiPage(),
      ),
    );

    if (result == true) {
      await _loadApps(syncFirst: true, forceRefresh: true);
    }
  }

  Future<void> _openAddApp() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAppPage(),
      ),
    );

    if (result == true) {
      await _loadApps(syncFirst: true, forceRefresh: true);
    }
  }

  void _openApp(Map<String, String> app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppDetailPage(app: app),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Apps',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (apps.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() => isGridView = !isGridView);
              },
              icon: Icon(
                isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: AppTheme.textPrimary,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddApp,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => _loadApps(syncFirst: true, forceRefresh: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                children: [
                  if (!apiLinked) ...[
                    _buildLinkApiCard(),
                    const SizedBox(height: 20),
                  ] else ...[
                    _buildApiLinkedCard(),
                    const SizedBox(height: 20),
                  ],
                  if (apps.isEmpty) ...[
                    const EmptyAppsState(),
                    const SizedBox(height: 18),
                    if (apiLinked)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _openAddApp,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Add Your First App',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ] else
                    isGridView ? _buildGrid() : _buildList(),
                ],
              ),
            ),
    );
  }

  Widget _buildLinkApiCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Link your Apple API',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Connect App Store Connect so DevDatapoint can show real app installs, impressions and performance insights.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openLinkApi,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Link API',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiLinkedCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API linked',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your App Store Connect details are saved.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openLinkApi,
            child: const Text(
              'Edit',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: apps.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final app = apps[index];
        return AppCard(
          app: app,
          onTap: () => _openApp(app),
        );
      },
    );
  }

  Widget _buildList() {
    return Column(
      children: List.generate(apps.length, (index) {
        final app = apps[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AppCard(
            app: app,
            compact: true,
            onTap: () => _openApp(app),
          ),
        );
      }),
    );
  }
}