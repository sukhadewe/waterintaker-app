import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../data/beverages.dart';
import '../i18n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'add_drink.dart';
import 'paywall.dart';

class BeveragesScreen extends StatefulWidget {
  const BeveragesScreen({super.key});

  @override
  State<BeveragesScreen> createState() => _BeveragesScreenState();
}

class _BeveragesScreenState extends State<BeveragesScreen> {
  String cat = 'all';

  void _toggle(String id, bool on) {
    final s = AppState.instance;
    if (on && !s.premium && s.quickBar.length >= AppState.freeQuickLimit) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(tr('quick_limit')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('cancel'))),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true));
              },
              child: Text(tr('get_premium')),
            ),
          ],
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    s.update((st) {
      if (on) {
        if (!st.quickBar.contains(id)) st.quickBar.add(id);
      } else {
        if (st.quickBar.length > 1) st.quickBar.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final all = cat == 'all' ? kBeverages : kBeverages.where((b) => b.category == cat).toList();
        final enabled = all.where((b) => s.quickBar.contains(b.id)).toList()
          ..sort((a, b) => s.quickBar.indexOf(a.id).compareTo(s.quickBar.indexOf(b.id)));
        final rest = all.where((b) => !s.quickBar.contains(b.id)).toList();
        final list = [...enabled, ...rest];
        return Scaffold(
          appBar: AppBar(title: Text(tr('beverages'))),
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(tr('beverages_sub'),
                  textAlign: TextAlign.center, style: const TextStyle(color: C.inkSoft)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  for (final c in kCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c == 'all' ? '${tr('cat_all')} ${kBeverages.length}' : tr('cat_$c')),
                        selected: cat == c,
                        showCheckmark: false,
                        selectedColor: C.ink,
                        labelStyle: TextStyle(
                            color: cat == c ? Colors.white : C.ink, fontWeight: FontWeight.w600),
                        side: const BorderSide(color: C.line),
                        onSelected: (_) => setState(() => cat = c),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final b = list[i];
                  final on = s.quickBar.contains(b.id);
                  final sub = beverageSubtitle(b);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: on ? C.accentSoft : C.card,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => showAddDrinkSheet(context, b),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(children: [
                            DrinkIcon(beverage: b, size: 34),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(b.name(s.lang),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                if (sub.isNotEmpty)
                                  Text(sub, style: const TextStyle(fontSize: 12, color: C.inkSoft)),
                              ]),
                            ),
                            Text('${b.hydration}%',
                                style: TextStyle(
                                    color: b.hydration < 0 ? C.danger : C.inkSoft,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Switch(value: on, onChanged: (v) => _toggle(b.id, v)),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        );
      },
    );
  }
}
