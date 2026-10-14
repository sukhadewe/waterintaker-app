import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/beverages.dart';
import '../i18n.dart';
import '../models.dart';
import '../services/ads.dart';
import '../services/notifications.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import 'add_drink.dart';
import 'home.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime selected = dayStart(DateTime.now());

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  Future<void> _addMissed() async {
    final b = await pickBeverage(context);
    if (b == null || !mounted) return;
    final now = DateTime.now();
    final isToday = dayKey(selected) == dayKey(now);
    final at = isToday ? now : DateTime(selected.year, selected.month, selected.day, 20);
    await showAddDrinkSheet(context, b, at: at);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final entries = s.entriesFor(selected).reversed.toList();
        final ml = s.hydrationFor(selected);
        return Scaffold(
          appBar: AppBar(title: Text(tr('history'))),
          bottomNavigationBar: const BannerAdBox(),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${s.currentStreak}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1)),
                    Text(tr('day_streak'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              _stats(s),
              const SizedBox(height: 16),
              _calendar(s),
              const SizedBox(height: 16),
              Center(
                child: Mascot(
                  characterId: s.character,
                  layers: layersForDay(s, selected),
                  height: 130,
                  animateWave: false,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(s.fmt(ml),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.accent)),
              ),
              Center(
                child: Text(tr('hydration_of_goal', {'p': '${(ml * 100 / s.goalMl).round()}'}),
                    style: const TextStyle(color: C.inkSoft)),
              ),
              const SizedBox(height: 10),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _addMissed,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(tr('add_missed')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: C.accentDeep,
                    side: const BorderSide(color: C.accent),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text(tr('no_entries'), style: const TextStyle(color: C.inkSoft))),
                ),
              for (final e in entries)
                Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: C.danger, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    s.removeEntry(e.id);
                    Reminders.reschedule();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        DrinkIcon(beverage: beverageById(e.beverageId), size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(beverageById(e.beverageId).name(s.lang),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(s.fmt(e.volumeMl), style: const TextStyle(color: C.inkSoft, fontSize: 13)),
                          ]),
                        ),
                        Text(_time(e.time), style: const TextStyle(color: C.inkSoft)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: C.inkSoft),
                          onPressed: () {
                            s.removeEntry(e.id);
                            Reminders.reschedule();
                          },
                        ),
                      ]),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _weekChart(s),
            ],
          ),
        );
      },
    );
  }

  Widget _stats(AppState s) {
    final now = dayStart(DateTime.now());
    var sum = 0, days = 0, hits = 0;
    for (var i = 0; i < 30; i++) {
      final d = now.subtract(Duration(days: i));
      final v = s.hydrationFor(d);
      if (v > 0) {
        sum += v;
        days++;
      }
      if (v >= s.goalMl) hits++;
    }
    Widget box(String v, String l) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              FittedBox(
                child: Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 2),
              Text(l,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11.5, color: C.inkSoft)),
            ]),
          ),
        );
    return Row(children: [
      box(s.fmt(days == 0 ? 0 : sum ~/ days), tr('avg')),
      const SizedBox(width: 8),
      box('$hits/30', tr('goals_hit')),
      const SizedBox(width: 8),
      box('${s.bestStreak}', tr('best_streak')),
    ]);
  }

  Widget _calendar(AppState s) {
    final first = DateTime(month.year, month.month, 1);
    final daysIn = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1; // Monday first
    final today = dayStart(DateTime.now());
    final cells = <Widget>[];
    for (var i = 0; i < 7; i++) {
      cells.add(Center(
        child: Text(weekdayShort(i),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.accentDeep)),
      ));
    }
    for (var i = 0; i < lead; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= daysIn; d++) {
      final date = DateTime(month.year, month.month, d);
      final p = s.progressFor(date);
      final isSel = dayKey(date) == dayKey(selected);
      final future = date.isAfter(today);
      cells.add(GestureDetector(
        onTap: future ? null : () => setState(() => selected = date),
        child: Center(
          child: SizedBox(
            width: 38,
            height: 38,
            child: Stack(alignment: Alignment.center, children: [
              if (!future)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: p,
                    strokeWidth: 3,
                    backgroundColor: C.line,
                    color: C.accent,
                  ),
                ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSel ? C.ink : (p >= 1 ? C.accent : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('$d',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isSel || p >= 1 ? Colors.white : (future ? C.line : C.ink),
                    )),
              ),
            ]),
          ),
        ),
      ));
    }
    final canNext = DateTime(month.year, month.month + 1).isBefore(DateTime(today.year, today.month + 1));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(22)),
      child: Column(children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)),
          ),
          Expanded(
            child: Text('${monthName(month.month)} ${month.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: canNext ? () => setState(() => month = DateTime(month.year, month.month + 1)) : null,
          ),
        ]),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          children: cells,
        ),
      ]),
    );
  }

  Widget _weekChart(AppState s) {
    final today = dayStart(DateTime.now());
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final vals = days.map(s.hydrationFor).toList();
    final maxV = [s.goalMl, ...vals].reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('last_7'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        SizedBox(
          height: 150,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (vals[i] > 0)
                    FittedBox(
                      child: Text(s.fmt(vals[i], unit: false),
                          style: const TextStyle(fontSize: 10, color: C.inkSoft)),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    width: 18,
                    height: (110 * vals[i] / maxV).clamp(4.0, 110.0),
                    decoration: BoxDecoration(
                      color: vals[i] >= s.goalMl ? C.accent : C.accent.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(weekdayShort(days[i].weekday - 1),
                      style: const TextStyle(fontSize: 11, color: C.inkSoft, fontWeight: FontWeight.w600)),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}

