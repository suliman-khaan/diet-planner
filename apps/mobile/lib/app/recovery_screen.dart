import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/app_buttons.dart';

/// Shown when the on-device database cannot be read. Data is never reset silently:
/// "Start fresh" keeps the damaged file aside and only runs after the user confirms.
class RecoveryApp extends StatelessWidget {
  const RecoveryApp({super.key, required this.onRetry, required this.onStartFresh});

  final Future<void> Function() onRetry;
  final Future<void> Function() onStartFresh;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: _RecoveryScreen(onRetry: onRetry, onStartFresh: onStartFresh),
      );
}

class _RecoveryScreen extends StatelessWidget {
  const _RecoveryScreen({required this.onRetry, required this.onStartFresh});

  final Future<void> Function() onRetry;
  final Future<void> Function() onStartFresh;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(Icons.healing_outlined, size: 48),
                const SizedBox(height: 16),
                Text('We could not open your saved data', style: AppTypography.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'The file on this phone seems damaged. Nothing has been deleted. Try again first. '
                  'If it still does not open, you can start fresh and restore a backup you exported earlier.',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                PrimaryButton(label: 'Try again', onPressed: onRetry),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Start fresh?'),
                        content: const Text(
                            'The damaged file is kept aside on this phone, and the app starts empty. You can then restore an exported backup.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Start fresh')),
                        ],
                      ),
                    );
                    if (ok == true) await onStartFresh();
                  },
                  child: const Text('Start fresh'),
                ),
              ],
            ),
          ),
        ),
      );
}
