enum AlertUrgency {
  immediate,
  expected,
  future,
}

enum AlertSeverity {
  extreme,
  severe,
  moderate,
  minor,
}

class DisasterAlert {
  final String id;
  final String headline;
  final String description;
  final String instruction;
  final String wardId;
  final String wardName;
  final AlertSeverity severity;
  final AlertUrgency urgency;
  final DateTime timestamp;
  final int leadTimeMinutes;
  final String issuedBy;
  final bool isBroadcasted;

  DisasterAlert({
    required this.id,
    required this.headline,
    required this.description,
    required this.instruction,
    required this.wardId,
    required this.wardName,
    required this.severity,
    required this.urgency,
    required this.timestamp,
    required this.leadTimeMinutes,
    this.issuedBy = 'NDRF & State Disaster Management Authority',
    this.isBroadcasted = true,
  });
}
