import 'package:flutter/material.dart';

import '../app_state.dart';
import '../i18n.dart';
import '../services/purchases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool busy = false;

  @override
  void initState() {
    super.initState();
    if (Purchases.product == null) {
      Purchases.init().then((_) {
        if (mounted) setState(() {});
      });
    }
    AppState.instance.addListener(_onState);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onState);
    super.dispose();
  }

  void _onState() {
    if (AppState.instance.premium && mounted) Navigator.of(context).maybePop();
  }

  Future<void> _buy() async {
    setState(() => busy = true);
    final ok = await Purchases.buy();
    if (!mounted) return;
    setState(() => busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('store_unavailable'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = Purchases.product?.price;
    Widget feature(IconData i, String key) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: C.accentSoft, borderRadius: BorderRadius.circular(12)),
              child: Icon(i, color: C.accentDeep, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(tr(key), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          ]),
        );
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleIconButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
            ),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
              SizedBox(
                height: 170,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (final c in kCharacters.where((c) => c.premium))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MascotThumb(characterId: c.id, size: 120, fill: 0.7),
                    ),
                ]),
              ),
              const SizedBox(height: 8),
              Text(tr('become_hero'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 22),
              feature(Icons.block_rounded, 'pw_1'),
              feature(Icons.pets_rounded, 'pw_2'),
              feature(Icons.local_drink_rounded, 'pw_3'),
              feature(Icons.favorite_rounded, 'pw_4'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: C.accent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tr('lifetime'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(tr('no_recurring'), style: const TextStyle(color: Colors.white)),
                    ]),
                  ),
                  if (price != null)
                    Text(price,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
            child: PillButton(
              label: busy ? '...' : tr('continue'),
              expand: true,
              onTap: busy ? null : _buy,
            ),
          ),
          TextButton(
            onPressed: () async {
              await Purchases.restore();
            },
            child: Text(tr('restore'),
                style: const TextStyle(color: C.inkSoft, decoration: TextDecoration.underline)),
          ),
        ]),
      ),
    );
  }
}
