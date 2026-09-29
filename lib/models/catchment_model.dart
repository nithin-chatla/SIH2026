import 'package:latlong2/latlong.dart';
import 'ward_risk.dart';

enum RiskTrend {
  increasing, // ↗ Swelling / Rising
  stable,     // → Peaked / Steady
  decreasing, // ↘ Receding
}

enum InfrastructureType {
  bridge,
  hospital,
  school,
  roadPass,
  culvert,
}

class CriticalInfrastructure {
  final String id;
  final String name;
  final InfrastructureType type;
  final LatLng location;
  final String wardId;
  final String status; // 'SAFE', 'AT_RISK', 'SUBMERGED', 'DISRUPTED'
  final double elevationMeters;

  const CriticalInfrastructure({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.wardId,
    required this.status,
    required this.elevationMeters,
  });

  String get typeLabel {
    switch (type) {
      case InfrastructureType.bridge: return 'Bridge / Crossing';
      case InfrastructureType.hospital: return 'Emergency Hospital';
      case InfrastructureType.school: return 'School / Camp Refuge';
      case InfrastructureType.roadPass: return 'High-Pass Highway';
      case InfrastructureType.culvert: return 'Drainage Culvert';
    }
  }
}

class DrainageStream {
  final String id;
  final String name;
  final int order; // Strahler stream order (1 to 4)
  final List<LatLng> points; // Upstream to downstream
  final double currentFlowCumecs;
  final double peakCapacityCumecs;

  const DrainageStream({
    required this.id,
    required this.name,
    required this.order,
    required this.points,
    required this.currentFlowCumecs,
    required this.peakCapacityCumecs,
  });
}

class ForecastHorizonPrediction {
  final String horizon; // '6H', '3H', '1H', '30M'
  final String label;
  final double forecastRainfallMm;
  final double predictedWaterLevelMeters;
  final double riskScore;
  final AlertLevel alertLevel;
  final RiskTrend trend;
  final String expectedImpact;

  const ForecastHorizonPrediction({
    required this.horizon,
    required this.label,
    required this.forecastRainfallMm,
    required this.predictedWaterLevelMeters,
    required this.riskScore,
    required this.alertLevel,
    required this.trend,
    required this.expectedImpact,
  });
}

class PredictionEvidence {
  final double rainfallContributionPercent;   // e.g. 40%
  final double soilWetnessContributionPercent;  // e.g. 25%
  final double slopeContributionPercent;        // e.g. 18%
  final double lulcContributionPercent;         // e.g. 10%
  final double upstreamDischargePercent;       // e.g. 7%
  final String dominantTrigger;
  final String hydrologicalMechanism;

  const PredictionEvidence({
    required this.rainfallContributionPercent,
    required this.soilWetnessContributionPercent,
    required this.slopeContributionPercent,
    required this.lulcContributionPercent,
    required this.upstreamDischargePercent,
    required this.dominantTrigger,
    required this.hydrologicalMechanism,
  });
}

enum DataQualityStatus {
  good,
  warning,
  stale,
  unavailable,
}

enum ModelStatusTag {
  live,
  simulated,
  historicalReplay,
  methodologyPrototype,
  unavailable,
}

class StaticGeomorphicFingerprint {
  final double reliefMeters; // Difference between max and min elevation
  final double drainageDensityKmPerKm2; // Total stream length / Area
  final int maxStreamOrder; // 1 to 5 Strahler order
  final double topographicWetnessIndex; // ln(a / tan(beta))
  final String dominantLulc; // e.g., 'Dense Himalayan Pine & Scrub (62%)'
  final String dominantSoil; // e.g., 'Sandy Loam with High Infiltration (Hydrologic Group B)'
  final double hypsometricIntegral; // Basin shape (0.0 to 1.0)
  final double timeOfConcentrationHours; // Lag time from rain to peak flow
  final double channelSinuosity; // Stream length / valley length

  const StaticGeomorphicFingerprint({
    required this.reliefMeters,
    required this.drainageDensityKmPerKm2,
    required this.maxStreamOrder,
    required this.topographicWetnessIndex,
    required this.dominantLulc,
    required this.dominantSoil,
    required this.hypsometricIntegral,
    required this.timeOfConcentrationHours,
    required this.channelSinuosity,
  });
}

class PubTransferMetadata {
  final bool isUngauged;
  final String donorCatchmentId;
  final String donorCatchmentName;
  final double geomorphicSimilarityScore; // 0.0 to 1.0
  final String transferMechanism; // e.g., 'Spatial Proximity & Geomorphic Regionalization'
  final String localDischargeStatus; // 'Limited / Observation Unavailable'
  final String justification;

