import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

import 'package:devdatapoint/features/ai/widgets/ai_section_header.dart';
import 'package:devdatapoint/features/ai/widgets/ai_tool_card.dart';

import 'package:devdatapoint/features/ai/pages/prototype_lab_page.dart';
import 'package:devdatapoint/features/ai/pages/improve_my_app_page.dart';
import 'package:devdatapoint/features/ai/pages/monetisation_ideas_page.dart';
import 'package:devdatapoint/features/ai/pages/aso_suggestions_page.dart'
    as aso_page;
import 'package:devdatapoint/features/ai/pages/feature_planner_page.dart'
    as planner_page;

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AiSectionHeader(
                title: 'AI Tools',
                subtitle:
                    'Premium AI tools to help you improve, plan and grow your apps faster.',
              ),
              const SizedBox(height: 24),

              _buildHeroCard(),
              const SizedBox(height: 22),

              AiToolCard(
                icon: Icons.lightbulb_rounded,
                title: 'Prototype Lab',
                subtitle:
                    'Generate app concepts, premium ideas and monetisation angles.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrototypeLabPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AiToolCard(
                icon: Icons.auto_graph_rounded,
                title: 'Improve My App',
                subtitle:
                    'Find ways to improve retention, onboarding and growth.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ImproveMyAppPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AiToolCard(
                icon: Icons.payments_rounded,
                title: 'Monetisation Ideas',
                subtitle:
                    'Improve subscriptions, upgrades and premium positioning.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MonetisationIdeasPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AiToolCard(
                icon: Icons.storefront_rounded,
                title: 'ASO Suggestions',
                subtitle:
                    'Improve App Store conversion, screenshots and first impression.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const aso_page.AsoSuggestionsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AiToolCard(
                icon: Icons.view_timeline_rounded,
                title: 'Feature Planner',
                subtitle:
                    'Sort what to build next and what should stay premium.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const planner_page.FeaturePlannerPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF18140A),
            Color(0xFF111827),
            Color(0xFF0B0F18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFFFD76A),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD76A).withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFFFD76A),
            size: 36,
          ),
          SizedBox(height: 18),
          Text(
            'Built for indie developers',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Use AI to make smarter decisions around features, monetisation, App Store performance and app growth.',
            style: TextStyle(
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