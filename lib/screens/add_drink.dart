import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../data/beverages.dart';
import '../i18n.dart';
import '../models.dart';
import '../services/ads.dart';
import '../services/notifications.dart';
import '../theme.dart';
import '../widgets/common.dart';

String beverageSubtitle(Beverage b) {
  if (b.alcohol != null) return tr('alc_${b.alcohol}');
  if (b.caffeine > 0) return tr('caffeine', {'n': '${b.caffeine}'});
  return '';
}

/// Bottom sheet to choose an amount and log a drink.
/// Returns the created entry (or null when cancelled).
Future<Entry?> showAddDrinkSheet(BuildContext context, Beverage b, {DateTime? at}) {
  final s = AppState.instance;
  int amount = s.lastAmount[b.id] ?? (b.vessel == Vessel.mug ? 150 : 250);
  return showModalBottomSheet<Entry>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
      final hyd = (amount * b.hydration / 100).round();
      final presets = s.presetAmounts;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DrinkIcon(beverage: b, size: 72, fill: (amount / 750).clamp(0.15, 1.0)),
            const SizedBox(height: 8),
            Text(b.name(s.lang), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            if (beverageSubtitle(b).isNotEmpty)
              Text(beverageSubtitle(b), style: const TextStyle(color: C.inkSoft)),
            const SizedBox(height: 14),
            Text(s.fmt(amount),
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: C.accent)),
            Text(
              hyd >= 0 ? tr('counts_as', {'n': s.fmt(hyd)}) : tr('dehydrates', {'n': s.fmt(-hyd)}),
              style: TextStyle(color: hyd >= 0 ? C.inkSoft : C.danger, fontSize: 13),
            ),
            Slider(
              value: amount.toDouble().clamp(30, 1500),
              min: 30,
              max: 1500,
              divisions: (1500 - 30) ~/ 10,
              activeColor: C.accent,
              onChanged: (v) => setSt(() => amount = (v / 10).round() * 10),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final p in presets)
                  ChoiceChip(
                    label: Text(s.fmt(p)),
                    selected: amount == p,
                    showCheckmark: false,
                    selectedColor: C.accentSoft,
                    side: BorderSide(color: amount == p ? C.accent : C.line),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setSt(() => amount = p);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PillButton(
              label: '${tr('add')}  ${s.fmt(amount)}',
              icon: Icons.add_rounded,
              expand: true,
              onTap: () {
                if (s.soundsOn) HapticFeedback.mediumImpact();
                final e = s.addDrink(b.id, amount, at: at);
                Reminders.reschedule();
                Ads.onDrinkLogged();
                Navigator.pop(ctx, e);
              },
            ),
          ]),
        ),
      );
    }),
  );
}

/// Pick any beverage (used by "Add missed").
Future<Beverage?> pickBeverage(BuildContext context) {
  final s = AppState.instance;
  final list = [
    ...s.quickBar.map(beverageById),
    ...kBeverages.where((b) => !s.quickBar.contains(b.id)),
  ];
  return showModalBottomSheet<Beverage>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.7,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final b = list[i];
          return ListTile(
            leading: DrinkIcon(beverage: b, size: 34),
            title: Text(b.name(s.lang), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: beverageSubtitle(b).isEmpty ? null : Text(beverageSubtitle(b)),
            trailing: Text('${b.hydration}%', style: const TextStyle(color: C.inkSoft)),
            onTap: () => Navigator.pop(ctx, b),
          );
        },
      ),
    ),
  );
}
