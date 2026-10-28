import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../domain/common/local_date.dart';
import '../../../domain/common/meal_slot.dart';
import '../../../domain/profile/user_profile.dart';
import 'settings_controller.dart';

/// Meal times (3–6 meals) and Ramadan dates. Late dinners and a chai slot are normal defaults.
class MealScheduleSheet extends ConsumerStatefulWidget {
  const MealScheduleSheet({super.key, required this.initial});

  final MealSchedule initial;

  static Future<void> show(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    final setup = await container.read(profileRepositoryProvider).load();
    if (setup == null || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MealScheduleSheet(initial: setup.schedule),
    );
  }

  @override
  ConsumerState<MealScheduleSheet> createState() => _MealScheduleSheetState();
}

class _MealScheduleSheetState extends ConsumerState<MealScheduleSheet> {
  late Map<MealSlot, int> _normal;
  late List<SlotTime> _ramadan;
  LocalDate? _start;
  LocalDate? _end;
  bool _saving = false;

  static const _normalOrder = [
    MealSlot.breakfast,
    MealSlot.snack,
    MealSlot.lunch,
    MealSlot.chai,
    MealSlot.dinner
  ];
  static const _defaults = {
    MealSlot.breakfast: 8 * 60,
    MealSlot.snack: 11 * 60,
    MealSlot.lunch: 14 * 60,
    MealSlot.chai: 17 * 60 + 30,
    MealSlot.dinner: 21 * 60 + 30,
  };
  static const _required = {
    MealSlot.breakfast,
    MealSlot.lunch,
    MealSlot.dinner
  };

  @override
  void initState() {
    super.initState();
    _normal = {
      for (final s in widget.initial.normalSlots) s.slot: s.minutesOfDay
    };
    _ramadan = [...widget.initial.ramadanSlots];
    _start = widget.initial.ramadanStart;
    _end = widget.initial.ramadanEnd;
  }

  Future<void> _pickTime(MealSlot slot) async {
    final current = _normal[slot]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null)
      setState(() => _normal[slot] = picked.hour * 60 + picked.minute);
  }

  Future<void> _pickRamadanTime(int index) async {
    final current = _ramadan[index].minutesOfDay;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      setState(() => _ramadan[index] =
          SlotTime(_ramadan[index].slot, picked.hour * 60 + picked.minute));
    }
  }

  Future<void> _pickRamadanDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _start == null
          ? null
          : DateTimeRange(start: _start!.atMinutes(0), end: _end!.atMinutes(0)),
      helpText: 'Ramadan dates',
    );
    if (range != null) {
      setState(() {
        _start = LocalDate.fromDateTime(range.start);
        _end = LocalDate.fromDateTime(range.end);
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final schedule = MealSchedule(
      normalSlots: [
        for (final s in _normalOrder)
          if (_normal.containsKey(s)) SlotTime(s, _normal[s]!)
      ],
      ramadanSlots: _ramadan,
      ramadanStart: _start,
      ramadanEnd: _end,
    );
    await ref
        .read(settingsControllerProvider.notifier)
        .updateSchedule(schedule);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    final count = _normal.length;
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding.add(
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Meal times', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              Text(
                  'Between ${MealSchedule.minSlots} and ${MealSchedule.maxSlots} meals. Changes apply to plans made from now on.',
                  style: AppTypography.caption),
              const SizedBox(height: 12),
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  children: [
                    for (final s in _normalOrder)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(Fmt.slot(s)),
                        subtitle: _normal.containsKey(s)
                            ? InkWell(
                                onTap: () => _pickTime(s),
                                child: Text(
                                    '${Fmt.time(_normal[s]!)} · tap to change',
                                    style: AppTypography.captionStrong),
                              )
                            : const Text('Off'),
                        value: _normal.containsKey(s),
                        onChanged: _required.contains(s)
                            ? null
                            : (on) => setState(() {
                                  if (on && count < MealSchedule.maxSlots) {
                                    _normal[s] = _defaults[s]!;
                                  } else if (!on &&
                                      count > MealSchedule.minSlots) {
                                    _normal.remove(s);
                                  }
                                }),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Ramadan', style: AppTypography.subheading),
              const SizedBox(height: 4),
              Text(
                  'On these dates, sehri and iftar replace breakfast and lunch, and reminders follow them.',
                  style: AppTypography.caption),
              const SizedBox(height: 8),
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.nightlight_round),
                      title: Text(_start == null
                          ? 'Set Ramadan dates'
                          : '${fmt.format(_start!.atMinutes(0))} – ${fmt.format(_end!.atMinutes(0))}'),
                      trailing: _start == null
                          ? null
                          : IconButton(
                              tooltip: 'Clear Ramadan dates',
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _start = null;
                                _end = null;
                              }),
                            ),
                      onTap: _pickRamadanDates,
                    ),
                    for (var i = 0; i < _ramadan.length; i++)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(Fmt.slot(_ramadan[i].slot)),
                        subtitle: Text(
                            '${Fmt.time(_ramadan[i].minutesOfDay)} · tap to change'),
                        onTap: () => _pickRamadanTime(i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                  label: 'Save meal times',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
