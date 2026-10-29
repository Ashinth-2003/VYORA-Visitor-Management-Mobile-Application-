import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final textColor = outlined ? context.colors.onSurface : AppColors.onGold;
    final canTap = onPressed != null && !isLoading;

    return Opacity(
      opacity: onPressed == null && !isLoading ? .45 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: outlined ? null : AppColors.goldGradient,
          border: outlined ? Border.all(color: context.colors.outline) : null,
          boxShadow: outlined || !canTap
              ? null
              : [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: .3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: canTap ? onPressed : null,
            child: SizedBox(
              height: 54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: textColor,
                      ),
                    )
                  else if (icon != null)
                    Icon(icon, size: 20, color: textColor),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
