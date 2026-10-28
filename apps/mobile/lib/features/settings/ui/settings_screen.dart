import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

/// Current values shown under each setting.
class SettingsViewModel {
  final String targetSummary;
  final String richnessSummary;
  final String exclusionsSummary;
  final String scheduleSummary;
  final String versionLabel;

  const SettingsViewModel({
    this.targetSummary = '',
    this.richnessSummary = '',
    this.exclusionsSummary = '',
    this.scheduleSummary = '',
    this.versionLabel = '',
  });
}

/// More & Settings screen.
class SettingsScreen extends StatelessWidget {
  final SettingsViewModel vm;
  final VoidCallback? onOpenMealSchedule;
  final VoidCallback? onSendFeedback;
  final VoidCallback? onOpenAbout;
  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onOpenTransparency;
  final VoidCallback? onOpenReminders;
  final VoidCallback? onOpenShopping;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenProfileTarget;
  final VoidCallback? onOpenCookingRichness;
  final VoidCallback? onOpenAllergies;
  final VoidCallback? onOpenLanguage;

  const SettingsScreen({
    super.key,
    this.vm = const SettingsViewModel(),
    this.onOpenMealSchedule,
    this.onSendFeedback,
    this.onOpenAbout,
    this.onOpenPrivacy,
    this.onOpenTransparency,
    this.onOpenReminders,
    this.onOpenShopping,
    this.onOpenHistory,
    this.onOpenProfileTarget,
    this.onOpenCookingRichness,
    this.onOpenAllergies,
    this.onOpenLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupHeader(context, 'DAILY TOOLS'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildTile(context,
                    icon: Icons.history,
                    title: 'Past days & history',
                    subtitle: 'Immutable daily nutrition snapshots',
                    onTap: onOpenHistory),
                const Divider(height: 1),
                _buildTile(context,
                    icon: Icons.shopping_basket_outlined,
                    title: 'Shopping list',
                    subtitle: 'Aggregated planned ingredients',
                    onTap: onOpenShopping),
                const Divider(height: 1),
                _buildTile(context,
                    icon: Icons.notifications_none,
                    title: 'Meal reminders',
                    subtitle: 'Logging alerts with Ramadan shift',
                    onTap: onOpenReminders),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildGroupHeader(context, 'PREFERENCES & HEALTH TARGETS'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile & calorie target',
                  subtitle: vm.targetSummary,
                  onTap: onOpenProfileTarget,
                ),
                const Divider(height: 1),
                _buildTile(
                  context,
                  icon: Icons.soup_kitchen_outlined,
                  title: 'Default cooking richness',
                  subtitle: vm.richnessSummary,
                  onTap: onOpenCookingRichness,
                ),
                const Divider(height: 1),
                _buildTile(
                  context,
                  icon: Icons.no_food_outlined,
                  title: 'Allergies & exclusions',
                  subtitle: vm.exclusionsSummary,
                  onTap: onOpenAllergies,
                ),
                const Divider(height: 1),
                _buildTile(
                  context,
                  icon: Icons.schedule,
                  title: 'Meal times & Ramadan',
                  subtitle: vm.scheduleSummary,
                  onTap: onOpenMealSchedule,
                ),
                const Divider(height: 1),
                _buildTile(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English (Urdu coming soon)',
                  onTap: onOpenLanguage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildGroupHeader(context, 'TRANSPARENCY & DATA'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildTile(context,
                    icon: Icons.calculate_outlined,
                    title: 'How we calculate this',
                    subtitle: 'Formulas, safety floors, rate caps',
                    onTap: onOpenTransparency),
                const Divider(height: 1),
                _buildTile(context,
                    icon: Icons.shield_outlined,
                    title: 'Privacy & data ownership',
                    subtitle: 'Export, import, delete all',
                    onTap: onOpenPrivacy),
                const Divider(height: 1),
                _buildTile(context,
                    icon: Icons.mail_outline,
                    title: 'Send feedback or a missing food',
                    subtitle: 'Opens your email app',
                    onTap: onSendFeedback),
                const Divider(height: 1),
                _buildTile(context,
                    icon: Icons.info_outline,
                    title: 'About & disclaimer',
                    subtitle: 'Estimates, data sources, not medical advice',
                    onTap: onOpenAbout),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              vm.versionLabel,
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.micro.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon,
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
      title: Text(
        title,
        style: AppTypography.bodyStrong.copyWith(
          color: isDark ? AppColors.darkInk : AppColors.lightInk,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}
