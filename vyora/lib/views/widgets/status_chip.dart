import 'package:flutter/material.dart';

import '../../models/visitor_model.dart';
import '../../theme/app_theme.dart';

Color statusColor(VisitorStatus status) {
  switch (status) {
    case VisitorStatus.registered:
      return AppColors.info;
    case VisitorStatus.checkedIn:
      return AppColors.success;
    case VisitorStatus.checkedOut:
      return AppColors.neutral;
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final VisitorStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
