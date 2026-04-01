import 'package:flutter/material.dart';
import 'package:devdatapoint/core/theme/app_theme.dart';

class PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String buttonText;
  final bool selected;
  final bool highlight;
  final bool isCurrent;
  final bool isLoading;
  final bool isPurchasing;
  final String? badge;
  final String? savingsText;
  final List<Map<String, dynamic>> features;
  final VoidCallback onTap;
  final VoidCallback? onUpgrade;
  final VoidCallback onLearnMore;

  const PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.buttonText,
    required this.selected,
    required this.highlight,
    required this.isCurrent,
    required this.isLoading,
    required this.isPurchasing,
    required this.features,
    required this.onTap,
    required this.onLearnMore,
    this.onUpgrade,
    this.badge,
    this.savingsText,
  });

  @override
  Widget build(BuildContext context) {
    final accent = highlight ? const Color(0xFFFFD76A) : AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: selected
              ? LinearGradient(
                  colors: highlight
                      ? [
                          const Color(0xFF3A2A0C),
                          const Color(0xFF1C150C),
                          const Color(0xFF111827),
                        ]
                      : [
                          const Color(0xFF18202D),
                          const Color(0xFF121826),
                          const Color(0xFF0D1320),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppTheme.surface,
          border: Border.all(
            color: selected ? accent : AppTheme.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.14),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null || isCurrent)
              Row(
                children: [
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  if (badge != null && isCurrent) const SizedBox(width: 8),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.28),
                        ),
                      ),
                      child: const Text(
                        'CURRENT PLAN',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),

            if (badge != null || isCurrent) const SizedBox(height: 18),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              color: accent,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (savingsText != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              savingsText!,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),

            if (selected) ...[
              const SizedBox(height: 22),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 20),

              ...features.map((feature) {
                final bool enabled = feature['enabled'] == true;
                final String title = feature['name'] ?? '';
                final String? desc = feature['desc'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          enabled ? Icons.check_circle : Icons.lock_rounded,
                          size: 20,
                          color: enabled ? accent : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: enabled
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (desc != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                desc,
                                style: TextStyle(
                                  color: enabled
                                      ? AppTheme.textSecondary
                                      : AppTheme.textMuted,
                                  fontSize: 12.5,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 58),
                    backgroundColor: isCurrent ? AppTheme.surfaceAlt : accent,
                    foregroundColor:
                        isCurrent ? AppTheme.textPrimary : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (isCurrent || isPurchasing) ? null : onUpgrade,
                  child: Text(
                    isCurrent
                        ? 'Current Plan'
                        : (isPurchasing ? 'Please wait...' : buttonText),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: onLearnMore,
                  child: Text(
                    'Learn More',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}