import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';

class SensorTelemetryCard extends StatelessWidget {
  final IoTSensorNode sensor;
  final VoidCallback? onTap;
  final bool isSelected;

  const SensorTelemetryCard({
    super.key,
    required this.sensor,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = sensor.isCritical;
    final Color indicatorColor = isCritical ? AppColors.criticalRed : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isCritical
                    ? AppColors.criticalRed.withAlpha(90)
                    : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Type & Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: indicatorColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_getSensorIcon(sensor.type), color: indicatorColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensor.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${sensor.wardName} • ${sensor.elevationMeters.toInt()}m MSL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sensor.isOnline ? AppColors.safeGreen : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${sensor.batteryPercent}%',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reading Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    sensor.typeLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sensor.primaryReadingString,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isCritical ? AppColors.criticalRed : AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            // Multi-depth soil layers if applicable
            if (sensor.type == SensorType.soilMoisture && sensor.soilLayers != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 8),
              Row(
                children: sensor.soilLayers!.map((layer) {
                  final isLayerHigh = layer.saturationPercentage >= 85;
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${layer.depthCm.toInt()}cm depth',
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${layer.volumetricWaterContent.toStringAsFixed(0)}% VWC',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isLayerHigh ? AppColors.criticalRed : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSensorIcon(SensorType type) {
    switch (type) {
      case SensorType.soilMoisture:
        return Icons.layers_outlined;
      case SensorType.slopeStability:
        return Icons.terrain_outlined;
      case SensorType.riverLevel:
        return Icons.water_outlined;
      case SensorType.rainGauge:
        return Icons.cloud_outlined;
      case SensorType.weatherRadar:
        return Icons.radar_outlined;
    }
  }
}
