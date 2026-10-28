import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';

/// Privacy & Data Management screen.
class PrivacyScreen extends StatefulWidget {
  final VoidCallback? onExportData;
  final VoidCallback? onImportData;
  final VoidCallback? onDeleteAllConfirmed;

  const PrivacyScreen({
    super.key,
    this.onExportData,
    this.onImportData,
    this.onDeleteAllConfirmed,
  });

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _crashDiagnosticsConsent = false;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all local data?'),
        content: const Text(
          'This will permanently erase all your profile details, past weight records, and meal history from this phone. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDeleteAllConfirmed?.call();
            },
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Data')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your health data is 100% on-device',
                          style: AppTypography.bodyStrong.copyWith(
                            color: isDark ? AppColors.darkInk : AppColors.lightInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your weight, height, age, allergies, and daily food logs are stored in a local SQLite database on your device and are never sent to external servers.',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'CONSENT & DIAGNOSTICS',
              style: AppTypography.micro.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: primary,
                title: Text(
                  'Anonymous crash reports',
                  style: AppTypography.bodyStrong.copyWith(
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
                subtitle: Text(
                  'Strip all personal and health data before sending error logs to help us fix bugs.',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                value: _crashDiagnosticsConsent,
                onChanged: (val) => setState(() => _crashDiagnosticsConsent = val),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'DATA OWNERSHIP',
              style: AppTypography.micro.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.file_download_outlined, color: primary),
                    title: const Text('Export all data (JSON)'),
                    subtitle: const Text('Save your entire food and weight history'),
                    onTap: widget.onExportData,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.file_upload_outlined, color: primary),
                    title: const Text('Import data backup'),
                    subtitle: const Text('Restore from an existing JSON backup'),
                    onTap: widget.onImportData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                onPressed: () => _showDeleteConfirmation(context),
                child: const Text('Delete all data from phone'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
