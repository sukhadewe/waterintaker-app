import 'dart:math' as math;

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
import '../widgets/mascot.dart';
import 'add_drink.dart';
import 'beverages.dart';
import 'history.dart';
import 'settings.dart';

List<FillLayer> layersForDay(AppState s, DateTime day) {
  final list = s.entriesFor(day);
  final goal = s.goalMl;
  final pos = <FillLayer>[];
  int positive = 0;
  for (final e in list) {
    if (e.hydrationMl <= 0) continue;
    positive += e.hydrationMl;
    final c = beverageById(e.beverageId).color;
    if (pos.isNotEmpty && pos.last.color == c) {
      final last = pos.removeLast();
      pos.add(FillLayer(c, last.fraction + e.hydrationMl / goal));
    } else {
      pos.add(FillLayer(c, e.hydrationMl / goal));
    }
  }
  final net = s.hydrationFor(day);
  if (positive == 0 || net >= positive) return pos;
  final k = net / positive;
  return pos.map((l) => FillLayer(l.color, l.fraction * k)).toList();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _showRemaining = false;
  bool _confetti = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {}); // new day roll-over
      Reminders.reschedule();
    }
  }

  Future<void> _add(Beverage b) async {
    final s = AppState.instance;
    final wasDone = s.goalReached(DateTime.now());
    final e = await showAddDrinkSheet(context, b);
    if (e == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.ink,
      content: Text(tr('added', {'n': '${s.fmt(e.volumeMl)} ${b.name(s.lang)}'})),
      action: SnackBarAction(
        label: tr('undo'),
        textColor: C.accent,
        onPressed: () {
          s.removeEntry(e.id);
          Reminders.reschedule();
        },
      ),
    ));
    final today = dayKey(DateTime.now());
    if (!wasDone && s.goalReached(DateTime.now()) && s.celebratedDay != today) {
      s.update((st) => st.celebratedDay = today);
      if (s.soundsOn) HapticFeedback.heavyImpact();
      setState(() => _confetti = true);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _confetti = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final now = DateTime.now();
        final ml = s.todayMl;
        final pct = (ml * 100 / s.goalMl).round();
        final done = ml >= s.goalMl;
        final streak = s.currentStreak;
        final quick = s.quickBar.map(beverageById).toList();
        return Scaffold(
          body: Stack(children: [
            SafeArea(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(children: [
                    _StreakChip(
                      streak: streak,
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    ),
                    const Spacer(),
                    CircleIconButton(
                      icon: Icons.tune_rounded,
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  child: Text(s.fmt(ml),
                      style: const TextStyle(
                          fontSize: 46, fontWeight: FontWeight.w800, color: C.accent, height: 1.1)),
                ),
                const SizedBox(height: 4),
                Text(
                  done ? tr('goal_done') : tr('hydration_of_goal', {'p': '$pct'}),
                  style: const TextStyle(color: C.inkSoft, fontSize: 15),
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, c) {
                    final h = math.min(c.maxHeight * 0.92, c.maxWidth * 1.1);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _showRemaining = !_showRemaining);
                      },
                      child: Center(
                        child: Stack(alignment: Alignment.center, children: [
                          Mascot(
                            characterId: s.character,
                            layers: layersForDay(s, now),
                            height: h,
                          ),
                          AnimatedOpacity(
                            opacity: _showRemaining ? 1 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: C.ink.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                done
                                    ? tr('goal_done')
                                    : tr('left_to_drink', {'n': s.fmt(s.goalMl - ml)}),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: 96,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final b in quick) _QuickDrink(b: b, onTap: () => _add(b)),
                      _QuickEdit(
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const BeveragesScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const BannerAdBox(),
              ]),
            ),
            if (_confetti) const Positioned.fill(child: IgnorePointer(child: Confetti())),
            if (_confetti)
              Positioned(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).padding.top + 120,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(20)),
                    child: Text(tr('celebrate'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int streak;
  final VoidCallback onTap;
  const _StreakChip({required this.streak, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.accent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text('$streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    );
  }
}

class _QuickDrink extends StatelessWidget {
  final Beverage b;
  final VoidCallback onTap;
  const _QuickDrink({required this.b, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          DrinkIcon(beverage: b, size: 46),
          const SizedBox(height: 6),
          Text(
            b.name(s.lang).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: C.inkSoft, letterSpacing: 0.3),
          ),
        ]),
      ),
    );
  }
}

class _QuickEdit extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickEdit({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(tr('edit').toUpperCase(),
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: C.inkSoft)),
        ]),
      ),
    );
  }
}

/// Lightweight confetti burst.
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3800))..forward();
  final _rnd = math.Random();
  late final List<_Piece> _pieces = List.generate(
    90,
    (_) => _Piece(
      x: _rnd.nextDouble(),
      delay: _rnd.nextDouble() * 0.35,
      speed: 0.6 + _rnd.nextDouble() * 0.6,
      drift: (_rnd.nextDouble() - 0.5) * 0.25,
      spin: _rnd.nextDouble() * 10,
      color: [C.accent, C.ink, C.coral, const Color(0xFF9AA4FF), C.accentDeep][_rnd.nextInt(5)],
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(painter: _ConfettiPainter(_pieces, _c.value)),
      );
}

class _Piece {
  final double x, delay, speed, drift, spin;
  final Color color;
  _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final lt = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (lt <= 0) continue;
      final y = -20 + lt * p.speed * (size.height + 60);
      final x = (p.x + p.drift * lt) * size.width;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * lt);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -7, 8, 14), const Radius.circular(2)),
        Paint()..color = p.color.withValues(alpha: 1 - lt * 0.6),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
