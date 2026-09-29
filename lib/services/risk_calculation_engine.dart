import 'dart:math';
import '../models/ward_risk.dart';

class RiskCalculationEngine {
  /// Computes composite multi-source flash flood and slope failure risk
  /// [rainfallMmHr] : Live radar/rain gauge intensity in mm/hr
  /// [soilMoistureVwc] : Volumetric water content % (0 - 100)
  /// [slopeAngleDeg] : Inclinometer slope gradient in degrees
  /// [historicalLandslideWeight] : 0.0 to 1.0 based on geological fault inventory
  /// [riverLevelRatio] : Current level / Danger threshold (e.g. 0.85)
  static Map<String, dynamic> computeMultiSourceRisk({
    required double rainfallMmHr,
    required double soilMoistureVwc,
    required double slopeAngleDeg,
    required double historicalLandslideWeight,
    required double riverLevelRatio,
  }) {
    // 1. Rainfall Index (0 - 100): High risk > 35mm/hr, Extreme > 70mm/hr (Cloudburst criteria)
    final double rainScore = (rainfallMmHr / 75.0 * 100).clamp(0.0, 100.0);

    // 2. Soil Saturation Index (0 - 100): Clay-loam hill soils saturate at ~45-50% VWC
    final double soilScore = ((soilMoistureVwc - 20) / 30.0 * 100).clamp(0.0, 100.0);

    // 3. Slope Stability Factor of Safety (FoS) Estimation
    // As soil saturates and pore pressure rises, effective normal stress drops.
    final double slopeRad = slopeAngleDeg * pi / 180.0;
    final double internalFrictionAngleRad = 32.0 * pi / 180.0;
    final double saturationRatio = (soilMoistureVwc / 50.0).clamp(0.1, 1.0);
    
    // Simplified hydrological infinite-slope stability FoS:
    final double effectiveCohesion = 12.0 * (1.0 - 0.4 * saturationRatio); // kPa
    final double baseFos = (effectiveCohesion / 18.0 + tan(internalFrictionAngleRad) * (1.0 - 0.5 * saturationRatio)) /
        tan(slopeRad.clamp(0.1, 1.2));
    final double fos = baseFos.clamp(0.70, 2.50);

    // 4. River Inundation Score
    final double riverScore = (riverLevelRatio * 100).clamp(0.0, 100.0);

    // 5. Composite Multi-Source Risk Score (0 - 100)
    final double rawRiskScore = (rainScore * 0.35) +
        (soilScore * 0.25) +
        ((2.0 - fos).clamp(0.0, 1.5) / 1.5 * 25.0) +
        (riverScore * 0.15) +
        (historicalLandslideWeight * 10.0);

    final double compositeScore = rawRiskScore.clamp(0.0, 100.0);

    // 6. 5-Tier Alert Level Classification
    AlertLevel alertLevel;
    if (compositeScore >= 75.0 || fos < 1.05 || rainfallMmHr >= 65.0) {
      alertLevel = AlertLevel.critical; // Level 5: Red
    } else if (compositeScore >= 55.0 || fos < 1.25 || rainfallMmHr >= 38.0) {
      alertLevel = AlertLevel.warning; // Level 4: Orange
    } else if (compositeScore >= 40.0 || fos < 1.40 || rainfallMmHr >= 22.0) {
      alertLevel = AlertLevel.alert; // Level 3: Yellow
    } else if (compositeScore >= 25.0 || rainfallMmHr >= 12.0) {
      alertLevel = AlertLevel.advisory; // Level 2: Blue
    } else {
      alertLevel = AlertLevel.safe; // Level 1: Green
    }

    // 7. Dynamic Actionable Evacuation Lead Time (Minutes)
    int leadTimeMinutes;
    if (alertLevel == AlertLevel.critical) {
      leadTimeMinutes = max(10, (40 - (compositeScore - 75) * 1.2).round());
    } else if (alertLevel == AlertLevel.warning) {
      leadTimeMinutes = max(35, (75 - (compositeScore - 55) * 1.8).round());
    } else if (alertLevel == AlertLevel.alert) {
      leadTimeMinutes = 110;
    } else if (alertLevel == AlertLevel.advisory) {
      leadTimeMinutes = 240;
    } else {
      leadTimeMinutes = 480; // Safe monitoring
    }

    final double floodProb = ((rainScore * 0.55) + (riverScore * 0.45)).clamp(0.0, 99.0);
    final double landslideProb = ((soilScore * 0.45) + ((2.0 - fos) / 1.5 * 55.0)).clamp(0.0, 99.0);

    return {
      'riskScore': double.parse(compositeScore.toStringAsFixed(1)),
      'factorOfSafety': double.parse(fos.toStringAsFixed(2)),
      'alertLevel': alertLevel,
      'evacuationLeadTimeMinutes': leadTimeMinutes,
      'floodProbability': double.parse(floodProb.toStringAsFixed(1)),
      'landslideProbability': double.parse(landslideProb.toStringAsFixed(1)),
    };
  }
}
