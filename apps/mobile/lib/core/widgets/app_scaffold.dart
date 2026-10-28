import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'state_widgets.dart';

enum AppTab { today, foods, progress, more }

/// Main persistent shell scaffold with 4-destination bottom navigation bar.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabChanged;
  final bool isOffline;

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentTab,
    required this.onTabChanged,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            if (isOffline) const OfflineBanner(),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              tab: AppTab.today,
              label: 'Today',
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
            ),
            _buildNavItem(
              context: context,
              tab: AppTab.foods,
              label: 'Foods',
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
            ),
            _buildNavItem(
              context: context,
              tab: AppTab.progress,
              label: 'Progress',
              icon: Icons.trending_up_outlined,
              activeIcon: Icons.trending_up,
            ),
            _buildNavItem(
              context: context,
              tab: AppTab.more,
              label: 'More',
              icon: Icons.more_horiz_outlined,
              activeIcon: Icons.more_horiz,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required AppTab tab,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = tab == currentTab;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final primarySoft = isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: '$label tab',
        child: InkWell(
          onTap: () => onTabChanged(tab),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? primary : muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.micro.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? primary : muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
