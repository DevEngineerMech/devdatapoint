import 'package:flutter/material.dart';

import 'package:devdatapoint/core/services/api_connection_service.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/features/apps/pages/link_api_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  bool isLinked = false;
  bool isSyncing = false;
  List<Map<String, String>> apps = [];

  int totalDownloads = 0;
  int totalImpressions = 0;
  double conversionRate = 0;
  double averagePlayTime = 0;

  @override
  void initState() {
    super.initState();
    _loadState(syncFirst: true);
  }

  Future<void> _loadState({bool syncFirst = false}) async {
    final linked = await ApiConnectionService.isLinked();

    if (linked && syncFirst) {
      try {
        await ApiConnectionService.syncNow();
      } catch (_) {}
    }

    final savedApps = await ApiConnectionService.getSavedApps();
    final totals = await ApiConnectionService.getDashboardTotals();

    if (!mounted) return;

    setState(() {
      isLinked = linked;
      apps = savedApps;
      totalDownloads = totals['downloads'] as int;
      totalImpressions = totals['impressions'] as int;
      conversionRate = (totals['conversionRate'] as num).toDouble();
      averagePlayTime = (totals['averagePlayTime'] as num).toDouble();
      isLoading = false;
    });
  }

  Future<void> _syncNow() async {
    if (!isLinked) return;

    setState(() => isSyncing = true);

    try {
      await ApiConnectionService.syncNow();
      await _loadState();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync complete.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync failed.')),
      );
    } finally {
      if (mounted) {
        setState(() => isSyncing = false);
      }
    }
  }

  Future<void> _openLinkApiPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const LinkApiPage(),
      ),
    );

    if (result == true) {
      await _loadState(syncFirst: true);
    }
  }

  String _formatWhole(int value) {
    return value.toString();
  }

  String _formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  String _formatPlayTime(double minutes) {
    if (minutes <= 0) return '—';
    return '${minutes.toStringAsFixed(1)}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : RefreshIndicator(
                onRefresh: () => _loadState(syncFirst: true),
                color: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        apps.isEmpty
                            ? 'Your main App Store overview lives here.'
                            : 'Combined lifetime totals across ${apps.length} linked app${apps.length == 1 ? '' : 's'}.',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (!isLinked) _linkApiHero() else _linkedHero(),
                      const SizedBox(height: 18),
                      if (isLinked)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSyncing ? null : _syncNow,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: isSyncing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Icon(Icons.sync_rounded),
                            label: Text(
                              isSyncing ? 'Syncing...' : 'Sync Apple Data',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      if (isLinked) const SizedBox(height: 18),
                      _sectionTitle('Overview'),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.16,
                        children: [
                          _MetricCard(
                            title: 'Downloads',
                            value: _formatWhole(totalDownloads),
                            subtitle:
                                apps.isEmpty ? 'No linked apps yet' : 'Lifetime total',
                          ),
                          _MetricCard(
                            title: 'Impressions',
                            value: _formatWhole(totalImpressions),
                            subtitle:
                                apps.isEmpty ? 'No linked apps yet' : 'Lifetime total',
                          ),
                          _MetricCard(
                            title: 'Conversion',
                            value: _formatPercent(conversionRate),
                            subtitle: 'Downloads ÷ impressions',
                          ),
                          _MetricCard(
                            title: 'Avg Play Time',
                            value: _formatPlayTime(averagePlayTime),
                            subtitle: 'Weighted average',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('Linked Apps'),
                      const SizedBox(height: 14),
                      if (apps.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Text(
                            'No apps added yet. Link your API and add your first app to start filling this dashboard.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        )
                      else
                        ...apps.map((app) {
                          final downloads = int.tryParse(app['downloads'] ?? '0') ?? 0;
                          final impressions = int.tryParse(app['impressions'] ?? '0') ?? 0;
                          final avgPlayTime =
                              double.tryParse(app['avgPlayTime'] ?? '0') ?? 0;

                          final appConversion = impressions == 0
                              ? 0.0
                              : (downloads / impressions) * 100;

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app['name'] ?? 'Unnamed App',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (app['bundleId'] ?? '').isEmpty
                                      ? 'Bundle ID not added'
                                      : app['bundleId']!,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _miniMetric('Downloads', '$downloads'),
                                    _miniMetric('Impressions', '$impressions'),
                                    _miniMetric(
                                      'Conversion',
                                      '${appConversion.toStringAsFixed(1)}%',
                                    ),
                                    _miniMetric(
                                      'Play Time',
                                      avgPlayTime <= 0
                                          ? '—'
                                          : '${avgPlayTime.toStringAsFixed(1)}m',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkApiHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141D2D),
            Color(0xFF111827),
            Color(0xFF0B1220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Link your Apple API first',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Set up your App Store Connect API details step by step. You can paste your private key or upload the .p8 file from your device.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openLinkApiPage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
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

  Widget _linkedHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.cloud_done_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API linked',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${apps.length} app${apps.length == 1 ? '' : 's'} currently linked.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}