import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/disaster_alert.dart';
import '../theme/app_colors.dart';

class AlertBanner extends StatelessWidget {
  final DisasterAlert alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onViewDetails;

  const AlertBanner({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExtreme = alert.severity == AlertSeverity.extreme;
    final Color alertColor = isExtreme ? AppColors.criticalRed : AppColors.warningOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: alertColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExtreme ? Icons.error_outline : Icons.warning_amber_rounded,
                        color: alertColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isExtreme ? 'FLASH FLOOD EMERGENCY' : 'PRE-EVACUATION WARNING',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: alertColor,
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Lead: ${alert.leadTimeMinutes}m',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: alertColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.headline,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            alert.description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.safeGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    alert.instruction,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.safeGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
