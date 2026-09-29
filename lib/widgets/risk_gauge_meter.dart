import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class RiskGaugeMeter extends StatelessWidget {
  final double score; // 0 to 100
  final String label;
  final double size;
  final bool showTiers;

  const RiskGaugeMeter({
    super.key,
    required this.score,
    this.label = 'Composite Risk Index',
    this.size = 140,
    this.showTiers = true,
  });

  @override
  Widget build(BuildContext context) {
    final String tierName;
    final Color riskColor;

    if (score >= 75) {
      tierName = 'Critical Risk';
      riskColor = AppColors.criticalRed;
    } else if (score >= 50) {
      tierName = 'High Warning';
      riskColor = AppColors.warningOrange;
    } else if (score >= 30) {
      tierName = 'Moderate Watch';
      riskColor = AppColors.advisoryYellow;
    } else {
      tierName = 'Normal / Safe';
      riskColor = AppColors.safeGreen;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CleanGaugePainter(
              score: score,
              riskColor: riskColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tierName,
                  style: GoogleFonts.inter(
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CleanGaugePainter extends CustomPainter {
  final double score;
  final Color riskColor;

  _CleanGaugePainter({required this.score, required this.riskColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    const startAngle = 140 * pi / 180;
    const sweepAngle = 260 * pi / 180;

    // Background track (light slate)
    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active progress arc
    final progressSweep = (score / 100.0) * sweepAngle;
    final progressPaint = Paint()
      ..color = riskColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CleanGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.riskColor != riskColor;
  }
}
