import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import 'gold_button.dart';

/// Grey shimmering boxes shown while the list loads.
class LoadingList extends StatelessWidget {
  const LoadingList({super.key, this.count = 5, this.itemHeight = 100});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.outline),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1400.ms,
          color: AppColors.gold.withValues(alpha: .15),
        );
      }),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.person_search_outlined,
    this.buttonLabel,
    this.onPressed,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _Message(
      icon: icon,
      color: context.colors.primary,
      title: title,
      message: message,
      buttonLabel: buttonLabel,
      onPressed: onPressed,
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Message(
      icon: Icons.cloud_off_rounded,
      color: context.colors.error,
      title: 'Something went wrong',
      message: message,
      buttonLabel: 'Try again',
      onPressed: onRetry,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: color.withValues(alpha: .1),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
            if (buttonLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: GoldButton(label: buttonLabel!, onPressed: onPressed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
