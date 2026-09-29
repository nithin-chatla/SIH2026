import 'package:latlong2/latlong.dart';
import 'catchment_model.dart';

enum AlertLevel {
  safe, // Level 1: Normal (Green)
  advisory, // Level 2: Hydrological Watch (Blue)
  alert, // Level 3: Pre-Failure Alert (Yellow)
  warning, // Level 4: Flash Flood Warning (Orange)
  critical, // Level 5: Emergency Mandatory Evacuation (Red)
}

class WardRisk {
  final String id;
  final String name;
  final String district;
  final String state;
  final String catchmentId;
  final String catchmentName;
  final LatLng center;
  final double elevationMeters;
  final int population;
  final int highRiskHouseholds;
  final AlertLevel alertLevel;
  final RiskTrend trend;
  final double riskScore; // 0 to 100
  final double floodProbability; // 0 to 100 %
  final double landslideProbability; // 0 to 100 %
  final int evacuationLeadTimeMinutes; // Remaining time for safe evacuation
  final double rainfall1hMm;
  final double accumulated24hRainMm;
  final double temperatureCelsius;
  final double humidityPercent;
  final double soilSaturationPercent;
  final double factorOfSafety;
  final double slopeAngleDegrees;
  final String lulcType;
  final String sirenStatus; // 'SILENT', 'ARMED', 'ACTIVE_BROADCAST'
  final String actionAdvisory;
  final List<LatLng> boundaryPoints;
  final String? activeAlertHeadline;
  final String? activeAlertDetail;
  final String? designatedSafeRoute;
  final DateTime? lastBroadcastTime;
  final String? dispatchedByOfficer;
  final List<ForecastHorizonPrediction> horizonPredictions;
  final PredictionEvidence? evidence;
  final DateTime lastUpdated;

  WardRisk({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    this.catchmentId = 'CAT-01',
    this.catchmentName = 'Upper Alaknanda Basin',
    required this.center,
    required this.elevationMeters,
    required this.population,
    required this.highRiskHouseholds,
    required this.alertLevel,
    this.trend = RiskTrend.increasing,
    required this.riskScore,
    required this.floodProbability,
    required this.landslideProbability,
    required this.evacuationLeadTimeMinutes,
    required this.rainfall1hMm,
    this.accumulated24hRainMm = 54.0,
    this.temperatureCelsius = 18.5,
    this.humidityPercent = 88.0,
    required this.soilSaturationPercent,
    required this.factorOfSafety,
    this.slopeAngleDegrees = 32.0,
    this.lulcType = 'Mountain Slope / Dense Forest',
    this.sirenStatus = 'SILENT',
    required this.actionAdvisory,
    this.boundaryPoints = const [],
    this.activeAlertHeadline,
    this.activeAlertDetail,
    this.designatedSafeRoute,
    this.lastBroadcastTime,
    this.dispatchedByOfficer,
    this.horizonPredictions = const [],
    this.evidence,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  int get levelIndex {
    switch (alertLevel) {
      case AlertLevel.safe: return 1;
      case AlertLevel.advisory: return 2;
      case AlertLevel.alert: return 3;
      case AlertLevel.warning: return 4;
      case AlertLevel.critical: return 5;
    }
  }

  String get alertLevelName {
    switch (alertLevel) {
      case AlertLevel.critical:
        return 'LVL 5: CRITICAL RED (EVACUATE)';
      case AlertLevel.warning:
        return 'LVL 4: ORANGE WARNING (PREPARE)';
      case AlertLevel.alert:
        return 'LVL 3: YELLOW ALERT (WATCH)';
      case AlertLevel.advisory:
        return 'LVL 2: BLUE ADVISORY (STREAM RISE)';
      case AlertLevel.safe:
        return 'LVL 1: GREEN (NORMAL / SAFE)';
    }
  }

  String get trendLabel {
    switch (trend) {
      case RiskTrend.increasing: return 'Increasing ↗ (Surge Developing)';
      case RiskTrend.stable: return 'Stable → (Near Peak Crest)';
      case RiskTrend.decreasing: return 'Decreasing ↘ (Receding)';
    }
  }

  WardRisk copyWith({
    String? id,
    String? name,
    String? district,
    String? state,
    String? catchmentId,
    String? catchmentName,
    LatLng? center,
    double? elevationMeters,
    int? population,
    int? highRiskHouseholds,
    AlertLevel? alertLevel,
    RiskTrend? trend,
    double? riskScore,
    double? floodProbability,
    double? landslideProbability,
    int? evacuationLeadTimeMinutes,
    double? rainfall1hMm,
    double? accumulated24hRainMm,
    double? temperatureCelsius,
    double? humidityPercent,
    double? soilSaturationPercent,
    double? factorOfSafety,
    double? slopeAngleDegrees,
    String? lulcType,
    String? sirenStatus,
    String? actionAdvisory,
    List<LatLng>? boundaryPoints,
    String? activeAlertHeadline,
    String? activeAlertDetail,
    String? designatedSafeRoute,
    DateTime? lastBroadcastTime,
    String? dispatchedByOfficer,
    List<ForecastHorizonPrediction>? horizonPredictions,
    PredictionEvidence? evidence,
    DateTime? lastUpdated,
  }) {
    return WardRisk(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      state: state ?? this.state,
      catchmentId: catchmentId ?? this.catchmentId,
      catchmentName: catchmentName ?? this.catchmentName,
      center: center ?? this.center,
      elevationMeters: elevationMeters ?? this.elevationMeters,
      population: population ?? this.population,
      highRiskHouseholds: highRiskHouseholds ?? this.highRiskHouseholds,
      alertLevel: alertLevel ?? this.alertLevel,
      trend: trend ?? this.trend,
      riskScore: riskScore ?? this.riskScore,
      floodProbability: floodProbability ?? this.floodProbability,
      landslideProbability: landslideProbability ?? this.landslideProbability,
      evacuationLeadTimeMinutes:
          evacuationLeadTimeMinutes ?? this.evacuationLeadTimeMinutes,
      rainfall1hMm: rainfall1hMm ?? this.rainfall1hMm,
      accumulated24hRainMm: accumulated24hRainMm ?? this.accumulated24hRainMm,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      soilSaturationPercent:
          soilSaturationPercent ?? this.soilSaturationPercent,
      factorOfSafety: factorOfSafety ?? this.factorOfSafety,
      slopeAngleDegrees: slopeAngleDegrees ?? this.slopeAngleDegrees,
      lulcType: lulcType ?? this.lulcType,
      sirenStatus: sirenStatus ?? this.sirenStatus,
      actionAdvisory: actionAdvisory ?? this.actionAdvisory,
      boundaryPoints: boundaryPoints ?? this.boundaryPoints,
      activeAlertHeadline: activeAlertHeadline ?? this.activeAlertHeadline,
      activeAlertDetail: activeAlertDetail ?? this.activeAlertDetail,
      designatedSafeRoute: designatedSafeRoute ?? this.designatedSafeRoute,
      lastBroadcastTime: lastBroadcastTime ?? this.lastBroadcastTime,
      dispatchedByOfficer: dispatchedByOfficer ?? this.dispatchedByOfficer,
      horizonPredictions: horizonPredictions ?? this.horizonPredictions,
      evidence: evidence ?? this.evidence,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
