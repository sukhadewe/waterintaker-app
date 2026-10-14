import 'package:flutter/material.dart';

import '../app_state.dart';
import '../i18n.dart';
import '../services/notifications.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import 'beverages.dart';
import 'goal.dart';
import 'paywall.dart';

const kAppVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _hm(int m) {
    final h = m ~/ 60, mm = m % 60;
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${mm.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return Scaffold(
          appBar: AppBar(title: Text(tr('settings'))),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              // Reminders card
              Material(
                color: C.accentSoft,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => showReminderSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(tr('reminders'),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800, color: C.accentDeep)),
                          const SizedBox(height: 6),
                          Text(
                            s.remindersOn
                                ? '${tr('interval')}: ${tr('hours', {'n': (s.remindIntervalMin / 60).toStringAsFixed(1).replaceAll('.0', '')})}\n${_hm(s.remindStartMin)} – ${_hm(s.remindEndMin)}'
                                : tr('off'),
                            style: const TextStyle(color: C.inkSoft, height: 1.4),
                          ),
                        ]),
                      ),
                      Icon(s.remindersOn ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
                          color: C.accentDeep, size: 40),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Goal card
              Material(
                color: C.accent,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen())),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.fmt(s.goalMl),
                              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text(tr(s.customGoalMl != null ? 'your_goal' : 'recommended_goal'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          Text(tr('change_goal_sub'),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                        ]),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!s.premium)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: C.ink,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true)),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(children: [
                          const Icon(Icons.workspace_premium_rounded, color: C.accent, size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(tr('get_premium'),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                              Text(tr('remove_ads'),
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                            ]),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white),
                        ]),
                      ),
                    ),
                  ),
                ),
              SettingTile(
                leading: const Icon(Icons.local_drink_rounded, color: C.accent),
                title: tr('manage_drinks'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeveragesScreen())),
              ),
              SettingTile(
                leading: SizedBox(width: 26, height: 26, child: MascotThumb(characterId: s.character, size: 26)),
                title: tr('character'),
                value: characterById(s.character).name,
                onTap: () => showCharacterSheet(context),
              ),
              SettingTile(
                leading: const Icon(Icons.straighten_rounded, color: C.accent),
                title: tr('units'),
                value: s.unitLabel,
                onTap: () => s.update((st) => st.useOz = !st.useOz),
              ),
              SettingTile(
                leading: const Icon(Icons.translate_rounded, color: C.accent),
                title: tr('language'),
                value: kLanguages[s.lang],
                onTap: () => _pickLang(context),
              ),
              SettingTile(
                leading: const Icon(Icons.vibration_rounded, color: C.accent),
                title: tr('sounds'),
                trailing: Switch(value: s.soundsOn, onChanged: (v) => s.update((st) => st.soundsOn = v)),
              ),
              const SizedBox(height: 10),
              if (s.premium)
                SettingTile(
                  leading: const Icon(Icons.workspace_premium_rounded, color: C.accent),
                  title: tr('premium_active'),
                ),
              SettingTile(
                leading: const Icon(Icons.delete_outline_rounded, color: C.danger),
                title: tr('reset_data'),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      content: Text(tr('reset_confirm')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('cancel'))),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(tr('delete'), style: const TextStyle(color: C.danger))),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await s.resetAll();
                    await Reminders.reschedule();
                  }
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('Waddle • ${tr('version')} $kAppVersion',
                    style: const TextStyle(color: C.inkSoft, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickLang(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final e in kLanguages.entries)
            ListTile(
              title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing:
                  AppState.instance.lang == e.key ? const Icon(Icons.check_rounded, color: C.accent) : null,
              onTap: () {
                AppState.instance.update((s) => s.lang = e.key);
                Reminders.reschedule();
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

Future<void> showCharacterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (ctx) => ListenableBuilder(
      listenable: AppState.instance,
      builder: (ctx, _) {
        final s = AppState.instance;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(tr('character'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
                for (final c in kCharacters)
                  GestureDetector(
                    onTap: () {
                      if (c.premium && !s.premium) {
                        Navigator.pop(ctx);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true));
                        return;
                      }
                      s.update((st) => st.character = c.id);
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: s.character == c.id ? C.accentSoft : C.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: s.character == c.id ? C.accent : Colors.transparent, width: 2),
                      ),
                      child: Column(children: [
                        MascotThumb(characterId: c.id, size: 80),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if (c.premium && !s.premium)
                            const Padding(
                              padding: EdgeInsets.only(right: 3),
                              child: Icon(Icons.lock_rounded, size: 13, color: C.inkSoft),
                            ),
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ]),
                    ),
                  ),
              ]),
            ]),
          ),
        );
      },
    ),
  );
}

Future<void> showReminderSheet(BuildContext context) {
  String hm(int m) {
    final h = m ~/ 60, mm = m % 60;
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${mm.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
  }

  Future<void> pickTime(BuildContext ctx, bool start) async {
    final s = AppState.instance;
    final cur = start ? s.remindStartMin : s.remindEndMin;
    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay(hour: cur ~/ 60, minute: cur % 60));
    if (t == null) return;
    final m = t.hour * 60 + t.minute;
    s.update((st) {
      if (start) {
        st.remindStartMin = m;
      } else {
        st.remindEndMin = m;
      }
    });
    await Reminders.reschedule();
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => ListenableBuilder(
      listenable: AppState.instance,
      builder: (ctx, _) {
        final s = AppState.instance;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(tr('smart_reminders'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(tr('smart_reminders_sub'),
                  textAlign: TextAlign.center, style: const TextStyle(color: C.inkSoft)),
              const SizedBox(height: 16),
              SettingTile(
                leading: const Icon(Icons.notifications_rounded, color: C.accent),
                title: tr('reminders'),
                trailing: Switch(
                  value: s.remindersOn,
                  onChanged: (v) async {
                    if (v) {
                      final ok = await Reminders.requestPermission();
                      if (!ok && ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(tr('notif_denied'))));
                      }
                      s.update((st) => st.remindersOn = ok);
                    } else {
                      s.update((st) => st.remindersOn = false);
                    }
                    await Reminders.reschedule();
                  },
                ),
              ),
              if (s.remindersOn) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Wrap(spacing: 8, children: [
                    for (final m in [60, 90, 120, 180])
                      ChoiceChip(
                        label: Text(tr('hours', {'n': (m / 60).toStringAsFixed(1).replaceAll('.0', '')})),
                        selected: s.remindIntervalMin == m,
                        showCheckmark: false,
                        selectedColor: C.accentSoft,
                        onSelected: (_) async {
                          s.update((st) => st.remindIntervalMin = m);
                          await Reminders.reschedule();
                        },
                      ),
                  ]),
                ),
                SettingTile(
                  leading: const Icon(Icons.wb_twilight_rounded, color: C.accent),
                  title: tr('from'),
                  value: hm(s.remindStartMin),
                  onTap: () => pickTime(ctx, true),
                ),
                SettingTile(
                  leading: const Icon(Icons.bedtime_outlined, color: C.accent),
                  title: tr('until'),
                  value: hm(s.remindEndMin),
                  onTap: () => pickTime(ctx, false),
                ),
                SettingTile(
                  leading: const Icon(Icons.auto_awesome_rounded, color: C.accent),
                  title: tr('smart_skip'),
                  trailing: Switch(
                    value: s.smartSkip,
                    onChanged: (v) async {
                      s.update((st) => st.smartSkip = v);
                      await Reminders.reschedule();
                    },
                  ),
                ),
              ],
            ]),
          ),
        );
      },
    ),
  );
}
