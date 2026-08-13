import 'dart:math';

import 'package:flutter/material.dart';

import '../palette.dart';
import '../../models/models.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    required this.config,
    this.size = 180,
    this.celebrate = false,
  });

  final AvatarConfig config;
  final double size;
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(
        painter: _AvatarPainter(config: config, celebrate: celebrate),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({required this.config, required this.celebrate});

  final AvatarConfig config;
  final bool celebrate;

  static const presets = [
    Color(0xFFF1C27D),
    Color(0xFFE0AC69),
    Color(0xFFC68642),
    Color(0xFF8D5524),
    Color(0xFF5C3317),
    Color(0xFFFFE0BD),
  ];

  static const hairs = [
    Color(0xFF111111),
    Color(0xFF3B2A1F),
    Color(0xFFC43C3C),
    Color(0xFF00F0FF),
    Color(0xFFFF2BD6),
    Color(0xFFFFD166),
  ];

  static const outfits = [
    Color(0xFF00F0FF),
    Color(0xFFFF2BD6),
    Color(0xFF7A5CFF),
    Color(0xFF7CFF6B),
    Color(0xFFFFD166),
    Color(0xFFFF4D6D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final skin = presets[config.preset % presets.length];
    final hair = hairs[config.hairColor % hairs.length];
    final suit = outfits[config.outfit % outfits.length];
    final lift = celebrate ? -size.height * 0.04 : 0.0;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height * 0.92), width: size.width * 0.55, height: 14),
      Paint()..color = ArenaPalette.cyan.withValues(alpha: 0.18),
    );

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.68 + lift),
        width: size.width * 0.46,
        height: size.height * 0.38,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(body, Paint()..color = suit.withValues(alpha: 0.9));
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(Offset(cx, size.height * 0.34 + lift), size.width * 0.22, Paint()..color = skin);

    if (config.hair != 0) {
      final hairPath = Path()
        ..addOval(Rect.fromCircle(center: Offset(cx, size.height * 0.26 + lift), radius: size.width * 0.23));
      if (config.hair == 2) {
        hairPath.addRect(Rect.fromLTWH(cx - 8, size.height * 0.08 + lift, 16, 28));
      }
      canvas.drawPath(hairPath, Paint()..color = hair);
    }

    final eyeY = size.height * 0.34 + lift;
    canvas.drawCircle(Offset(cx - 12, eyeY), 3.2, Paint()..color = const Color(0xFF101018));
    canvas.drawCircle(Offset(cx + 12, eyeY), 3.2, Paint()..color = const Color(0xFF101018));
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, eyeY + 10), width: 18, height: 10),
      0.15,
      pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFF101018)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    if (config.glasses != 0) {
      final g = Paint()
        ..color = ArenaPalette.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 12, eyeY), width: 18, height: 12), const Radius.circular(3)),
        g,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 12, eyeY), width: 18, height: 12), const Radius.circular(3)),
        g,
      );
      canvas.drawLine(Offset(cx - 3, eyeY), Offset(cx + 3, eyeY), g);
    }

    if (config.hat != 0) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, size.height * 0.16 + lift), width: size.width * 0.42, height: 10),
        Paint()..color = ArenaPalette.gold,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, size.height * 0.11 + lift), width: size.width * 0.28, height: 16),
        Paint()..color = suit,
      );
    }

    if (config.accessory != 0) {
      canvas.drawCircle(Offset(cx, size.height * 0.54 + lift), 5, Paint()..color = ArenaPalette.gold);
    }

    final shoe = Paint()..color = outfits[config.shoes % outfits.length];
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 36, size.height * 0.86 + lift, 24, 10),
        const Radius.circular(4),
      ),
      shoe,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 12, size.height * 0.86 + lift, 24, 10),
        const Radius.circular(4),
      ),
      shoe,
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.config != config || oldDelegate.celebrate != celebrate;
}
