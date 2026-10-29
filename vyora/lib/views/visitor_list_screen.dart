import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/visitor_controller.dart';
import '../models/visitor_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/snack_bar.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';
import 'widgets/state_views.dart';
import 'widgets/visitor_card.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm([Visitor? visitor]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VisitorFormScreen(visitor: visitor)),
    );
  }

  void _openDetails(Visitor visitor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
      ),
    );
  }

  Future<void> _confirmDelete(Visitor visitor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete visitor?'),
        content: Text('${visitor.name} will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.colors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<VisitorController>().deleteVisitor(visitor.id);
      if (mounted) showMessage(context, 'Visitor deleted');
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitorController>();
    final visitors = controller.filteredVisitors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visitors',
                      style: context.textStyles.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${visitors.length} of ${controller.visitors.length} shown',
                      style: TextStyle(color: context.colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openForm,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: AppColors.goldGradient,
                  ),
                  child: const Icon(Icons.add_rounded, color: AppColors.onGold),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: TextField(
            controller: _searchController,
            onChanged: controller.setSearch,
            decoration: InputDecoration(
              hintText: 'Search by name or mobile',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        controller.setSearch('');
                      },
                    ),
            ),
          ),
        ),
        _FilterRow(controller: controller),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(controller, visitors)),
      ],
    );
  }

  Widget _buildBody(VisitorController controller, List<Visitor> visitors) {
    if (controller.isLoading && controller.visitors.isEmpty) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: LoadingList(count: 6, itemHeight: 124),
      );
    }
    if (controller.errorMessage != null && controller.visitors.isEmpty) {
      return ErrorView(
        message: controller.errorMessage!,
        onRetry: controller.loadVisitors,
      );
    }
    if (visitors.isEmpty) {
      if (controller.hasFilters) {
        return EmptyView(
          title: 'No matches',
          message: 'Try a different search or clear the filters.',
          buttonLabel: 'Clear filters',
          onPressed: () {
            _searchController.clear();
            controller.clearFilters();
          },
        );
      }
      return EmptyView(
        title: 'No visitors yet',
        message: 'Registered visitors will show up here.',
        icon: Icons.groups_2_outlined,
        buttonLabel: 'Register visitor',
        onPressed: _openForm,
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () => controller.loadVisitors(showLoader: false),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: visitors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final visitor = visitors[index];
          return VisitorCard(
            visitor: visitor,
            onTap: () => _openDetails(visitor),
            onEdit: () => _openForm(visitor),
            onDelete: () => _confirmDelete(visitor),
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});

  final VisitorController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterChip(
            label: 'All',
            selected: controller.statusFilter == null,
            onTap: () => controller.setStatusFilter(null),
          ),
          for (final status in VisitorStatus.values)
            _FilterChip(
              label: status.label,
              selected: controller.statusFilter == status,
              onTap: () => controller.setStatusFilter(status),
            ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                controller.setProjectFilter(value.isEmpty ? null : value),
            itemBuilder: (_) => [
              const PopupMenuItem(value: '', child: Text('All projects')),
              for (final project in visitorProjects)
                PopupMenuItem(value: project, child: Text(project)),
            ],
            child: _FilterChip(
              label: controller.projectFilter ?? 'All projects',
              selected: controller.projectFilter != null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: onTap == null ? null : (_) => onTap!(),
        showCheckmark: false,
        selectedColor: AppColors.gold,
        backgroundColor: context.colors.surfaceContainerHighest,
        side: BorderSide(
          color: selected ? AppColors.gold : context.colors.outline,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.onGold : context.colors.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