  const PubTransferMetadata({
    required this.isUngauged,
    required this.donorCatchmentId,
    required this.donorCatchmentName,
    required this.geomorphicSimilarityScore,
    required this.transferMechanism,
    required this.localDischargeStatus,
    required this.justification,
  });
}

class DataHarmonizationStep {
  final String sourceName; // e.g., 'IMD Gridded + NASA GPM IMERG'
  final String rawResolution; // e.g., '0.1° x 0.1° (~10km) / 30-min'
  final String spatialTransformation; // e.g., 'Hydrologic Area-Weighted Polygon Intersection'
  final String temporalTransformation; // e.g., '15-min Moving Accumulation Alignment'
  final String finalHydrologicalFeature; // e.g., 'Catchment-Averaged Forcing ($P_t$ mm/h)'
  final DataQualityStatus quality;
  final String latency;

  const DataHarmonizationStep({
    required this.sourceName,
    required this.rawResolution,
    required this.spatialTransformation,
    required this.temporalTransformation,
    required this.finalHydrologicalFeature,
    required this.quality,
    required this.latency,
  });
}

class SystemDataSource {
  final String category; // 'RAINFALL', 'WEATHER', 'TERRAIN', 'SOIL', 'HYDROLOGY', 'LULC'
  final String providerName; // 'IMD Doppler + NASA GPM', 'Copernicus 30m DEM', 'SMAP Satellite'
  final String coverage; // 'Himalayan Catchment Basin'
  final String resolution; // '30m DEM / 10km Gridded Weather'
  final String updateCadence; // '15-Minute Near-Realtime'
  final DataQualityStatus status;
  final String lastObservedTimestamp;
  final String scientificRole;

  const SystemDataSource({
    required this.category,
    required this.providerName,
    required this.coverage,
    required this.resolution,
    required this.updateCadence,
    required this.status,
    required this.lastObservedTimestamp,
    required this.scientificRole,
  });
}

class HistoricalEventReplayItem {
  final String id;
  final String name;
  final String dateString;
  final String location;
  final String description;
  final double peakRainfallMmPerHour;
  final double totalCasualtiesOrDisplacement;
  final List<ReplayTimeStep> timeSteps;

  const HistoricalEventReplayItem({
    required this.id,
    required this.name,
    required this.dateString,
    required this.location,
    required this.description,
    required this.peakRainfallMmPerHour,
    required this.totalCasualtiesOrDisplacement,
    required this.timeSteps,
  });
}

class ReplayTimeStep {
  final String timeLabel; // 'T-6H', 'T-3H', 'T-1H', 'T-30M', 'EVENT', 'AFTERMATH'
  final String timeOffset; // '-06:00:00'
  final AlertLevel riskLevel;
  final double rainfallMmPerHour;
  final double soilSaturationPercent;
  final double predictedWaterLevelMeters;
  final String situationNarrative;
  final String actionTaken;

  const ReplayTimeStep({
    required this.timeLabel,
    required this.timeOffset,
    required this.riskLevel,
    required this.rainfallMmPerHour,
    required this.soilSaturationPercent,
    required this.predictedWaterLevelMeters,
    required this.situationNarrative,
    required this.actionTaken,
  });
}

class CatchmentBasin {
  final String id;
  final String name;
  final String riverSystem;
  final double areaSqKm;
  final double meanElevationMeters;
  final double meanSlopeDegrees;
  final double runoffCoefficient; // LULC based (0.2 to 0.9)
  final bool isGauged; // True if physical sensor node exists, False if PUB (Prediction in Ungauged Basins)
  final String? donorCatchmentId; // For PUB transfer
  final List<LatLng> boundaryPolygon;
  final List<DrainageStream> drainageNetwork;
  final List<String> exposedVillageIds;
  final List<CriticalInfrastructure> criticalAssets;
  final AlertLevel currentRisk;
  final RiskTrend riskTrend;
  final List<ForecastHorizonPrediction> horizonPredictions;
  final PredictionEvidence evidence;
  final StaticGeomorphicFingerprint geomorphicFingerprint;
  final PubTransferMetadata? pubMetadata;

  const CatchmentBasin({
    required this.id,
    required this.name,
    required this.riverSystem,
    required this.areaSqKm,
    required this.meanElevationMeters,
    required this.meanSlopeDegrees,
    required this.runoffCoefficient,
    required this.isGauged,
    this.donorCatchmentId,
    required this.boundaryPolygon,
    required this.drainageNetwork,
    required this.exposedVillageIds,
    required this.criticalAssets,
    required this.currentRisk,
    required this.riskTrend,
    required this.horizonPredictions,
    required this.evidence,
    required this.geomorphicFingerprint,
    this.pubMetadata,
  });

  String get pubStatusLabel => isGauged ? 'Direct Gauge Monitored' : 'PUB (Transferred Hydrological Model)';
}
