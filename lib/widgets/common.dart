import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool accent;
  final IconData? icon;
  final double height;
  final bool expand;

  const PillButton({
    super.key,
    required this.label,
    this.onTap,
    this.accent = false,
    this.icon,
    this.height = 56,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = accent ? C.accent : C.ink;
    final child = Material(
      color: onTap == null ? bg.withValues(alpha: 0.35) : bg,
      borderRadius: BorderRadius.circular(height / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(height / 2),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class SettingTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                SizedBox(width: 28, child: Center(child: leading)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(subtitle!, style: const TextStyle(fontSize: 13, color: C.inkSoft)),
                      ],
                    ],
                  ),
                ),
                if (value != null)
                  Text(value!, style: const TextStyle(fontSize: 14, color: C.inkSoft)),
                if (trailing != null) trailing!,
                if (trailing == null && onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.chevron_right_rounded, color: C.inkSoft),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CircleIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: C.line, width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 42, height: 42, child: Icon(icon, color: C.ink, size: 22)),
      ),
    );
  }
}

/// Small painted drink vessel (glass / mug / bottle ...) filled with the drink colour.
class DrinkIcon extends StatelessWidget {
  final Beverage beverage;
  final double size;
  final double fill;
  const DrinkIcon({super.key, required this.beverage, this.size = 36, this.fill = 0.75});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _VesselPainter(beverage.vessel, beverage.color, fill)),
    );
  }
}

class _VesselPainter extends CustomPainter {
  final Vessel vessel;
  final Color color;
  final double fill;
  _VesselPainter(this.vessel, this.color, this.fill);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final outline = Path();
    switch (vessel) {
      case Vessel.glass:
        outline
          ..moveTo(w * 0.2, h * 0.1)
          ..lineTo(w * 0.8, h * 0.1)
          ..lineTo(w * 0.7, h * 0.92)
          ..quadraticBezierTo(w * 0.5, h * 0.97, w * 0.3, h * 0.92)
          ..close();
        break;
      case Vessel.mug:
        outline.addRRect(RRect.fromLTRBR(w * 0.14, h * 0.2, w * 0.72, h * 0.9, Radius.circular(w * 0.1)));
        break;
      case Vessel.bottle:
        outline
          ..moveTo(w * 0.4, h * 0.04)
          ..lineTo(w * 0.6, h * 0.04)
          ..lineTo(w * 0.6, h * 0.2)
          ..quadraticBezierTo(w * 0.74, h * 0.26, w * 0.74, h * 0.4)
          ..lineTo(w * 0.74, h * 0.9)
          ..quadraticBezierTo(w * 0.74, h * 0.96, w * 0.66, h * 0.96)
          ..lineTo(w * 0.34, h * 0.96)
          ..quadraticBezierTo(w * 0.26, h * 0.96, w * 0.26, h * 0.9)
          ..lineTo(w * 0.26, h * 0.4)
          ..quadraticBezierTo(w * 0.26, h * 0.26, w * 0.4, h * 0.2)
          ..close();
        break;
      case Vessel.can:
        outline.addRRect(RRect.fromLTRBR(w * 0.26, h * 0.08, w * 0.74, h * 0.94, Radius.circular(w * 0.08)));
        break;
      case Vessel.wine:
        outline
          ..moveTo(w * 0.24, h * 0.06)
          ..lineTo(w * 0.76, h * 0.06)
          ..quadraticBezierTo(w * 0.8, h * 0.52, w * 0.53, h * 0.58)
          ..lineTo(w * 0.53, h * 0.86)
          ..lineTo(w * 0.7, h * 0.92)
          ..lineTo(w * 0.3, h * 0.92)
          ..lineTo(w * 0.47, h * 0.86)
          ..lineTo(w * 0.47, h * 0.58)
          ..quadraticBezierTo(w * 0.2, h * 0.52, w * 0.24, h * 0.06)
          ..close();
        break;
      case Vessel.cocktail:
        outline
          ..moveTo(w * 0.12, h * 0.1)
          ..lineTo(w * 0.88, h * 0.1)
          ..lineTo(w * 0.54, h * 0.52)
          ..lineTo(w * 0.54, h * 0.86)
          ..lineTo(w * 0.7, h * 0.92)
          ..lineTo(w * 0.3, h * 0.92)
          ..lineTo(w * 0.46, h * 0.86)
          ..lineTo(w * 0.46, h * 0.52)
          ..close();
        break;
      case Vessel.bowl:
        outline
          ..moveTo(w * 0.08, h * 0.38)
          ..lineTo(w * 0.92, h * 0.38)
          ..quadraticBezierTo(w * 0.9, h * 0.86, w * 0.5, h * 0.86)
          ..quadraticBezierTo(w * 0.1, h * 0.86, w * 0.08, h * 0.38)
          ..close();
        break;
    }

    // glass body
    canvas.drawPath(outline, Paint()..color = const Color(0xFFEFF2F6));
    // liquid
    final b = outline.getBounds();
    final top = b.bottom - b.height * fill.clamp(0.0, 1.0);
    canvas.save();
    canvas.clipPath(outline);
    canvas.drawRect(Rect.fromLTRB(b.left - 2, top, b.right + 2, b.bottom + 2), Paint()..color = color);
    // subtle highlight
    canvas.drawRect(
      Rect.fromLTRB(b.left + b.width * 0.12, b.top, b.left + b.width * 0.24, b.bottom),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.restore();
    // outline for light drinks
    canvas.drawPath(
      outline,
      Paint()
        ..color = const Color(0xFFD9DEE5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    if (vessel == Vessel.mug) {
      canvas.drawArc(
        Rect.fromLTRB(w * 0.6, h * 0.36, w * 0.92, h * 0.72),
        -1.4,
        2.8,
        false,
        Paint()
          ..color = const Color(0xFFD9DEE5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.07,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VesselPainter old) =>
      old.color != color || old.vessel != vessel || old.fill != fill;
}
