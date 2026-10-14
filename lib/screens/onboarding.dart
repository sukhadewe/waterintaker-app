import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../i18n.dart';
import '../services/notifications.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import 'goal.dart';
import 'paywall.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int step = 0;
  double welcomeFill = 0;
  Timer? _timer;
  bool sipped = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (step == 0 && mounted) {
        setState(() => welcomeFill = welcomeFill >= 1 ? 0 : (welcomeFill + 0.34).clamp(0.0, 1.0));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void next() => setState(() => step++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: KeyedSubtree(key: ValueKey(step), child: _page()),
      ),
    );
  }

  Widget _page() {
    switch (step) {
      case 0:
        return _welcome();
      case 1:
        return _units();
      case 2:
        return _firstSip();
      case 3:
        return _reminders();
      case 4:
        return GoalPanel(onDone: next);
      default:
        return _benefits();
    }
  }

  Widget _skip(VoidCallback onTap) => Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: onTap,
          child: Text(tr('skip'),
              style: const TextStyle(color: C.inkSoft, decoration: TextDecoration.underline, fontSize: 13)),
        ),
      );

  Widget _welcome() {
    final layers = <FillLayer>[
      if (welcomeFill > 0) FillLayer(C.accent, welcomeFill.clamp(0, 0.34)),
      if (welcomeFill > 0.34) FillLayer(const Color(0xFFC08A5B), (welcomeFill - 0.34).clamp(0, 0.34)),
      if (welcomeFill > 0.68) FillLayer(const Color(0xFFF4A23A), (welcomeFill - 0.68).clamp(0, 0.32)),
    ];
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 36),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 10),
            const Text('Waddle',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: C.ink)),
          ]),
          const SizedBox(height: 10),
          Text(tr('tagline'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: C.inkSoft)),
          const Spacer(),
          Mascot(characterId: 'penguin', layers: layers, height: 330),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _pickLanguage,
                icon: const Icon(Icons.translate_rounded, color: C.ink, size: 20),
                label: Text(kLanguages[AppState.instance.lang] ?? 'English',
                    style: const TextStyle(color: C.ink, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              PillButton(label: tr('get_started'), onTap: next),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickLanguage() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(tr('language'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final e in kLanguages.entries)
            ListTile(
              title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: AppState.instance.lang == e.key
                  ? const Icon(Icons.check_rounded, color: C.accent)
                  : null,
              onTap: () {
                AppState.instance.update((s) => s.lang = e.key);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 12),
        ]),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _units() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(),
            const MascotThumb(characterId: 'penguin', size: 220, fill: 0.15),
            const Spacer(),
            Text(tr('choose_units'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            PillButton(
              label: tr('ml_units'),
              accent: true,
              expand: true,
              onTap: () {
                AppState.instance.update((s) => s.useOz = false);
                next();
              },
            ),
            const SizedBox(height: 12),
            PillButton(
              label: tr('oz_units'),
              accent: true,
              expand: true,
              onTap: () {
                AppState.instance.update((s) => s
                  ..useOz = true
                  ..weightLbs = true);
                next();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _firstSip() {
    final s = AppState.instance;
    final amount = s.useOz ? (8 * 29.5735).round() : 250;
    return SafeArea(
      child: Column(
        children: [
          _skip(next),
          Text(tr('first_sip'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(tr('first_sip_hint'), style: const TextStyle(color: C.inkSoft)),
          const Spacer(),
          if (sipped)
            Text(s.fmt(amount),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: C.accent)),
          Mascot(
            characterId: 'penguin',
            layers: [if (sipped) FillLayer(C.accent, amount / s.goalMl)],
            height: 320,
          ),
          const Spacer(),
          GestureDetector(
            onTap: sipped
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    s.addDrink('water', amount);
                    setState(() => sipped = true);
                    Future.delayed(const Duration(milliseconds: 1600), () {
                      if (mounted && step == 2) next();
                    });
                  },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: sipped ? 0.3 : 1,
              child: Column(children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(color: C.accentSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.local_drink_rounded, color: C.accent, size: 40),
                ),
                const SizedBox(height: 6),
                Text(tr('add_water'),
                    style: const TextStyle(color: C.accentDeep, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _reminders() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            _skip(next),
            Text(tr('smart_reminders'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(tr('smart_reminders_sub'),
                textAlign: TextAlign.center, style: const TextStyle(color: C.inkSoft, fontSize: 15)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: C.accentSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.water_drop_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tr('notif_title'), style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(tr('n2'), style: const TextStyle(fontSize: 13, color: C.inkSoft)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                const MascotThumb(characterId: 'penguin', size: 190, fill: 0.55),
              ]),
            ),
            const Spacer(),
            PillButton(
              label: tr('remind_me'),
              expand: true,
              onTap: () async {
                final ok = await Reminders.requestPermission();
                AppState.instance.update((s) => s.remindersOn = ok);
                await Reminders.reschedule();
                next();
              },
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _benefits() {
    Widget item(String key, bool good) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(good ? Icons.check_circle_rounded : Icons.close_rounded,
                size: 20, color: good ? Colors.white : C.inkSoft),
            const SizedBox(width: 8),
            Expanded(
                child: Text(tr(key),
                    style: TextStyle(fontSize: 14, color: good ? Colors.white : C.ink, height: 1.3))),
          ]),
        );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 36),
          Text(tr('feel_best'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const Spacer(),
          SizedBox(
            height: 400,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(24)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr('when_dehydrated'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.inkSoft)),
                    const SizedBox(height: 12),
                    item('dh1', false),
                    item('dh2', false),
                    item('dh3', false),
                    const Spacer(),
                    const Center(child: MascotThumb(characterId: 'penguin', size: 110, fill: 0.08)),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(24)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr('when_hydrated'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 12),
                    item('hy1', true),
                    item('hy2', true),
                    item('hy3', true),
                    const Spacer(),
                    Center(
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(8),
                        child: const MascotThumb(characterId: 'penguin', size: 110, fill: 1),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
          const Spacer(),
          PillButton(
            label: tr('feel_my_best'),
            onTap: () async {
              AppState.instance.update((s) => s.onboarded = true);
              await Future<void>.delayed(const Duration(milliseconds: 400));
              final nav = AppNavigator.key.currentState;
              nav?.push(MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true));
            },
          ),
          const SizedBox(height: 36),
        ]),
      ),
    );
  }
}

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();
}
