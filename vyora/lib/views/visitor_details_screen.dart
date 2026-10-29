import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/visitor_controller.dart';
import '../models/visitor_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/snack_bar.dart';
import 'visitor_form_screen.dart';
import 'widgets/app_card.dart';
import 'widgets/gold_button.dart';
import 'widgets/qr_box.dart';
import 'widgets/screen_background.dart';
import 'widgets/section_title.dart';
import 'widgets/state_views.dart';
import 'widgets/status_chip.dart';

/// Takes only the visitor id and reads the visitor from the controller,
/// so a check-in done anywhere shows up here straight away.
class VisitorDetailsScreen extends StatelessWidget {
  const VisitorDetailsScreen({super.key, required this.visitorId});

  final String visitorId;

  Future<void> _changeStatus(BuildContext context, Visitor visitor) async {
    final controller = context.read<VisitorController>();
    final isCheckIn = visitor.status == VisitorStatus.registered;

    try {
      if (isCheckIn) {
        await controller.checkIn(visitor.id);
      } else {
        await controller.checkOut(visitor.id);
      }
      if (context.mounted) {
        showMessage(
          context,
          isCheckIn ? '${visitor.name} checked in' : '${visitor.name} checked out',
        );
      }
    } on AppException catch (e) {
      if (context.mounted) showMessage(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitorController>();
    final visitor = controller.visitorById(visitorId);

    if (visitor == null) {
      return ScreenBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Visitor')),
          body: const EmptyView(
            title: 'Visitor not found',
            message: 'This visitor was removed or could not be loaded.',
            icon: Icons.person_off_outlined,
          ),
        ),
      );
    }

    String buttonLabel = 'Check in';
    IconData buttonIcon = Icons.login_rounded;
    if (visitor.status == VisitorStatus.checkedIn) {
      buttonLabel = 'Check out';
      buttonIcon = Icons.logout_rounded;
    } else if (visitor.status == VisitorStatus.checkedOut) {
      buttonLabel = 'Visit completed';
      buttonIcon = Icons.task_alt_rounded;
    }

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Visitor pass'),
          actions: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VisitorFormScreen(visitor: visitor),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            _PassCard(visitor: visitor),
            const SizedBox(height: 22),
            const SectionTitle('Visitor information'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _InfoRow(Icons.phone_outlined, 'Mobile', visitor.mobile),
                  _InfoRow(
                    Icons.alternate_email_rounded,
                    'Email',
                    visitor.email ?? 'Not provided',
                  ),
                  _InfoRow(Icons.apartment_outlined, 'Project', visitor.project),
                  _InfoRow(
                    Icons.badge_outlined,
                    'Type',
                    visitor.visitorType.label,
                  ),
                  _InfoRow(Icons.notes_rounded, 'Purpose', visitor.purpose),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('Timeline'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _TimelineRow('Registered', visitor.createdAt),
                  _TimelineRow('Checked in', visitor.checkInTime),
                  _TimelineRow('Checked out', visitor.checkOutTime),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: GoldButton(
              label: buttonLabel,
              icon: buttonIcon,
              isLoading: controller.isBusy(visitor.id),
              onPressed: visitor.status == VisitorStatus.checkedOut
                  ? null
                  : () => _changeStatus(context, visitor),
            ),
          ),
        ),
      ),
    );
  }
}

class _PassCard extends StatelessWidget {
  const _PassCard({required this.visitor});

  final Visitor visitor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      goldBorder: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VYORA PASS',
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                  fontSize: 13,
                ),
              ),
              StatusChip(status: visitor.status),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            visitor.name,
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${visitor.project} · ${visitor.visitorType.label}',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 22),
          Center(child: QrBox(data: visitor.id)),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'ID  ${visitor.id}',
              style: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow(this.label, this.time);

  final String label;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final done = time != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 20,
            color: done
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: done
                    ? context.colors.onSurface
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            done ? DateFormat('d MMM, h:mm a').format(time!.toLocal()) : 'Pending',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
