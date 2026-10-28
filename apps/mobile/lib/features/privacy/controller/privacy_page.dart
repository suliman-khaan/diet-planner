import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../app/providers/reminder_coordinator.dart';
import '../../../app/routes.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/repositories.dart';
import '../../today/controller/today_controller.dart';
import '../ui/privacy_screen.dart';

const _log = AppLogger('privacy');

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).valueOrNull ?? const AppSettings();

    void snack(String text) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));

    Future<void> saveConsent({bool? crash, bool? analytics}) async {
      final repo = ref.read(settingsRepositoryProvider);
      final s = await repo.load();
      final updated = s.copyWith(
        consentAsked: true,
        crashReportingConsent: crash ?? s.crashReportingConsent,
        analyticsConsent: analytics ?? s.analyticsConsent,
      );
      await repo.save(updated);
      ref.read(analyticsServiceProvider).setConsent(updated.analyticsConsent);
      ref.invalidate(appSettingsProvider);
    }

    void refreshEverything() {
      ref
        ..invalidate(userSetupProvider)
        ..invalidate(appSettingsProvider)
        ..invalidate(todayControllerProvider);
    }

    return PrivacyScreen(
      crashReportsConsent: settings.crashReportingConsent,
      analyticsConsent: settings.analyticsConsent,
      onCrashReportsConsentChanged: (v) => saveConsent(crash: v),
      onAnalyticsConsentChanged: (v) => saveConsent(analytics: v),
      onExportData: () async {
        try {
          final data = await ref.read(dataPortabilityProvider).exportAll();
          final today = ref.read(todayProvider).toIso();
          await ref.read(backupFileServiceProvider).shareExport(
                const JsonEncoder.withIndent(' ').convert(data),
                'diet-planner-backup-$today.json',
              );
        } on Object catch (e, st) {
          _log.error('export_failed', e, st);
          if (context.mounted)
            snack(
                'Export did not finish. Your data on this phone is unchanged.');
        }
      },
      onImportData: () async {
        final String? text;
        try {
          text = await ref.read(backupFileServiceProvider).pickImportFile();
        } on InvalidImportFile {
          if (context.mounted)
            snack('That file could not be read. Nothing was changed.');
          return;
        }
        if (text == null || !context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Replace data on this phone?'),
            content: const Text(
                'Everything on this phone will be replaced with the backup. Export first if you want to keep what is here now.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Replace')),
            ],
          ),
        );
        if (confirmed != true) return;
        try {
          final Object? decoded = jsonDecode(text);
          if (decoded is! Map<String, Object?>)
            throw const InvalidImportFile('Not an object');
          await ref.read(dataPortabilityProvider).importAll(decoded);
          refreshEverything();
          await ref.read(reminderCoordinatorProvider).reschedule();
          if (context.mounted) snack('Backup restored.');
        } on FormatException {
          if (context.mounted)
            snack(
                'That file is not a Diet Planner backup. Nothing was changed.');
        } on InvalidImportFile {
          if (context.mounted)
            snack(
                'That file is not a valid Diet Planner backup. Nothing was changed.');
        }
      },
      onDeleteAllConfirmed: () async {
        await ref.read(dataPortabilityProvider).deleteAll();
        await ref.read(reminderServiceProvider).cancelAll();
        refreshEverything();
        if (context.mounted) context.go(AppRoutes.onboarding);
      },
    );
  }
}
