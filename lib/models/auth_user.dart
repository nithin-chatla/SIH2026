import 'package:latlong2/latlong.dart';

enum UserRole {
  disasterAuthority,
  citizen,
}

class AppUser {
  final String id;
  final String name;
  final String emailOrPhone;
  final UserRole role;
  final String? department;
  final String? badgeId;
  LatLng currentCoordinates;
  String currentWardId;
  String currentWardName;
  bool isLocationTrackingActive;
  bool isCriticalAlertsEnabled;
  bool isSmsRelayEnabled;
  bool isMeshNetworkEnabled;

  AppUser({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    required this.role,
    this.department,
    this.badgeId,
    required this.currentCoordinates,
    required this.currentWardId,
    required this.currentWardName,
    this.isLocationTrackingActive = true,
    this.isCriticalAlertsEnabled = true,
    this.isSmsRelayEnabled = true,
    this.isMeshNetworkEnabled = true,
  });

  bool get isAuthority => role == UserRole.disasterAuthority;

  String get roleTitle => isAuthority ? 'Disaster Authority (NDRF/SDMA)' : 'Citizen / Resident';
}
