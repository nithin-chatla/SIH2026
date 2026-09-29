import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/disaster_alert.dart';
import '../theme/app_colors.dart';

class CitizenTargetedAlertDialog extends StatelessWidget {
  final DisasterAlert alert;
  final VoidCallback onDismiss;
  final VoidCallback onNavigateSafeRoute;

  const CitizenTargetedAlertDialog({
    super.key,
    required this.alert,
    required this.onDismiss,
    required this.onNavigateSafeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = alert.severity == AlertSeverity.extreme;
    final Color alertColor = isCritical ? AppColors.criticalRed : AppColors.warningOrange;
    final Color alertBg = isCritical ? AppColors.criticalRedBg : AppColors.warningOrangeBg;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: alertColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: alertColor.withAlpha(50),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Close
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: alertBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: alertColor.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, size: 16, color: alertColor),
                        const SizedBox(width: 6),
                        Text(
                          isCritical ? 'CRITICAL EVACUATION ORDER' : 'EMERGENCY GEO-ALERT',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: alertColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                alert.headline,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),

              // Location Tag
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Target Zone: ${alert.wardName} • Verified by NDRF Control Room',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Problem Cause Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTUAL FIELD HAZARD DETECTED:',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: alertColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.description,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Evacuation Corridor Action Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.safeGreenBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.safeGreenBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_run_rounded, color: AppColors.safeGreen, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SAFE HIGH-GROUND CORRIDOR:',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.safeGreen),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            alert.instruction,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDismiss,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Acknowledge'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onDismiss();
                        onNavigateSafeRoute();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alertColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.navigation_rounded, size: 16),
                      label: const Text('Start Evacuation Route'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
