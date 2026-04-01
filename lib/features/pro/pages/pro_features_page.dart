import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

class ProFeaturesPage extends StatelessWidget {
  const ProFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': 'Advanced Analytics',
        'points': [
          'See deeper app performance beyond just basic impressions and downloads.',
          'Understand which metrics are actually improving over time.',
          'Spot weak areas before they hurt growth.',
          'Useful for update tracking, launch monitoring and optimisation decisions.',
          'Designed to help you make better product choices faster.',
        ],
      },
      {
        'title': 'Custom Notifications',
        'points': [
          'Set smart alerts around the metrics you care about most.',
          'Know when downloads spike or suddenly drop.',
          'Catch unusual performance changes early.',
          'Avoid constantly checking App Store stats manually.',
          'Ideal for staying on top of app growth with less effort.',
        ],
      },
      {
        'title': 'Multi-App Monitoring',
        'points': [
          'Track several apps inside one cleaner workspace.',
          'Perfect if you are launching multiple products or experiments.',
          'Compare which app is gaining traction fastest.',
          'Keep everything organised without bouncing between dashboards.',
          'Useful for indie developers and small app studios.',
        ],
      },
      {
        'title': 'AI Growth Analysis',
        'points': [
          'Get AI-powered suggestions based on your app performance.',
          'See what may be helping or hurting conversion.',
          'Identify possible reasons for performance changes.',
          'Helpful for improving App Store pages, updates and monetisation.',
          'Built to save time when deciding what to work on next.',
        ],
      },
      {
        'title': 'Revenue Trend Insights',
        'points': [
          'Understand how your monetisation is moving over time.',
          'Spot stronger-performing periods and weaker ones.',
          'Useful when testing ads, subscriptions or paid unlocks.',
          'Makes it easier to decide which monetisation methods are worth keeping.',
          'Helps you build apps more like a business, not just a hobby.',
        ],
      },
      {
        'title': 'Conversion Breakdowns',
        'points': [
          'See where users are viewing your app but not downloading.',
          'Helpful for improving screenshots, icons, titles and descriptions.',
          'Can highlight App Store page weak points more clearly.',
          'Makes growth optimisation more practical.',
          'Great for improving App Store conversion over time.',
        ],
      },
      {
        'title': 'Review Sentiment Summaries',
        'points': [
          'Quickly understand what users like and dislike.',
          'Find recurring complaints faster.',
          'Spot which updates are improving user satisfaction.',
          'Useful when prioritising bug fixes or feature improvements.',
          'Helps you turn reviews into useful product decisions.',
        ],
      },
      {
        'title': 'Launch Performance Snapshots',
        'points': [
          'See how your app performs after launches and updates.',
          'Compare traction before and after key changes.',
          'Great for measuring whether updates actually help.',
          'Useful when testing store assets or new features.',
          'Makes release tracking much clearer.',
        ],
      },
      {
        'title': 'Collaboration (Future Ready)',
        'points': [
          'Planned support for sharing workspaces and app tracking with others.',
          'Useful if you build apps with friends, co-founders or collaborators.',
          'Designed to support team workflows as DevDatapoint grows.',
          'A strong feature for future studio-style development.',
          'Lifetime users especially benefit as more premium tools are added.',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Why Go Pro',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2C1F07),
                  Color(0xFF151008),
                  Color(0xFF0B0E14),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFFFFD76A),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Built to help you grow apps smarter.',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'DevDatapoint Pro is designed for developers who want more than surface-level stats. It helps you understand performance, react faster, and make better product decisions.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _FeatureExpansionCard(
                title: section['title'] as String,
                points: (section['points'] as List).cast<String>(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureExpansionCard extends StatelessWidget {
  final String title;
  final List<String> points;

  const _FeatureExpansionCard({
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: const Color(0xFFFFD76A),
          collapsedIconColor: const Color(0xFFFFD76A),
          title: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: points
              .map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFFFFD76A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}