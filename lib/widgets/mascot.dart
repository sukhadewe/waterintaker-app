import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// One coloured band of the character's fill (a beverage share of the goal).
class FillLayer {
  final Color color;
  final double fraction; // fraction of goal (0..1)
  const FillLayer(this.color, this.fraction);
}

class CharacterDef {
  final String id;
  final String name;
  final bool premium;
  final Path Function() silhouette; // in a 200 x 240 box
  final void Function(Canvas c, double level) features;
  const CharacterDef(this.id, this.name, this.premium, this.silhouette, this.features);
}

const _ink = C.ink;
const _blush = Color(0x55FF7A9A);

Path _oval(double l, double t, double r, double b) => Path()..addOval(Rect.fromLTRB(l, t, r, b));

Path _rotOval(double cx, double cy, double w, double h, double angle) {
  final m = Matrix4.identity()
    ..translate(cx, cy)
    ..rotateZ(angle)
    ..translate(-cx, -cy);
  return _oval(cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2).transform(m.storage);
}

Path _union(List<Path> parts) {
  var p = parts.first;
  for (final q in parts.skip(1)) {
    p = Path.combine(PathOperation.union, p, q);
  }
  return p;
}

void _eye(Canvas c, double x, double y, double r) {
  c.drawCircle(Offset(x, y), r, Paint()..color = _ink);
  c.drawCircle(Offset(x + r * 0.35, y - r * 0.35), r * 0.38, Paint()..color = Colors.white);
}

void _smile(Canvas c, Offset a, Offset ctrl, Offset b, {double w = 3}) {
  c.drawPath(
    Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy),
    Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w,
  );
}

// ---------------- Penguin (free) ----------------
Path _penguin() => _union([
      _oval(50, 22, 150, 122),
      _oval(32, 72, 168, 228),
      _rotOval(36, 146, 26, 74, 0.38),
      _rotOval(164, 146, 26, 74, -0.38),
      _oval(60, 214, 98, 238),
      _oval(102, 214, 140, 238),
    ]);

void _penguinFx(Canvas c, double level) {
  // belly sheen
  c.drawOval(const Rect.fromLTRB(60, 104, 140, 218), Paint()..color = Colors.white.withValues(alpha: 0.38));
  _eye(c, 82, 68, 7.5);
  _eye(c, 118, 68, 7.5);
  c.drawOval(const Rect.fromLTRB(62, 84, 78, 94), Paint()..color = _blush);
  c.drawOval(const Rect.fromLTRB(122, 84, 138, 94), Paint()..color = _blush);
  final beak = Path()
    ..moveTo(90, 82)
    ..quadraticBezierTo(100, 78, 110, 82)
    ..quadraticBezierTo(104, 96, 100, 97)
    ..quadraticBezierTo(96, 96, 90, 82)
    ..close();
  c.drawPath(beak, Paint()..color = C.coral);
  // feet tint
  c.drawOval(const Rect.fromLTRB(64, 222, 94, 236), Paint()..color = C.coral.withValues(alpha: 0.85));
  c.drawOval(const Rect.fromLTRB(106, 222, 136, 236), Paint()..color = C.coral.withValues(alpha: 0.85));
}

// ---------------- Whale ----------------
Path _whale() => _union([
      _oval(16, 96, 188, 222),
      _rotOval(24, 120, 22, 60, -0.5),
      _rotOval(10, 92, 46, 20, -0.55),
      _rotOval(42, 84, 46, 20, 0.55),
      _oval(124, 54, 138, 70),
      _oval(110, 40, 122, 52),
      _oval(140, 38, 152, 50),
      _rotOval(120, 206, 44, 22, 0.4),
    ]);

void _whaleFx(Canvas c, double level) {
  c.drawOval(const Rect.fromLTRB(48, 172, 176, 220), Paint()..color = Colors.white.withValues(alpha: 0.38));
  _eye(c, 150, 140, 7);
  c.drawOval(const Rect.fromLTRB(150, 152, 168, 162), Paint()..color = _blush);
  _smile(c, const Offset(140, 168), const Offset(160, 182), const Offset(178, 162));
}

