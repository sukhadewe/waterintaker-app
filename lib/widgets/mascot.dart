import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';

/// One coloured band of the matka's water (a beverage share of the goal).
class FillLayer {
  final Color color;
  final double fraction; // fraction of goal (0..1)
  const FillLayer(this.color, this.fraction);
}

/// An animal friend who visits the matka.
class Friend {
  final String id;
  final String emoji;
  final String en;
  final String hi;
  final String mr;
  final bool premium;
  final int unlockStreak; // free friends unlock after this many streak days
  const Friend(this.id, this.emoji, this.en, this.hi, this.mr, {this.premium = false, this.unlockStreak = 0});

  String get name {
    final l = AppState.instance.lang;
    return l == 'hi' ? hi : (l == 'mr' ? mr : en);
  }
}

const List<Friend> kCharacters = [
  Friend('sparrow', '🐦', 'Chiku the Sparrow', 'चीकू गौरैया', 'चिकू चिमणी'),
  Friend('cat', '🐈', 'Billu the Cat', 'बिल्लू बिल्ली', 'बिल्लू मांजर'),
  Friend('squirrel', '🐿️', 'Gillu the Squirrel', 'गिल्लू गिलहरी', 'गिल्लू खार', unlockStreak: 3),
  Friend('dog', '🐕', 'Moti the Dog', 'मोती कुत्ता', 'मोती कुत्रा', unlockStreak: 7),
  Friend('cow', '🐄', 'Gauri the Cow', 'गौरी गाय', 'गौरी गाय', unlockStreak: 14),
  Friend('goat', '🐐', 'Bholu the Goat', 'भोलू बकरी', 'भोलू शेळी', unlockStreak: 30),
  Friend('parrot', '🦜', 'Mithu the Parrot', 'मिट्ठू तोता', 'मिठू पोपट', premium: true),
  Friend('elephant', '🐘', 'Gajju the Elephant', 'गज्जू हाथी', 'गज्जू हत्ती', premium: true),
  Friend('camel', '🐪', 'Raju the Camel', 'राजू ऊँट', 'राजू उंट', premium: true),
  Friend('tiger', '🐅', 'Sheru the Tiger', 'शेरू बाघ', 'शेरू वाघ', premium: true),
  Friend('peacock', '🦚', 'Mayur the Peacock', 'मयूर मोर', 'मयूर मोर', premium: true),
  Friend('monkey', '🐒', 'Bandu the Monkey', 'बंदू बंदर', 'बंडू माकड', premium: true),
  Friend('owl', '🦉', 'Ullu the Owl', 'उल्लू', 'घुबडू', premium: true),
  Friend('turtle', '🐢', 'Kachhu the Turtle', 'कछुआ काका', 'कासव काका', premium: true),
  Friend('rabbit', '🐇', 'Sonu the Rabbit', 'सोनू खरगोश', 'सोनू ससा', premium: true),
];

Friend characterById(String id) =>
    kCharacters.firstWhere((c) => c.id == id, orElse: () => kCharacters.first);

bool friendUnlocked(Friend f) {
  final s = AppState.instance;
  if (s.premium) return true;
  if (f.premium) return false;
  return s.bestStreak >= f.unlockStreak;
}

// ---------------------------------------------------------------------------
// Matka geometry (in a 200 x 240 box)
// ---------------------------------------------------------------------------
const _clay = Color(0xFFD96A3B);
const _clayDark = Color(0xFFB4502A);
const _clayMouth = Color(0xFF5A2412);

Path matkaBody() => Path()
  ..moveTo(78, 74)
  ..cubicTo(76, 86, 72, 92, 62, 100)
  ..cubicTo(28, 124, 20, 172, 44, 206)
  ..cubicTo(60, 230, 82, 238, 100, 238)
  ..cubicTo(118, 238, 140, 230, 156, 206)
  ..cubicTo(180, 172, 172, 124, 138, 100)
  ..cubicTo(128, 92, 124, 86, 122, 74)
  ..close();

