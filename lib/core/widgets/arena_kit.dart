import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../palette.dart';

class ArenaBackground extends StatefulWidget {
  const ArenaBackground({
    super.key,
    required this.quality,
    this.accent = ArenaPalette.cyan,
    this.child,
  });

  final GraphicsQuality quality;
  final Color accent;
  final Widget? child;

  @override
  State<ArenaBackground> createState() => _ArenaBackgroundState();
}

class _ArenaBackgroundState extends State<ArenaBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _particles {
    final calm = MediaQuery.disableAnimationsOf(context);
    if (calm) return 8;
    return switch (widget.quality) {
      GraphicsQuality.low => 12,
      GraphicsQuality.medium => 22,
      GraphicsQuality.high => 36,
      GraphicsQuality.ultra => 52,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _ArenaPainter(
            t: _ctrl.value,
            accent: widget.accent,
            particles: _particles,
            showGrid: widget.quality != GraphicsQuality.low && !MediaQuery.disableAnimationsOf(context),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ArenaPainter extends CustomPainter {
  _ArenaPainter({
    required this.t,
    required this.accent,
    required this.particles,
    required this.showGrid,
  });

  final double t;
  final Color accent;
  final int particles;
  final bool showGrid;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF070712), Color(0xFF140820), Color(0xFF050510)],
        ).createShader(rect),
    );

    final horizon = size.height * 0.42;
    if (showGrid) {
      final grid = Paint()
        ..color = accent.withValues(alpha: 0.18)
        ..strokeWidth = 1;
      for (var i = 0; i < 14; i++) {
        final y = horizon + pow(i / 13, 1.6) * (size.height - horizon);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      }
      final vanish = Offset(size.width / 2, horizon - 12);
      for (var i = -10; i <= 10; i++) {
        final x = size.width / 2 + i * size.width * 0.12;
        canvas.drawLine(Offset(x, size.height), vanish, grid);
      }
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.22), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, horizon), radius: size.width * 0.55));
    canvas.drawCircle(Offset(size.width * 0.5, horizon), size.width * 0.55, glow);

    final rng = Random(7);
    for (var i = 0; i < particles; i++) {
      final px = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final y = (baseY + sin((t * 2 * pi) + i) * 18) % size.height;
      final r = 1.2 + rng.nextDouble() * 2.4;
      canvas.drawCircle(
        Offset(px, y),
        r,
        Paint()..color = (i.isEven ? accent : ArenaPalette.magenta).withValues(alpha: 0.55),
      );
    }

    final platform = Path()
      ..moveTo(size.width * 0.18, size.height * 0.78)
      ..lineTo(size.width * 0.82, size.height * 0.78)
      ..lineTo(size.width * 0.72, size.height * 0.88)
      ..lineTo(size.width * 0.28, size.height * 0.88)
      ..close();
    canvas.drawPath(
      platform,
      Paint()
        ..color = accent.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      platform,
      Paint()
        ..color = accent.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _ArenaPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.accent != accent || oldDelegate.particles != particles;
}

class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = ArenaPalette.cyan,
    this.icon,
    this.expand = true,
    this.height = 58,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.85), width: 1.4),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.18), const Color(0xFF101428)],
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ArenaPalette.text,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                fontSize: 14,
                shadows: [Shadow(color: color, blurRadius: 12)],
              ),
            ),
          ),
        ],
      ),
    );
    final button = GestureDetector(
      onTap: onTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(-0.06),
        child: child,
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class HoloPanel extends StatelessWidget {
  const HoloPanel({super.key, required this.child, this.padding, this.accent = ArenaPalette.cyan});

  final Widget child;
  final EdgeInsets? padding;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ArenaPalette.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.16), blurRadius: 24)],
      ),
      child: child,
    );
  }
}

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.progress, this.height = 10});

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF1B2340)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0, 1),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [ArenaPalette.cyan, ArenaPalette.magenta]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlowText extends StatelessWidget {
  const GlowText(
    this.text, {
    super.key,
    this.size = 18,
    this.color = ArenaPalette.cyan,
    this.weight = FontWeight.w800,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: ArenaPalette.text,
        letterSpacing: 1.4,
        shadows: [Shadow(color: color, blurRadius: 18)],
      ),
    );
  }
}

class HitBurst extends StatelessWidget {
  const HitBurst({super.key, this.color = ArenaPalette.lime});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BurstPainter(color),
        size: const Size(120, 120),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * 3.14159 * 2;
      canvas.drawLine(c, c + Offset.fromDirection(a, 46), p);
    }
    canvas.drawCircle(c, 8, Paint()..color = color.withValues(alpha: 0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<bool> confirmLeaveArena(BuildContext context) async {
  final leave = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ArenaPalette.deepNavy,
      title: const Text('LEAVE THE ARENA?'),
      content: const Text('This run will not be saved.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('STAY')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('LEAVE')),
      ],
    ),
  );
  return leave == true;
}

