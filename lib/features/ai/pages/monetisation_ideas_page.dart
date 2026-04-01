import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';
import 'package:devdatapoint/features/ai/services/ai_tools_service.dart';

class MonetisationIdeasPage extends StatelessWidget {
  const MonetisationIdeasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = AiToolsService.getMonetisationIdeas();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text(
          'Monetisation Ideas',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _AiIdeaCard(
            title: item['title']!,
            subtitle: item['subtitle']!,
          );
        },
      ),
    );
  }
}

class _AiIdeaCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AiIdeaCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
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
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}