void paintMatka(Canvas canvas, List<FillLayer> layers, double level, double phase,
    {bool bubbles = true, double t = 0}) {
  final body = matkaBody();
  final b = body.getBounds();

  // ground shadow
  canvas.drawOval(const Rect.fromLTRB(46, 228, 154, 244), Paint()..color = const Color(0x22000000));
  // clay body
  canvas.drawPath(body, Paint()..color = _clay);

  // water seen through the clay ("x-ray" window)
  if (level > 0.001) {
    canvas.save();
    canvas.clipPath(body);
    const top = 96.0; // usable water height starts below the neck
    final h = b.bottom - top;
    final total = layers.fold<double>(0, (s, l) => s + l.fraction);
    final k = total > 0 ? level / total : 0.0;
    double cum = 0;
    final amp = level >= 0.999 ? 0.0 : 3.5;
    for (var i = 0; i < layers.length; i++) {
      final f = layers[i].fraction * k;
      if (f <= 0) continue;
      final y0 = b.bottom - cum * h;
      final y1 = b.bottom - math.min(1.0, cum + f) * h;
      final isTop = i == layers.length - 1 || cum + f >= level - 0.0001;
      final p = Path()..moveTo(b.left - 4, y0 + 1);
      if (isTop) {
        for (double x = b.left - 4; x <= b.right + 4; x += 4) {
          p.lineTo(x, y1 + math.sin((x / b.width) * 2 * math.pi * 1.3 + phase) * amp);
        }
      } else {
        p
          ..lineTo(b.left - 4, y1)
          ..lineTo(b.right + 4, y1);
      }
      p
        ..lineTo(b.right + 4, y0 + 1)
        ..close();
      canvas.drawPath(p, Paint()..color = layers[i].color.withValues(alpha: 0.92));
      cum += f;
    }
    final yTop = b.bottom - level * h;
    if (bubbles) {
      final bubble = Paint()..color = Colors.white.withValues(alpha: 0.5);
      for (var j = 0; j < 7; j++) {
        final bt = (t * (1 + j % 3 * 0.35) + j * 0.137) % 1.0;
        final bx = b.left + b.width * (0.22 + 0.56 * ((j * 0.37) % 1.0)) + math.sin(bt * 6 + j) * 4;
        final by = b.bottom - bt * (b.bottom - yTop);
        if (by < yTop + 4) continue;
        canvas.drawCircle(Offset(bx, by), 1.8 + (j % 3), bubble);
      }
    }
    canvas.restore();
  }

  // traditional painted bands
  final band = Paint()
    ..color = Colors.white.withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4;
  canvas.save();
  canvas.clipPath(body);
  canvas.drawArc(const Rect.fromLTRB(20, 96, 180, 140), 0.15, math.pi - 0.3, false, band);
  canvas.drawArc(const Rect.fromLTRB(20, 104, 180, 148), 0.15, math.pi - 0.3, false, band);
  // little triangles (warli style) along the band
  final tri = Paint()..color = Colors.white.withValues(alpha: 0.85);
  for (var i = 0; i < 9; i++) {
    final x = 40.0 + i * 15;
    final y = 150.0 - math.sin((x - 100) / 60) * 4;
    canvas.drawPath(
      Path()
        ..moveTo(x - 4, y)
        ..lineTo(x + 4, y)
        ..lineTo(x, y + 7)
        ..close(),
      tri,
    );
  }
  // soft highlight
  canvas.drawOval(const Rect.fromLTRB(42, 118, 62, 190), Paint()..color = Colors.white.withValues(alpha: 0.16));
  canvas.restore();

  // rim + mouth
  canvas.drawRRect(RRect.fromLTRBR(66, 60, 134, 78, const Radius.circular(9)), Paint()..color = _clayDark);
  canvas.drawOval(const Rect.fromLTRB(74, 61, 126, 71), Paint()..color = _clayMouth);
  if (level > 0.999) {
    canvas.drawOval(const Rect.fromLTRB(78, 63, 122, 70), Paint()..color = C.accent);
  }
}

void _emoji(Canvas c, String e, Offset center, double size, {bool flip = false}) {
  final tp = TextPainter(
    text: TextSpan(text: e, style: TextStyle(fontSize: size, height: 1)),
    textDirection: TextDirection.ltr,
  )..layout();
  c.save();
  c.translate(center.dx, center.dy);
  if (flip) c.scale(-1, 1);
  tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  c.restore();
}

/// Home scene: the matka fills with your drinks, your buddy sits beside it
/// and more animal friends come to visit as the matka fills up.
class Mascot extends StatefulWidget {
  final String characterId; // the buddy
  final List<FillLayer> layers;
  final double height;
  final bool animateWave;
  final int pokes; // change to make everyone hop

