import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class LeadTimeCounter extends StatelessWidget {
  final int leadTimeMinutes;
  final String wardName;
  final bool isCompact;

  const LeadTimeCounter({
    super.key,
    required this.leadTimeMinutes,
    required this.wardName,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = leadTimeMinutes < 30;
    final bool isWarning = leadTimeMinutes < 60;
    final Color badgeColor = isCritical
        ? AppColors.criticalRed
        : isWarning
            ? AppColors.warningOrange
            : AppColors.safeGreen;

    final Color bgColor = isCritical
        ? AppColors.criticalRedBg
        : isWarning
            ? AppColors.warningOrangeBg
            : AppColors.safeGreenBg;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: badgeColor.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 14, color: badgeColor),
            const SizedBox(width: 6),
            Text(
              'Evac Window: ${leadTimeMinutes > 120 ? '> 2 hours' : '$leadTimeMinutes mins'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: badgeColor),
                  const SizedBox(width: 4),
                  Text(
                    'EVACUATION LEAD TIME',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withAlpha(60)),
                ),
                child: Text(
                  isCritical ? 'CRITICAL' : isWarning ? 'PREPARE' : 'NORMAL',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$leadTimeMinutes',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'minutes remaining',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (leadTimeMinutes / 120.0).clamp(0.05, 1.0),
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCritical
                ? 'High-velocity surge cresting. Move to designated high-ground refuge.'
                : 'Safe evacuation corridors are clear and accessible.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
