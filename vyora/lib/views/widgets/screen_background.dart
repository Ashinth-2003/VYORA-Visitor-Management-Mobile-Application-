import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Page background with two soft gold glows in the corners.
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      color: context.colors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _Glow(
              color: AppColors.gold.withValues(alpha: dark ? .16 : .22),
              size: 340,
            ),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _Glow(
              color: AppColors.goldDeep.withValues(alpha: dark ? .12 : .10),
              size: 380,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
