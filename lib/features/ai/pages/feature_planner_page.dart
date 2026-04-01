import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

class FeaturePlannerPage extends StatelessWidget {
  const FeaturePlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Quick win features',
        'body':
            'Small updates that make your app feel noticeably better fast, such as improving onboarding, simplifying buttons, or polishing premium screens.',
      },
      {
        'title': 'Retention features',
        'body':
            'Features that make users come back more often, such as streaks, reminders, progress systems, saved history, or personalisation.',
      },
      {
        'title': 'Revenue features',
        'body':
            'Features that support monetisation, such as gated premium tools, better plan comparison, upgrade prompts, and higher-value premium pages.',
      },
      {
        'title': 'Avoid building too much',
        'body':
            'Not every idea needs building. Focus on the features that improve user experience, retention, or revenue first.',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Feature Planner'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final item = features[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['body']!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}