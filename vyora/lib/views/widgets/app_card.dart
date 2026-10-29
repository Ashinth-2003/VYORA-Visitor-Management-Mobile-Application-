import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.goldBorder = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool goldBorder;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(goldBorder ? 19 : 20);

    return Container(
      padding: goldBorder ? const EdgeInsets.all(1.2) : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: goldBorder ? AppColors.goldGradient : null,
        border: goldBorder ? null : Border.all(color: context.colors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? .35 : .06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: context.colors.surfaceContainerHighest,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
