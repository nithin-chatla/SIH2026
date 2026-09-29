import 'package:latlong2/latlong.dart';

enum HazardCategory {
  waterLogging,
  landslideObstruction,
  bridgeOverflow,
  slopeCrack,
  debrisFlow,
}

class CitizenHazardReport {
  final String id;
  final String reporterName;
  final String phoneNumber;
  final HazardCategory category;
  final String description;
  final LatLng location;
  final String wardName;
  final DateTime reportedAt;
  final String severity; // Low, Medium, Critical
  final bool isVerified;
  final int upvotes;

  CitizenHazardReport({
    required this.id,
    required this.reporterName,
    required this.phoneNumber,
    required this.category,
    required this.description,
    required this.location,
    required this.wardName,
    required this.reportedAt,
    required this.severity,
    this.isVerified = false,
    this.upvotes = 1,
  });

  String get categoryTitle {
    switch (category) {
      case HazardCategory.waterLogging:
        return 'Severe Flash Waterlogging';
      case HazardCategory.landslideObstruction:
        return 'Active Landslide / Road Block';
      case HazardCategory.bridgeOverflow:
        return 'Bridge Submerged / Danger Stage';
      case HazardCategory.slopeCrack:
        return 'Fresh Ground / Slope Fissure';
      case HazardCategory.debrisFlow:
        return 'Debris Flow & Mud Torrent';
    }
  }
}
