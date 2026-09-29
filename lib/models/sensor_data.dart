import 'package:latlong2/latlong.dart';

enum SensorType {
  soilMoisture,
  slopeStability,
  riverLevel,
  rainGauge,
  weatherRadar
}

class SoilLayerMoisture {
  final double depthCm; // e.g. 10, 30, 50 cm
  final double volumetricWaterContent; // % (0 - 100)
  final double poreWaterPressureKPa; // kPa
  final double saturationPercentage; // %

  const SoilLayerMoisture({
    required this.depthCm,
    required this.volumetricWaterContent,
    required this.poreWaterPressureKPa,
    required this.saturationPercentage,
  });
}

class IoTSensorNode {
  final String id;
  final String name;
  final SensorType type;
  final LatLng location;
  final double elevationMeters;
  final String wardId;
  final String wardName;
  final DateTime lastUpdated;
  final int batteryPercent;
  final bool isOnline;

  // Type-specific values
  final List<SoilLayerMoisture>? soilLayers;
  final double? slopeTiltDegrees; // Inclinometer tilt
  final double? factorOfSafety; // FoS (>1.3 safe, <1.0 imminent failure)
  final double? factorOfSafetyEstimate;
  final double? tiltRateDegreesPerHour;
  final double? shearDisplacementMm; // Slope movement
  final double? riverWaterLevelMeters; // Ultrasonic river gauge
  final double? riverDangerThresholdMeters; // Danger mark
  final double? riverDischargeFlowCumecs; // m³/s
  final double? rainfallRateMmPerHour; // Rain gauge
  final double? cumulativeRain24hMm;
  final double? radarReflectivityDbz;

  IoTSensorNode({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.elevationMeters,
    required this.wardId,
    required this.wardName,
    required this.lastUpdated,
    this.batteryPercent = 95,
    this.isOnline = true,
    this.soilLayers,
    this.slopeTiltDegrees,
    this.factorOfSafety,
    this.factorOfSafetyEstimate,
    this.tiltRateDegreesPerHour,
    this.shearDisplacementMm,
    this.riverWaterLevelMeters,
    this.riverDangerThresholdMeters,
    this.riverDischargeFlowCumecs,
    this.rainfallRateMmPerHour,
    this.cumulativeRain24hMm,
    this.radarReflectivityDbz,
  });

  String get typeLabel {
    switch (type) {
      case SensorType.soilMoisture:
        return 'Multi-Depth Soil Array';
      case SensorType.slopeStability:
        return 'Slope Inclinometer & FoS';
      case SensorType.riverLevel:
        return 'Ultrasonic River Hydrograph';
      case SensorType.rainGauge:
        return 'Doppler Rain Gauge';
      case SensorType.weatherRadar:
        return 'Micro-X Radar Node';
    }
  }

  String get primaryReadingString {
    switch (type) {
      case SensorType.soilMoisture:
        final top = soilLayers?.first.volumetricWaterContent ?? 0;
        return '${top.toStringAsFixed(1)}% VWC';
      case SensorType.slopeStability:
        return 'FoS ${(factorOfSafety ?? 1.4).toStringAsFixed(2)} (${(slopeTiltDegrees ?? 12).toStringAsFixed(1)}°)';
      case SensorType.riverLevel:
        return '${(riverWaterLevelMeters ?? 2.1).toStringAsFixed(2)} m / ${(riverDangerThresholdMeters ?? 4.0).toStringAsFixed(1)} m';
      case SensorType.rainGauge:
        return '${(rainfallRateMmPerHour ?? 0).toStringAsFixed(1)} mm/hr';
      case SensorType.weatherRadar:
        return '${(radarReflectivityDbz ?? 35).toStringAsFixed(0)} dBZ';
    }
  }

  bool get isCritical {
    if (factorOfSafety != null && factorOfSafety! < 1.05) return true;
    if (riverWaterLevelMeters != null &&
        riverDangerThresholdMeters != null &&
        riverWaterLevelMeters! >= riverDangerThresholdMeters! * 0.9) {
      return true;
    }
    if (rainfallRateMmPerHour != null && rainfallRateMmPerHour! >= 40.0) {
      return true;
    }
    if (soilLayers != null &&
        soilLayers!.any((l) => l.saturationPercentage >= 90)) {
      return true;
    }
    return false;
  }
}
