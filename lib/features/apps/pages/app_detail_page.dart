import 'package:flutter/material.dart';

import 'package:devdatapoint/core/theme/app_theme.dart';

class AppDetailPage extends StatelessWidget {
  final Map<String, String> app;

  const AppDetailPage({
    super.key,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final appName = app['name'] ?? 'Unnamed App';

    final downloads = int.tryParse(app['downloads'] ?? '0') ?? 0;
    final impressions = int.tryParse(app['impressions'] ?? '0') ?? 0;
    final sessions = int.tryParse(app['sessions'] ?? '0') ?? 0;
    final avgPlayTime = double.tryParse(app['avgPlayTime'] ?? '0') ?? 0;

    final conversion = impressions == 0 ? 0.0 : (downloads / impressions) * 100;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          appName,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          _infoCard(
            title: 'App Overview',
            body:
                'This app is now connected to your DevDatapoint workspace and ready for live Apple metric syncing.',
          ),
          const SizedBox(height: 16),
          _metricGrid(
            downloads: downloads,
            impressions: impressions,
            sessions: sessions,
            avgPlayTime: avgPlayTime,
            conversion: conversion,
          ),
          const SizedBox(height: 16),
          _infoCard(
            title: 'App Store ID',
            body: app['appStoreId']?.isNotEmpty == true
                ? app['appStoreId']!
                : 'Not added yet',
          ),
          const SizedBox(height: 16),
          _infoCard(
            title: 'Bundle ID',
            body: app['bundleId']?.isNotEmpty == true
                ? app['bundleId']!
                : 'Not added yet',
          ),
        ],
      ),
    );
  }

  Widget _metricGrid({
    required int downloads,
    required int impressions,
    required int sessions,
    required double avgPlayTime,
    required double conversion,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.18,
      children: [
        _metricCard('Downloads', '$downloads'),
        _metricCard('Impressions', '$impressions'),
        _metricCard('Conversion', '${conversion.toStringAsFixed(1)}%'),
        _metricCard(
          'Avg Play Time',
          avgPlayTime <= 0 ? '—' : '${avgPlayTime.toStringAsFixed(1)}m',
        ),
        _metricCard('Sessions', '$sessions'),
      ],
    );
  }

  Widget _metricCard(String title, String value) {
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
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}