// ---------------- Cat ----------------
Path _cat() => _union([
      _oval(48, 30, 152, 130),
      Path()
        ..moveTo(52, 62)
        ..lineTo(60, 10)
        ..lineTo(98, 40)
        ..close(),
      Path()
        ..moveTo(148, 62)
        ..lineTo(140, 10)
        ..lineTo(102, 40)
        ..close(),
      _oval(44, 108, 156, 228),
      _rotOval(166, 178, 22, 80, 0.45),
      _oval(60, 214, 96, 238),
      _oval(104, 214, 140, 238),
    ]);

void _catFx(Canvas c, double level) {
  c.drawOval(const Rect.fromLTRB(70, 132, 130, 218), Paint()..color = Colors.white.withValues(alpha: 0.35));
  _eye(c, 80, 78, 7.5);
  _eye(c, 120, 78, 7.5);
  c.drawOval(const Rect.fromLTRB(62, 94, 78, 104), Paint()..color = _blush);
  c.drawOval(const Rect.fromLTRB(122, 94, 138, 104), Paint()..color = _blush);
  c.drawPath(
    Path()
      ..moveTo(95, 92)
      ..lineTo(105, 92)
      ..lineTo(100, 98)
      ..close(),
    Paint()..color = C.coral,
  );
  _smile(c, const Offset(92, 102), const Offset(96, 108), const Offset(100, 102), w: 2.4);
  _smile(c, const Offset(100, 102), const Offset(104, 108), const Offset(108, 102), w: 2.4);
  final wh = Paint()
    ..color = _ink.withValues(alpha: 0.5)
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  c.drawLine(const Offset(56, 96), const Offset(34, 92), wh);
  c.drawLine(const Offset(56, 102), const Offset(34, 104), wh);
  c.drawLine(const Offset(144, 96), const Offset(166, 92), wh);
  c.drawLine(const Offset(144, 102), const Offset(166, 104), wh);
}

// ---------------- Bunny ----------------
Path _bunny() => _union([
      _rotOval(80, 40, 28, 78, -0.12),
      _rotOval(120, 40, 28, 78, 0.12),
      _oval(54, 46, 146, 138),
      _oval(42, 112, 158, 230),
      _oval(58, 216, 96, 238),
      _oval(104, 216, 142, 238),
    ]);

void _bunnyFx(Canvas c, double level) {
  c.drawOval(const Rect.fromLTRB(70, 140, 130, 222), Paint()..color = Colors.white.withValues(alpha: 0.38));
  c.drawOval(const Rect.fromLTRB(74, 14, 86, 62), Paint()..color = _blush);
  c.drawOval(const Rect.fromLTRB(114, 14, 126, 62), Paint()..color = _blush);
  _eye(c, 82, 90, 7);
  _eye(c, 118, 90, 7);
  c.drawOval(const Rect.fromLTRB(64, 104, 80, 114), Paint()..color = _blush);
  c.drawOval(const Rect.fromLTRB(120, 104, 136, 114), Paint()..color = _blush);
  c.drawOval(const Rect.fromLTRB(95, 100, 105, 107), Paint()..color = C.coral);
  _smile(c, const Offset(92, 110), const Offset(100, 118), const Offset(108, 110), w: 2.4);
}

// ---------------- Blob / drop ----------------
Path _drop() => Path()
  ..moveTo(100, 8)
  ..cubicTo(130, 60, 176, 110, 176, 160)
  ..cubicTo(176, 205, 142, 236, 100, 236)
  ..cubicTo(58, 236, 24, 205, 24, 160)
  ..cubicTo(24, 110, 70, 60, 100, 8)
  ..close();

void _dropFx(Canvas c, double level) {
  c.drawOval(const Rect.fromLTRB(46, 120, 66, 170), Paint()..color = Colors.white.withValues(alpha: 0.45));
  _eye(c, 80, 150, 8);
  _eye(c, 120, 150, 8);
  c.drawOval(const Rect.fromLTRB(60, 166, 78, 176), Paint()..color = _blush);
  c.drawOval(const Rect.fromLTRB(122, 166, 140, 176), Paint()..color = _blush);
  _smile(c, const Offset(90, 172), const Offset(100, 184), const Offset(110, 172));
}

