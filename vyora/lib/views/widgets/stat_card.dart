import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      goldBorder: highlight,
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.primary, size: 22),
          const SizedBox(height: 14),
          // Counts up from 0 when the card first appears.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, number, _) => Text(
              '${number.round()}',
              style: context.textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