  const Mascot({
    super.key,
    required this.characterId,
    required this.layers,
    this.height = 300,
    this.animateWave = true,
    this.pokes = 0,
  });

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late final AnimationController _hop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 750));

  double _total(List<FillLayer> l) => l.fold<double>(0, (s, x) => s + x.fraction);

  @override
  void initState() {
    super.initState();
    if (widget.animateWave) _loop.repeat();
  }

  @override
  void didUpdateWidget(covariant Mascot old) {
    super.didUpdateWidget(old);
    if (widget.animateWave &&
        (_total(widget.layers) > _total(old.layers) + 0.0001 || widget.pokes != old.pokes)) {
      _hop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _hop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = _total(widget.layers).clamp(0.0, 1.0);
    final buddy = characterById(widget.characterId);
    final visitors = kCharacters
        .where((f) => f.id != buddy.id && friendUnlocked(f))
        .take(4)
        .map((f) => f.emoji)
        .toList();
    const fallback = ['🐦', '🐿️', '🦜', '🦚'];
    while (visitors.length < 4) {
      visitors.add(fallback[visitors.length]);
    }
    return SizedBox(
      height: widget.height,
      width: widget.height * 220 / 240,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, level, _) => AnimatedBuilder(
          animation: Listenable.merge([_loop, _hop]),
          builder: (context, _) => CustomPaint(
            painter: _ScenePainter(
              buddy.emoji,
              visitors,
              widget.layers,
              level,
              _loop.value,
              widget.animateWave ? _hop.value : 0,
              widget.animateWave,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final String buddy;
  final List<String> visitors;
  final List<FillLayer> layers;
  final double level;
  final double t;
  final double hop;
  final bool alive;
  _ScenePainter(this.buddy, this.visitors, this.layers, this.level, this.t, this.hop, this.alive);

  @override
  void paint(Canvas canvas, Size size) {
    final phase = t * 2 * math.pi;
    final scale = math.min(size.width / 220, size.height / 240);
    canvas.save();
    canvas.translate((size.width - 220 * scale) / 2, (size.height - 240 * scale) / 2);
    canvas.scale(scale);
    canvas.translate(10, 0);

    final hopping = hop > 0 && hop < 1;
    final jump = hopping ? math.sin(hop * math.pi) : 0.0;

    canvas.save();
    if (alive) {
      final wob = hopping ? math.sin(hop * math.pi * 4) * 0.035 * (1 - hop) : 0.0;
      canvas.translate(100, 238);
      canvas.rotate(wob);
      canvas.translate(-100, -238);
    }
    paintMatka(canvas, layers, level, phase, bubbles: alive, t: t);
    canvas.restore();

    if (!alive) {
      _emoji(canvas, buddy, const Offset(180, 206), 40);
      canvas.restore();
      return;
    }

    double bob(double off, [double amp = 3]) => math.sin(phase * 2 + off) * amp;

    if (level >= 0.25) {
      _emoji(canvas, visitors[0], Offset(118, 46 + bob(0.5) - jump * 14), 26, flip: true);
    }
    if (level >= 0.5) {
      _emoji(canvas, visitors[1], Offset(14, 214 + bob(1.7) - jump * 10), 30);
    }
    if (level >= 0.75) {
      final a = phase;
      _emoji(canvas, visitors[2], Offset(100 + math.cos(a) * 70, 40 + math.sin(a * 2) * 10), 24,
          flip: math.sin(a) > 0);
    }
    if (level >= 0.999) {
      _emoji(canvas, visitors[3], Offset(30, 140 + bob(2.4, 4) - jump * 16), 34);
      final sp = Paint()..color = C.accent;
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3 + phase;
        final r = 108 + math.sin(phase * 2 + i) * 6;
        canvas.drawCircle(Offset(100 + math.cos(a) * r * 0.75, 150 + math.sin(a) * r * 0.65), 2.5, sp);
      }
    }
    _emoji(canvas, buddy, Offset(180, 206 + bob(0) - jump * 22), 44);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.level != level || old.t != t || old.hop != hop || old.buddy != buddy || old.layers != layers;
}

/// Small static matka (used in onboarding cards & history).
class MascotThumb extends StatelessWidget {
  final String characterId;
  final double size;
  final double fill;
  const MascotThumb({super.key, required this.characterId, this.size = 80, this.fill = 0.6});

  @override
  Widget build(BuildContext context) => Mascot(
        characterId: characterId,
        layers: [FillLayer(C.accent, fill)],
        height: size,
        animateWave: false,
      );
}

/// Round badge showing a friend's emoji (used in pickers).
class FriendBadge extends StatelessWidget {
  final Friend friend;
  final double size;
  final bool locked;
  const FriendBadge({super.key, required this.friend, this.size = 64, this.locked = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: C.accentSoft, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Opacity(
        opacity: locked ? 0.35 : 1,
        child: Text(friend.emoji, style: TextStyle(fontSize: size * 0.55, height: 1)),
      ),
    );
  }
}

/// App logo: a little matka on a black tile + wordmark.
class AppLogo extends StatelessWidget {
  final double size;
  final bool wordmark;
  const AppLogo({super.key, this.size = 44, this.wordmark = true});

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(width: size, height: size, child: CustomPaint(painter: _LogoPainter()));
    if (!wordmark) return mark;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      mark,
      SizedBox(width: size * 0.25),
      Text('Jal Mitra',
          style: TextStyle(
              fontSize: size * 0.72, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: C.ink)),
    ]);
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width * 0.28));
    canvas.drawRRect(r, Paint()..color = C.ink);
    final s = size.width / 240 * 0.86;
    canvas.save();
    canvas.translate(size.width / 2 - 100 * s, size.height / 2 - 150 * s);
    canvas.scale(s);
    paintMatka(canvas, const [FillLayer(C.accent, 0.55)], 0.55, 0, bubbles: false);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
