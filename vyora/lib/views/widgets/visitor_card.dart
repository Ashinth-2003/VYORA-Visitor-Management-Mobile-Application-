import 'package:flutter/material.dart';

import '../../models/visitor_model.dart';
import '../../theme/app_theme.dart';
import 'app_card.dart';
import 'status_chip.dart';

class VisitorAvatar extends StatelessWidget {
  const VisitorAvatar({super.key, required this.name, this.size = 46});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldGradient,
      ),
      child: CircleAvatar(
        backgroundColor: context.colors.surface,
        child: Text(
          initial,
          style: TextStyle(
            color: context.colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: size * .38,
          ),
        ),
      ),
    );
  }
}

class VisitorCard extends StatelessWidget {
  const VisitorCard({
    super.key,
    required this.visitor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Visitor visitor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      color: context.colors.onSurfaceVariant,
      fontSize: 13,
    );

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
      child: Row(
        children: [
          VisitorAvatar(name: visitor.name),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(visitor.mobile, style: muted),
                Text(
                  '${visitor.project} · ${visitor.visitorType.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
                const SizedBox(height: 10),
                StatusChip(status: visitor.status),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit',
                icon: Icon(Icons.edit_outlined, color: context.colors.primary),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
