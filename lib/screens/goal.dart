import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../i18n.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

String sexLabel(Sex s) => switch (s) {
      Sex.male => tr('male'),
      Sex.female => tr('female'),
      Sex.pregnant => tr('pregnant'),
      Sex.breastfeeding => tr('breastfeeding'),
      Sex.other => tr('prefer_not'),
    };

String activityLabel(Activity a) => switch (a) {
      Activity.low => tr('act_low'),
      Activity.medium => tr('act_medium'),
      Activity.high => tr('act_high'),
      Activity.veryHigh => tr('act_veryhigh'),
    };

String climateLabel(Climate c) => switch (c) {
      Climate.cold => tr('cl_cold'),
      Climate.temperate => tr('cl_temperate'),
      Climate.hot => tr('cl_hot'),
      Climate.veryHot => tr('cl_veryhot'),
    };

IconData sexIcon(Sex s) => switch (s) {
      Sex.male => Icons.male_rounded,
      Sex.female => Icons.female_rounded,
      Sex.pregnant => Icons.pregnant_woman_rounded,
      Sex.breastfeeding => Icons.child_friendly_rounded,
      Sex.other => Icons.person_outline_rounded,
    };

IconData activityIcon(Activity a) => switch (a) {
      Activity.low => Icons.weekend_outlined,
      Activity.medium => Icons.directions_walk_rounded,
      Activity.high => Icons.directions_run_rounded,
      Activity.veryHigh => Icons.fitness_center_rounded,
    };

IconData climateIcon(Climate c) => switch (c) {
      Climate.cold => Icons.ac_unit_rounded,
      Climate.temperate => Icons.cloud_outlined,
      Climate.hot => Icons.wb_sunny_outlined,
      Climate.veryHot => Icons.local_fire_department_outlined,
    };

/// Full screen aqua "Calculate your goal" panel. Used in onboarding and settings.
class GoalPanel extends StatelessWidget {
  final VoidCallback onDone;
  final bool showSkip;
  const GoalPanel({super.key, required this.onDone, this.showSkip = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return Container(
          color: C.accent,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Material(
                      color: C.ink,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: onDone,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          child: Text(tr('done').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  s.customGoalMl != null ? tr('your_goal') : tr('recommended_goal'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    s.fmt(s.goalMl),
                    style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w800, height: 1.1),
                  ),
                ),
                Text(tr('calc_goal'),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const Spacer(),
                _tile(context, sexLabel(s.sex), sexIcon(s.sex), () => pickSex(context)),
                _tile(context, s.weightLabel, Icons.monitor_weight_outlined, () => pickWeight(context)),
                _tile(context, activityLabel(s.activity), activityIcon(s.activity), () => pickActivity(context)),
                _tile(context, climateLabel(s.climate), climateIcon(s.climate), () => pickClimate(context)),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => pickCustomGoal(context),
                  child: Text(tr('custom_goal'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white)),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tile(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 6),
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Icon(icon, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _optionSheet<T>(BuildContext context, String title, List<T> values, T current,
    String Function(T) label, IconData Function(T) icon, void Function(T) onPick) {
  return showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            for (final v in values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: v == current ? C.accentSoft : C.card,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onPick(v);
                      Navigator.pop(ctx);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Row(children: [
                        Expanded(
                            child: Text(label(v),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                        Icon(icon(v), color: v == current ? C.accentDeep : C.ink),
                      ]),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(tr('privacy_note'), style: const TextStyle(color: C.inkSoft, fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

Future<void> pickSex(BuildContext context) => _optionSheet<Sex>(context, tr('sex'), Sex.values,
    AppState.instance.sex, sexLabel, sexIcon, (v) => AppState.instance.update((s) => s
      ..sex = v
      ..customGoalMl = null));

Future<void> pickActivity(BuildContext context) => _optionSheet<Activity>(context, tr('activity'),
    Activity.values, AppState.instance.activity, activityLabel, activityIcon, (v) => AppState.instance.update((s) => s
      ..activity = v
      ..customGoalMl = null));

Future<void> pickClimate(BuildContext context) => _optionSheet<Climate>(context, tr('climate'),
    Climate.values, AppState.instance.climate, climateLabel, climateIcon, (v) => AppState.instance.update((s) => s
      ..climate = v
      ..customGoalMl = null));

Future<void> pickWeight(BuildContext context) {
  final s = AppState.instance;
  var lbs = s.weightLbs;
  var kg = s.weightKg.round();
  return showModalBottomSheet(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
      final min = lbs ? 66 : 30;
      final max = lbs ? 440 : 200;
      final cur = (lbs ? (kg * 2.20462).round() : kg).clamp(min, max);
      final ctrl = FixedExtentScrollController(initialItem: cur - min);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(tr('weight'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('kg')),
                ButtonSegment(value: true, label: Text('lbs')),
              ],
              selected: {lbs},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setSt(() => lbs = v.first),
            ),
            SizedBox(
              height: 180,
              child: ListWheelScrollView.useDelegate(
                key: ValueKey(lbs),
                controller: ctrl,
                itemExtent: 46,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  HapticFeedback.selectionClick();
                  final v = min + i;
                  kg = lbs ? (v / 2.20462).round() : v;
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: max - min + 1,
                  builder: (_, i) => Center(
                    child: Text('${min + i} ${lbs ? 'lbs' : 'kg'}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: C.accentDeep)),
                  ),
                ),
              ),
            ),
            Text(tr('privacy_note'), style: const TextStyle(color: C.inkSoft, fontSize: 12)),
            const SizedBox(height: 14),
            PillButton(
              label: tr('done'),
              onTap: () {
                AppState.instance.update((st) => st
                  ..weightKg = kg.toDouble()
                  ..weightLbs = lbs
                  ..customGoalMl = null);
                Navigator.pop(ctx);
              },
            ),
          ]),
        ),
      );
    }),
  );
}

Future<void> pickCustomGoal(BuildContext context) async {
  final s = AppState.instance;
  final ctrl = TextEditingController(text: s.fmt(s.goalMl, unit: false));
  final v = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('enter_goal')),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(suffixText: s.unitLabel),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('cancel'))),
        TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(tr('save'))),
      ],
    ),
  );
  if (v == null) return;
  final n = double.tryParse(v.trim());
  if (n == null || n <= 0) return;
  final ml = s.useOz ? (n * 29.5735).round() : n.round();
  s.update((st) => st.customGoalMl = ml.clamp(500, 8000));
}

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.accent,
      body: GoalPanel(onDone: () => Navigator.pop(context)),
    );
  }
}
