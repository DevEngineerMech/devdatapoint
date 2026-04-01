import 'package:flutter/material.dart';

import 'package:devdatapoint/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Map<String, String> app;
  final VoidCallback? onTap;
  final bool compact;

  const AppCard({
    super.key,
    required this.app,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconUrl = app['iconUrl'] ?? '';
    final appName = app['name'] ?? 'Unnamed App';

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.border),
        ),
        child: compact
            ? Row(
                children: [
                  _buildIcon(iconUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      appName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textMuted,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(iconUrl, large: true),
                  const Spacer(),
                  Text(
                    appName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap to open',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon(String iconUrl, {bool large = false}) {
    final size = large ? 68.0 : 52.0;

    if (iconUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          iconUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(size),
        ),
      );
    }

    return _fallbackIcon(size);
  }

  Widget _fallbackIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.apps_rounded,
        color: AppTheme.primary,
      ),
    );
  }
}