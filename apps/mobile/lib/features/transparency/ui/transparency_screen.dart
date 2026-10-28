import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';

class TransparencySection {
  final String title;
  final String body;
  final IconData icon;

  const TransparencySection({required this.title, required this.body, required this.icon});
}

class TransparencyViewModel {
  final String headline;
  final String intro;
  final List<TransparencySection> sections;
  final String policyLine;

  const TransparencyViewModel({
    this.headline = 'How we calculated this',
    this.intro = '',
    this.sections = const [],
    this.policyLine = '',
  });
}

/// "How we calculated this": formula, the user's inputs and the policy version.
class TransparencyScreen extends StatelessWidget {
  final TransparencyViewModel vm;

  const TransparencyScreen({super.key, this.vm = const TransparencyViewModel()});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(title: const Text('How We Calculate This')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vm.headline, style: AppTypography.titleLarge.copyWith(color: ink)),
            const SizedBox(height: 8),
            Text(vm.intro, style: AppTypography.body.copyWith(color: muted)),
            const SizedBox(height: 16),
            for (final s in vm.sections) ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(s.icon, color: primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.title, style: AppTypography.subheading.copyWith(color: ink)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(s.body, style: AppTypography.body.copyWith(color: muted)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(vm.policyLine, style: AppTypography.captionStrong.copyWith(color: muted)),
          ],
        ),
      ),
    );
  }
}

/// Gentle check-in sheet shown when intake has been critically low for multiple days.
class GentleCheckInSheet extends StatelessWidget {
  /// Called after the sheet closes itself.
  final VoidCallback? onDismiss;

  /// Opens support and guidance (blueprint §3 rule 6). Called after the sheet closes.
  final VoidCallback? onGetHelp;

  const GentleCheckInSheet({
    super.key,
    this.onDismiss,
    this.onGetHelp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimarySoft
                      : AppColors.lightPrimarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite_outline,
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Just checking in',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We noticed your logged eating has been quite low for the past few days. If you are unwell, fasting, or busy, please remember to listen to your body and eat when you need nourishment.',
            style: AppTypography.body.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'I am okay, continue',
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Find support and guidance',
            onPressed: () {
              Navigator.of(context).pop();
              onGetHelp?.call();
            },
          ),
        ],
      ),
    );
  }
}