final List<CharacterDef> kCharacters = [
  CharacterDef('penguin', 'Pingu', false, _penguin, _penguinFx),
  CharacterDef('drop', 'Bindu', false, _drop, _dropFx),
  CharacterDef('whale', 'Neel', true, _whale, _whaleFx),
  CharacterDef('cat', 'Billi', true, _cat, _catFx),
  CharacterDef('bunny', 'Gogo', true, _bunny, _bunnyFx),
];

CharacterDef characterById(String id) =>
    kCharacters.firstWhere((c) => c.id == id, orElse: () => kCharacters.first);

/// Animated character that fills from the bottom with coloured beverage layers.
class Mascot extends StatefulWidget {
  final String characterId;
  final List<FillLayer> layers;
  final double height;
  final bool animateWave;

  const Mascot({
    super.key,
    required this.characterId,
    required this.layers,
    this.height = 300,
    this.animateWave = true,
  });

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _wave =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    if (widget.animateWave) _wave.repeat();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.layers.fold<double>(0, (s, l) => s + l.fraction).clamp(0.0, 1.0);
    final def = characterById(widget.characterId);
    return SizedBox(
      height: widget.height,
      width: widget.height * 200 / 240,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, level, _) => AnimatedBuilder(
          animation: _wave,
          builder: (context, _) => CustomPaint(
            painter: _MascotPainter(def, widget.layers, level, _wave.value * 2 * math.pi),
          ),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final CharacterDef def;
  final List<FillLayer> layers;
  final double level;
  final double phase;
  _MascotPainter(this.def, this.layers, this.level, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 200, size.height / 240);
    canvas.save();
    canvas.translate((size.width - 200 * scale) / 2, (size.height - 240 * scale) / 2);
    canvas.scale(scale);

    final sil = def.silhouette();
    final b = sil.getBounds();
    canvas.drawPath(sil, Paint()..color = C.empty);

    if (level > 0.001) {
      canvas.save();
      canvas.clipPath(sil);
      final total = layers.fold<double>(0, (s, l) => s + l.fraction);
      final scaleL = total > 0 ? level / total.clamp(0.0001, 1000.0) : 0.0;
      double cum = 0;
      final h = b.height;
      final amp = level >= 0.999 ? 0.0 : 4.5;
      for (var i = 0; i < layers.length; i++) {
        final l = layers[i];
        final f = l.fraction * (scaleL.isFinite ? scaleL : 0);
        if (f <= 0) continue;
        final y0 = b.bottom - cum * h; // bottom of band
        final y1 = b.bottom - math.min(1.0, cum + f) * h; // top of band
        final isTop = i == layers.length - 1 || cum + f >= level - 0.0001;
        final p = Path()..moveTo(b.left - 4, y0 + 1);
        if (isTop) {
          for (double x = b.left - 4; x <= b.right + 4; x += 4) {
            final y = y1 + math.sin((x / b.width) * 2 * math.pi * 1.3 + phase) * amp;
            p.lineTo(x, y);
          }
        } else {
          p.lineTo(b.left - 4, y1);
          p.lineTo(b.right + 4, y1);
        }
        p
          ..lineTo(b.right + 4, y0 + 1)
          ..close();
        canvas.drawPath(p, Paint()..color = l.color);
        cum += f;
      }
      // light back-wave for depth
      if (level < 0.999) {
        final yTop = b.bottom - level * h;
        final back = Path()..moveTo(b.left - 4, yTop + 10);
        for (double x = b.left - 4; x <= b.right + 4; x += 4) {
          back.lineTo(x, yTop + math.sin((x / b.width) * 2 * math.pi * 1.1 - phase + 1.4) * 5);
        }
        back
          ..lineTo(b.right + 4, yTop + 10)
          ..close();
        canvas.drawPath(back, Paint()..color = Colors.white.withValues(alpha: 0.22));
      }
      canvas.restore();
    }

    def.features(canvas, level);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) =>
      old.level != level || old.phase != phase || old.def != def || old.layers != layers;
}

/// Small static preview used in pickers.
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
