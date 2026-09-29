import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class WeatherRadarCard extends StatefulWidget {
  final double reflectivityDbz;
  final double rainfallMmHr;

  const WeatherRadarCard({
    super.key,
    this.reflectivityDbz = 45.0,
    this.rainfallMmHr = 32.0,
  });

  @override
  State<WeatherRadarCard> createState() => _WeatherRadarCardState();
}

class _WeatherRadarCardState extends State<WeatherRadarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Micro-Doppler Cloud Radar Sweep',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.safeGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'LIVE SWEEP',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.safeGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: _sweepController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _LightRadarSweepPainter(
                      sweepAngle: _sweepController.value * 2 * pi,
                      dbz: widget.reflectivityDbz,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRadarMetric('Echo Intensity', '${widget.reflectivityDbz.toStringAsFixed(0)} dBZ', AppColors.primary)),
              Expanded(child: _buildRadarMetric('Precip. Rate', '${widget.rainfallMmHr.toStringAsFixed(1)} mm/h', AppColors.rainBlue)),
              Expanded(child: _buildRadarMetric('Storm Vector', 'NE @ 18 km/h', AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarMetric(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _LightRadarSweepPainter extends CustomPainter {
  final double sweepAngle;
  final double dbz;

  _LightRadarSweepPainter({required this.sweepAngle, required this.dbz});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle (soft tint)
    final bgCircle = Paint()..color = AppColors.surfaceElevated;
    canvas.drawCircle(center, radius, bgCircle);

    // Grid Rings (Slate 200)
    final ringPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.33, ringPaint);
    canvas.drawCircle(center, radius * 0.66, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    // Crosshairs
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), ringPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), ringPaint);

    // Simulated storm precipitation blob
    final stormPaint = Paint()
      ..color = (dbz > 50 ? AppColors.criticalRed : AppColors.warningOrange).withAlpha(120)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.35, center.dy - radius * 0.3),
      radius * 0.28,
      stormPaint,
    );

    // Sweep Line
    final sweepPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0;

    final sweepEnd = Offset(
      center.dx + radius * cos(sweepAngle),
      center.dy + radius * sin(sweepAngle),
    );
    canvas.drawLine(center, sweepEnd, sweepPaint);

    // Sweep Sector Gradient
    final sectorPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: sweepAngle - 0.5,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          AppColors.primary.withAlpha(40),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweepAngle - 0.5,
      0.5,
      true,
      sectorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LightRadarSweepPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.dbz != dbz;
  }
}
