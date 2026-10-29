import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/theme_controller.dart';
import '../controllers/visitor_controller.dart';
import '../models/visitor_model.dart';
import '../theme/app_theme.dart';
import 'scanner_screen.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';
import 'widgets/app_card.dart';
import 'widgets/section_title.dart';
import 'widgets/stat_card.dart';
import 'widgets/state_views.dart';
import 'widgets/status_chip.dart';
import 'widgets/visitor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  void _openRegister(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const VisitorFormScreen()));
  }

  void _openScanner(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitorController>();
    final recent = controller.visitors.take(4).toList();

    // The header sits outside the ListView, so it stays put while the page scrolls.
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () => controller.loadVisitors(showLoader: false),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _HeroCard(onSite: controller.checkedInCount),
                const SizedBox(height: 24),
                const SectionTitle('Today at a glance'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total today',
                        value: controller.totalToday,
                        icon: Icons.today_rounded,
                        highlight: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Checked in',
                        value: controller.checkedInCount,
                        icon: Icons.login_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Checked out',
                        value: controller.checkedOutToday,
                        icon: Icons.logout_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionTitle('Quick actions'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'Register',
                        onTap: () => _openRegister(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.people_alt_rounded,
                        label: 'Visitor list',
                        onTap: onViewAll,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan QR',
                        onTap: () => _openScanner(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionTitle('Recent visitors'),
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildRecent(context, controller, recent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecent(
    BuildContext context,
    VisitorController controller,
    List<Visitor> recent,
  ) {
    if (controller.isLoading && recent.isEmpty) {
      return const LoadingList(count: 3, itemHeight: 72);
    }
    if (controller.errorMessage != null && recent.isEmpty) {
      return ErrorView(
        message: controller.errorMessage!,
        onRetry: controller.loadVisitors,
      );
    }
    if (recent.isEmpty) {
      return EmptyView(
        title: 'No visitors yet',
        message: 'Register your first visitor to see them here.',
        icon: Icons.auto_awesome_outlined,
        buttonLabel: 'Register visitor',
        onPressed: () => _openRegister(context),
      );
    }
    return Column(
      children: recent.map((visitor) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RecentTile(visitor: visitor),
        );
      }).toList(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 4),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (rect) => AppColors.goldGradient.createShader(rect),
            child: const Text(
              'VYORA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Frequently asked questions',
            onPressed: () => _showFaqDialog(context),
            icon: Icon(
              Icons.help_outline_rounded,
              color: context.colors.primary,
            ),
          ),
          IconButton(
            tooltip: theme.isDark ? 'Light theme' : 'Dark theme',
            onPressed: theme.toggle,
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _FaqDialog(),
    );
  }
}

class _FaqDialog extends StatelessWidget {
  const _FaqDialog();

  static const _faqs = [
    (
      question: 'How do I register a visitor?',
      answer:
          'Tap Register from Quick actions, enter the visitor details, and save the form.',
    ),
    (
      question: 'How do I check a visitor in or out?',
      answer:
          'Open the visitor from the visitor list, then tap the check-in or check-out action on their details page.',
    ),
    (
      question: 'How does QR scanning work?',
      answer:
          'Tap Scan QR from the bottom navigation or Quick actions and allow camera access when prompted.',
    ),
    (
      question: 'Can I edit visitor information?',
      answer:
          'Yes. Open a visitor\'s details and tap the edit button in the top-right corner.',
    ),
    (
      question: 'How do I switch between light and dark mode?',
      answer:
          'Use the sun/moon button in the top-right corner of the dashboard.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline_rounded, color: context.colors.primary),
          const SizedBox(width: 10),
          const Text('FAQ'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _faqs.length; i++) ...[
                  Text(
                    _faqs[i].question,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _faqs[i].answer,
                    style: TextStyle(color: context.colors.onSurfaceVariant),
                  ),
                  if (i != _faqs.length - 1) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onSite});

  final int onSite;

  @override
  Widget build(BuildContext context) {
    final headline = context.textStyles.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );

    return AppCard(
      goldBorder: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(DateFormat('EEEE, d MMMM').format(DateTime.now())),
          const SizedBox(height: 14),
          Text('Every arrival,', style: headline),
          ShaderMask(
            shaderCallback: (rect) => AppColors.goldGradient.createShader(rect),
            child: Text(
              'seamlessly managed.',
              style: headline?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Verify passes and log every entry and exit in seconds.',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: .35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.success)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: .3, end: 1, duration: 900.ms),
                const SizedBox(width: 8),
                Text(
                  '$onSite on site now',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: .06);
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary, size: 26),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.visitor});

  final Visitor visitor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
          ),
        );
      },
      child: Row(
        children: [
          VisitorAvatar(name: visitor.name, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${visitor.project} · ${visitor.purpose}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(status: visitor.status),
        ],
      ),
    );
  }
}
