import 'package:latlong2/latlong.dart';

enum CenterType {
  reliefCamp,
  medicalHospital,
  highGroundShelter,
  helipad,
  communityHall,
  schoolReliefCamp
}

class EvacuationCenter {
  final String id;
  final String name;
  final CenterType type;
  final LatLng location;
  final double elevationMeters;
  final int capacity;
  final int currentOccupancy;
  final String contactNumber;
  final bool hasMedicalSupport;
  final bool hasHelipad;
  final bool hasEmergencyPower;
  final double distanceKm;
  final List<String> availableSupplies;

  const EvacuationCenter({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.elevationMeters,
    required this.capacity,
    required this.currentOccupancy,
    required this.contactNumber,
    this.hasMedicalSupport = true,
    this.hasHelipad = false,
    this.hasEmergencyPower = true,
    required this.distanceKm,
    this.availableSupplies = const ['Clean Water', 'Food Rations', 'First Aid', 'Blankets'],
  });

  String get typeLabel {
    switch (type) {
      case CenterType.reliefCamp:
        return 'High Ground Relief Camp';
      case CenterType.medicalHospital:
        return 'Emergency Medical Post';
      case CenterType.highGroundShelter:
        return 'Reinforced Community Shelter';
      case CenterType.helipad:
        return 'Emergency Air Evac Helipad';
      case CenterType.communityHall:
        return 'Community Hall Center';
      case CenterType.schoolReliefCamp:
        return 'School Relief Camp';
    }
  }

  int get availableBeds => capacity - currentOccupancy;
  double get occupancyPercent => (currentOccupancy / capacity) * 100;
}
