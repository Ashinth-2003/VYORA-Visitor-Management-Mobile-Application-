import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'scanner_screen.dart';
import 'visitor_list_screen.dart';
import 'widgets/screen_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void _openScanner() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final statusBar = context.isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBar,
      child: PopScope(
        // Back from the visitors tab goes to the overview first.
        canPop: _tab == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _tab = 0);
        },
        child: ScreenBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _tab,
                children: [
                  DashboardScreen(onViewAll: () => setState(() => _tab = 1)),
                  const VisitorListScreen(),
                ],
              ),
            ),
            bottomNavigationBar: _BottomBar(
              tab: _tab,
              onTab: (index) => setState(() => _tab = index),
              onScan: _openScanner,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.tab,
    required this.onTab,
    required this.onScan,
  });

  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.colors.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Overview',
                  selected: tab == 0,
                  onTap: () => onTab(0),
                ),
              ),
              GestureDetector(
                onTap: onScan,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: .4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.onGold,
                    size: 27,
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Visitors',
                  selected: tab == 1,
                  onTap: () => onTab(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primary
        : context.colors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
