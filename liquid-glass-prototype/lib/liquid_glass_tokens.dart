import 'dart:ui';
import 'package:flutter/material.dart';

/// Design tokens and reusable glass surface for the FLauncher Liquid Glass UI.
/// Integrate into the existing FLauncher widget tree; this file does not replace
/// the launcher app-discovery, database, or Android channel layers.
class LiquidGlassTokens {
  static const accent = Color(0xFF51CAFF);
  static const radius = 26.0;
  static const spring = SpringDescription(mass: 1, stiffness: 260, damping: 22);
  static const curve = Curves.easeOutCubic;
}

class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.blur = 22, this.opacity = .16, this.radius = LiquidGlassTokens.radius, this.borderColor = const Color(0x66FFFFFF)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur, opacity, radius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 28, offset: Offset(0, 12)), BoxShadow(color: Color(0x44FFFFFF), blurRadius: 1, offset: Offset(0, 1))],
        ),
        child: child,
      ),
    ),
  );
}

/// Centered clock header. Keep it in the main Stack, not in the corner/status row.
class LiquidGlassClock extends StatelessWidget {
  const LiquidGlassClock({super.key, required this.time, required this.date});
  final String time, date;
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(time, style: const TextStyle(fontSize: 64, height: 1, fontWeight: FontWeight.w300, letterSpacing: -2, color: Colors.white)),
    const SizedBox(height: 8), Text(date, style: const TextStyle(fontSize: 16, color: Color(0xCCDDEEFF))),
  ]);
}

/// Right-side settings drawer with slide + spring-like curve.
class LiquidGlassSettingsDrawer extends StatelessWidget {
  const LiquidGlassSettingsDrawer({super.key, required this.child, required this.open, required this.onClose});
  final Widget child;
  final bool open;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => Stack(children: [
    IgnorePointer(ignoring: !open, child: AnimatedOpacity(duration: const Duration(milliseconds: 280), opacity: open ? 1 : 0, child: GestureDetector(onTap: onClose, child: Container(color: Colors.black54)))),
    Align(alignment: Alignment.centerRight, child: AnimatedSlide(offset: open ? Offset.zero : const Offset(1.08, 0), curve: LiquidGlassTokens.curve, duration: const Duration(milliseconds: 520), child: SizedBox(width: 390, child: LiquidGlassSurface(padding: const EdgeInsets.all(24), child: child)))),
  ]);
}
