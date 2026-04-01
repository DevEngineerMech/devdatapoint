import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';
import '../widgets/stat_summary_card.dart';

class AdvancedAnalyticsPage extends StatelessWidget {
  const AdvancedAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Advanced Analytics',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.15,
          children: const [
            StatSummaryCard(
              icon: Icons.people_alt_rounded,
              title: 'Retention',
              value: '42%',
              changeText: '7 Day',
            ),
            StatSummaryCard(
              icon: Icons.monetization_on_rounded,
              title: 'Revenue',
              value: '£182',
              changeText: 'This Month',
            ),
            StatSummaryCard(
              icon: Icons.trending_up_rounded,
              title: 'Growth',
              value: '+12.4%',
              changeText: 'Last 30 Days',
            ),
            StatSummaryCard(
              icon: Icons.star_rounded,
              title: 'Rating',
              value: '4.8',
              changeText: '124 Reviews',
            ),
          ],
        ),
      ),
    );
  }
}