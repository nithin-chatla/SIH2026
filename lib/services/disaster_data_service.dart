import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/sensor_data.dart';
import '../models/ward_risk.dart';
import '../models/evacuation_center.dart';
import '../models/disaster_alert.dart';
import '../models/citizen_report.dart';
import '../models/auth_user.dart';
import '../models/catchment_model.dart';
import 'risk_calculation_engine.dart';

class DisasterDataService extends ChangeNotifier {
  Timer? _liveTelemetryTimer;
  final Random _random = Random();

  // User Auth & Role State
  AppUser? _currentUser;
  bool _isLoggedIn = false;
  DisasterAlert? _latestTargetedAlertForUser;
  Map<String, String>? _simulatedSmsPayload;
  Map<String, String>? _simulatedPushPayload;

  // Simulation Controls
  double _simulatedRainfallBoostMm = 0.0; // 0 to 120 mm/hr
  double _simulatedSoilMoistureBoost = 0.0; // 0 to 30 %
  bool _isSimulationActive = false;
  String _activeScenario = 'Live Environmental Baseline';

  // Historical Event Replay (Validation Engine)
  bool _isHistoricalReplayActive = false;
  double _replayTimelineProgress = 0.65; // 0.0 to 1.0 (T-6h to T0)
  String _selectedHistoricalEvent = '2021 Chamoli Glacial Cloudburst';

  // Selected Target Region Focus
  String _selectedRegion = 'Uttarakhand & Himalayas';

  // Data Collections
  List<CatchmentBasin> _catchments = [];
  List<WardRisk> _wards = [];
  List<IoTSensorNode> _sensors = [];
  List<EvacuationCenter> _evacuationCenters = [];
  List<CriticalInfrastructure> _infrastructure = [];
  final List<DisasterAlert> _activeAlerts = [];
  List<CitizenHazardReport> _citizenReports = [];

  WardRisk? _selectedWard;
  CatchmentBasin? _selectedCatchment;
  IoTSensorNode? _selectedSensor;

  DisasterDataService() {
    _currentUser = null;
    _isLoggedIn = false;
    _initializeData();
    _startLiveTelemetryStream();
  }

  void _initDefaultUser() {
    _currentUser = AppUser(
      id: 'USR-NDRF-801',
      name: 'Inspector Rajesh Varma',
      emailOrPhone: 'rajesh.varma@ndrf.gov.in',
      role: UserRole.disasterAuthority,
      department: 'NDRF 8th Battalion Command (Himalayan QRT)',
      badgeId: 'NDRF-UK-8842',
      currentCoordinates: const LatLng(30.5583, 79.5668),
      currentWardId: 'W-01',
      currentWardName: 'Joshimath Upper Ward',
      isLocationTrackingActive: true,
      isCriticalAlertsEnabled: true,
      isSmsRelayEnabled: true,
      isMeshNetworkEnabled: true,
    );
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn && _currentUser != null;
  bool get isAuthority => _currentUser?.isAuthority ?? false;
  DisasterAlert? get latestTargetedAlertForUser => _latestTargetedAlertForUser;
  Map<String, String>? get simulatedSmsPayload => _simulatedSmsPayload;
  Map<String, String>? get simulatedPushPayload => _simulatedPushPayload;

  double get simulatedRainfallBoostMm => _simulatedRainfallBoostMm;
  double get simulatedSoilMoistureBoost => _simulatedSoilMoistureBoost;
  bool get isSimulationActive => _isSimulationActive;
  String get activeScenario => _activeScenario;
  String get selectedRegion => _selectedRegion;

  bool get isHistoricalReplayActive => _isHistoricalReplayActive;
  double get replayTimelineProgress => _replayTimelineProgress;
  String get selectedHistoricalEvent => _selectedHistoricalEvent;

  List<CatchmentBasin> get catchments => _catchments;
  List<WardRisk> get wards => _wards;
  List<IoTSensorNode> get sensors => _sensors;
  List<EvacuationCenter> get evacuationCenters => _evacuationCenters;
  List<CriticalInfrastructure> get infrastructure => _infrastructure;
  List<DisasterAlert> get activeAlerts => _activeAlerts;
  List<CitizenHazardReport> get citizenReports => _citizenReports;

  WardRisk? get selectedWard => _selectedWard ?? (_wards.isNotEmpty ? _wards.first : null);
  CatchmentBasin? get selectedCatchment => _selectedCatchment ?? (_catchments.isNotEmpty ? _catchments.first : null);
  IoTSensorNode? get selectedSensor => _selectedSensor;

  int get criticalWardsCount =>
      _wards.where((w) => w.alertLevel == AlertLevel.critical).length;
  int get warningWardsCount =>
      _wards.where((w) => w.alertLevel == AlertLevel.warning).length;
  int get advisoryWardsCount =>
      _wards.where((w) => w.alertLevel == AlertLevel.advisory || w.alertLevel == AlertLevel.alert).length;

  int get totalAtRiskPopulation => _wards
      .where((w) => w.alertLevel == AlertLevel.critical || w.alertLevel == AlertLevel.warning || w.alertLevel == AlertLevel.alert)
      .fold(0, (sum, w) => sum + w.population);

  // End-to-End FLUVIA Demonstration Wizard State (8 Stages)
  // 0: SENSE -> 1: HARMONIZE -> 2: MODEL -> 3: PREDICT -> 4: LOCALIZE -> 5: VERIFY -> 6: ALERT -> 7: ACT
  int _demoStageIndex = 0;
  bool _isDemoWizardActive = false;
  int get demoStageIndex => _demoStageIndex;
  bool get isDemoWizardActive => _isDemoWizardActive;

  void startDemoWizard() {
    _isDemoWizardActive = true;
    _demoStageIndex = 0;
    _applyDemoStageEffect(0);
    notifyListeners();
  }

  void nextDemoStage() {
    if (_demoStageIndex < 7) {
      _demoStageIndex++;
      _applyDemoStageEffect(_demoStageIndex);
      notifyListeners();
    }
  }

  void previousDemoStage() {
    if (_demoStageIndex > 0) {
      _demoStageIndex--;
      _applyDemoStageEffect(_demoStageIndex);
      notifyListeners();
    }
  }

  void resetDemoWizard() {
    _isDemoWizardActive = false;
    _demoStageIndex = 0;
    updateSimulation(rainfallBoostMm: 0, soilBoostPercent: 0, scenarioName: 'Live Environmental Baseline');
  }

  void _applyDemoStageEffect(int stage) {
    switch (stage) {
      case 0: // SENSE: Normal baseline telemetry
        updateSimulation(rainfallBoostMm: 8.0, soilBoostPercent: 4.0, scenarioName: 'Stage 1: Multi-Source Data Ingestion');
        break;
      case 1: // HARMONIZE: Spatial-temporal grid alignment
        updateSimulation(rainfallBoostMm: 22.0, soilBoostPercent: 12.0, scenarioName: 'Stage 2: Spatial & Temporal Harmonization');
        break;
      case 2: // MODEL: Catchment geomorphic fingerprinting & PUB
        updateSimulation(rainfallBoostMm: 38.0, soilBoostPercent: 18.0, scenarioName: 'Stage 3: Catchment Topology & PUB Regionalization');
        break;
      case 3: // PREDICT: Multi-horizon hydrograph peak computation
        updateSimulation(rainfallBoostMm: 64.0, soilBoostPercent: 24.0, scenarioName: 'Stage 4: Multi-Horizon Peak Surge Prediction');
        break;
      case 4: // LOCALIZE: Downstream exposed villages & bridge risk
        updateSimulation(rainfallBoostMm: 78.0, soilBoostPercent: 28.0, scenarioName: 'Stage 5: Downstream Vulnerability Localization');
        break;
      case 5: // VERIFY: Officer evidence inspection & review
        updateSimulation(rainfallBoostMm: 85.0, soilBoostPercent: 30.0, scenarioName: 'Stage 6: Authority Evidence Review & Verification');
        break;
      case 6: // ALERT: Common Alerting Protocol geo-dispatch
        updateSimulation(rainfallBoostMm: 88.0, soilBoostPercent: 30.0, scenarioName: 'Stage 7: Targeted Multi-Channel Warning Dispatch');
        break;
      case 7: // ACT: Citizen evacuation along designated refuge corridor
        updateSimulation(rainfallBoostMm: 88.0, soilBoostPercent: 30.0, scenarioName: 'Stage 8: Citizen Protective Action & Evacuation');
        break;
    }
  }

  // Multi-Interval Rainfall Calculation (Scientific breakdown)
  Map<String, double> getRainfallBreakdownForWard(String? wardId) {
    final ward = wardId != null ? _wards.firstWhere((w) => w.id == wardId, orElse: () => _wards.first) : selectedWard ?? _wards.first;
    final r1h = ward.rainfall1hMm;
    return {
      '15m': double.parse((r1h * 0.28).toStringAsFixed(1)),
      '1h': double.parse(r1h.toStringAsFixed(1)),
      '3h': double.parse((r1h * 2.45).toStringAsFixed(1)),
      '6h': double.parse((r1h * 4.2).toStringAsFixed(1)),
      '24h': double.parse((ward.accumulated24hRainMm).toStringAsFixed(1)),
      'api7': double.parse((ward.accumulated24hRainMm * 0.72 + 35.0).toStringAsFixed(1)), // Antecedent Precipitation Index
    };
  }

  // Data Harmonization Pipeline Registry
  List<DataHarmonizationStep> get dataHarmonizationSteps => [
    const DataHarmonizationStep(
      sourceName: 'IMD Doppler Radar & NASA GPM IMERG',
      rawResolution: '0.1° x 0.1° (~10km) / 30-min Gridded Raster',
      spatialTransformation: 'Area-Weighted Catchment Boundary Intersection & Zonal Statistics',
      temporalTransformation: '15-Minute Moving Window Accumulation & Hyetograph Alignment',
      finalHydrologicalFeature: 'Hydrologically Aligned Catchment Forcing (Pt mm/h)',
      quality: DataQualityStatus.good,
      latency: '8 mins (Near-Realtime)',
    ),
    const DataHarmonizationStep(
      sourceName: 'Copernicus 30m WorldDEM / ISRO CartoDEM',
      rawResolution: '30m x 30m GeoTIFF Elevation Model',
      spatialTransformation: 'Hydro-Enforced Stream Burning, D8 Flow Direction & Sub-basin Delineation',
      temporalTransformation: 'Static Geomorphic Parameter Extraction (Topographic Index)',
      finalHydrologicalFeature: 'Basin Slope, Relief & Drainage Density Matrix',
      quality: DataQualityStatus.good,
      latency: 'Static Pre-computed',
    ),
    const DataHarmonizationStep(
      sourceName: 'NASA SMAP L4 Satellite Soil Moisture',
      rawResolution: '9km x 9km Global Surface/Root-zone Moisture',
      spatialTransformation: 'Hypsometric Topographic Redistribution based on TWI',
      temporalTransformation: '3-Hourly Infiltration Decay & Soil Saturation Scaling',
      finalHydrologicalFeature: 'Dynamic Soil Saturation Index & Pore Pressure Estimate',
      quality: DataQualityStatus.good,
      latency: '45 mins',
    ),
    const DataHarmonizationStep(
      sourceName: 'ISRO / NRSC Bhuvan High-Resolution LULC',
      rawResolution: '1:50,000 Scale Vector Polygon Classifications',
      spatialTransformation: 'Curve Number (CN) Weighting across Catchment Polygons',
      temporalTransformation: 'Seasonal Foliage & Infiltration Capacity Adjustment',
      finalHydrologicalFeature: 'Direct Runoff Coefficient (C = 0.58 - 0.78)',
      quality: DataQualityStatus.good,
      latency: 'Annual Baseline',
    ),
    const DataHarmonizationStep(
      sourceName: 'Autonomous Solar IoT Sensor Mesh (TDR & Ultrasonic)',
      rawResolution: 'Point Observations at Critical Mountain River Crossings',
      spatialTransformation: 'Cross-Section Rating Curve Transformation to Discharge Cumecs',
      temporalTransformation: '5-Minute High-Frequency Event Triggered Telemetry',
      finalHydrologicalFeature: 'Ground-Truth Stage-Discharge Hydrograph & In-situ Moisture',
      quality: DataQualityStatus.good,
      latency: '< 60 seconds',
    ),
  ];

  // System Data Sources Registry
  List<SystemDataSource> get dataSources => [
    const SystemDataSource(
      category: 'RAINFALL',
      providerName: 'IMD Doppler Weather Radar & NASA GPM IMERG',
      coverage: 'Upper Himalayan & Western Ghats Catchments',
      resolution: '0.1° (~10km) Gridded Radar Precipitation',
      updateCadence: '15-Minute Near-Realtime',
      status: DataQualityStatus.good,
      lastObservedTimestamp: '4 mins ago',
      scientificRole: 'Dynamic convective rainfall forcing & cloudburst detection',
    ),
    const SystemDataSource(
      category: 'WEATHER & FORECAST',
      providerName: 'IMD AWS Grid + ECMWF High-Res Forecast',
      coverage: 'Pan-India Mountain Catchments',
      resolution: '0.1° / Hourly Time-Step (6h Horizon)',
      updateCadence: 'Hourly Updates',
      status: DataQualityStatus.good,
      lastObservedTimestamp: '12 mins ago',
      scientificRole: 'Atmospheric moisture flux & short-term storm trajectory',
    ),
    const SystemDataSource(
      category: 'TERRAIN / DEM',
      providerName: 'Copernicus 30m Global DEM & SRTM',
      coverage: 'Topographic Catchment Basin Delineation',
      resolution: '30m Spatial Cell Size',
      updateCadence: 'Static Validated Baseline',
      status: DataQualityStatus.good,
      lastObservedTimestamp: 'Static High-Fidelity',
      scientificRole: 'Hydro-topographic slope, flow accumulation & Strahler drainage order',
    ),
    const SystemDataSource(
      category: 'SOIL WETNESS',
      providerName: 'NASA SMAP L4 Satellite & In-situ TDR Array',
      coverage: 'Surface (0-10cm) & Root-zone (0-100cm)',
      resolution: '9km Scaled via Topographic Wetness Index',
      updateCadence: '3-Hourly Satellite + 5-min IoT Ground Telemetry',
      status: DataQualityStatus.good,
      lastObservedTimestamp: '8 mins ago',
      scientificRole: 'Antecedent soil wetness index & infiltration threshold tracking',
    ),
    const SystemDataSource(
      category: 'HYDROLOGY',
      providerName: 'Central Water Commission (CWC) Gauging Network',
      coverage: 'Downstream Major River Gauges',
      resolution: 'Point Stage & Discharge Observations',
      updateCadence: 'Hourly Telemetry (Upper Mountain Tributaries Ungauged)',
      status: DataQualityStatus.warning,
      lastObservedTimestamp: '25 mins ago',
      scientificRole: 'Mainstream flood verification & PUB donor baseline calibration',
    ),
    const SystemDataSource(
      category: 'LAND USE / COVER',
      providerName: 'ISRO / NRSC Bhuvan National Geoportal',
      coverage: 'Himalayan Forest, Agricultural Terraces & Valley Settlements',
      resolution: '1:50,000 Thematic Map Layer',
      updateCadence: 'Annual Verified',
      status: DataQualityStatus.good,
      lastObservedTimestamp: '2025 Baseline',
      scientificRole: 'Surface roughness, Manning n & SCS Curve Number computation',
    ),
  ];

  // Historical Disaster Event Replay Registry
  List<HistoricalEventReplayItem> get historicalEvents => [
    const HistoricalEventReplayItem(
      id: 'EVT-CHAMOLI-2021',
      name: '2021 Chamoli Glacial Flash Flood & Debris Torrent',
      dateString: '7 February 2021',
      location: 'Rishi Ganga & Dhauliganga Catchments, Joshimath, Uttarakhand',
      description: 'Massive rock/ice avalanche from Ronti Peak triggered extreme flash surge in downstream gorge with rapid destruction of bridges and hydro tunnels.',
      peakRainfallMmPerHour: 62.0,
      totalCasualtiesOrDisplacement: 204,
      timeSteps: [
        ReplayTimeStep(
          timeLabel: 'T-6H',
          timeOffset: '-06:00:00',
          riskLevel: AlertLevel.safe,
          rainfallMmPerHour: 4.5,
          soilSaturationPercent: 42.0,
          predictedWaterLevelMeters: 1.8,
          situationNarrative: 'Baseline thermal sensor monitoring; sub-zero ambient temp in high glaciated headwaters.',
          actionTaken: 'Normal automated monitoring. Satellite thermal tracking active.',
        ),
        ReplayTimeStep(
          timeLabel: 'T-3H',
          timeOffset: '-03:00:00',
          riskLevel: AlertLevel.advisory,
          rainfallMmPerHour: 14.0,
          soilSaturationPercent: 58.0,
          predictedWaterLevelMeters: 2.3,
          situationNarrative: 'Headwall seismic tremors & localized thermal anomalies detected in upper hanging glacier.',
          actionTaken: 'FLUVIA triggers Advisory Level 2 to DEOC Chamoli command.',
        ),
        ReplayTimeStep(
          timeLabel: 'T-1H',
          timeOffset: '-01:00:00',
          riskLevel: AlertLevel.warning,
          rainfallMmPerHour: 38.0,
          soilSaturationPercent: 79.0,
          predictedWaterLevelMeters: 3.9,
          situationNarrative: 'Avalanche detachment in progress. Rapid pore pressure spike & tributary damming detected.',
          actionTaken: 'Pre-evacuation alerts dispatched to downstream Tapovan project sites.',
        ),
        ReplayTimeStep(
          timeLabel: 'T-30M',
          timeOffset: '-00:30:00',
          riskLevel: AlertLevel.critical,
          rainfallMmPerHour: 58.0,
          soilSaturationPercent: 94.0,
          predictedWaterLevelMeters: 5.4,
          situationNarrative: 'Hyper-concentrated debris torrent moving down gorge at 18 m/s. Extreme cresting imminent.',
          actionTaken: 'Mandatory sirens sound across Marwari, Joshimath gorge & Alaknanda bridges.',
        ),
        ReplayTimeStep(
          timeLabel: 'EVENT',
          timeOffset: '00:00:00',
          riskLevel: AlertLevel.critical,
          rainfallMmPerHour: 62.0,
          soilSaturationPercent: 100.0,
          predictedWaterLevelMeters: 6.8,
          situationNarrative: 'Peak surge wave breaches lower gorge bridges and Tapovan intake infrastructure.',
          actionTaken: 'Immediate rescue operations initiated; high-ground refuge assembly active.',
        ),
        ReplayTimeStep(
          timeLabel: 'AFTERMATH',
          timeOffset: '+04:00:00',
          riskLevel: AlertLevel.alert,
          rainfallMmPerHour: 12.0,
          soilSaturationPercent: 86.0,
          predictedWaterLevelMeters: 3.2,
          situationNarrative: 'Flood hydrograph receding; secondary damming watch active on side streams.',
          actionTaken: 'Relief camps active at Auli & Joshimath Higher Secondary School.',
        ),
      ],
    ),
    const HistoricalEventReplayItem(
      id: 'EVT-WAYANAD-2024',
      name: '2024 Wayanad Extreme Mountain Debris Surge',
      dateString: '30 July 2024',
      location: 'Chooralmala, Mundakkai & Meppadi, Wayanad, Kerala',
      description: 'Extremely heavy monsoon convective downpour (572mm in 48h) triggered catastrophic slope failure and torrential mud surge.',
      peakRainfallMmPerHour: 88.0,
      totalCasualtiesOrDisplacement: 350,
      timeSteps: [
        ReplayTimeStep(
          timeLabel: 'T-6H',
          timeOffset: '-06:00:00',
          riskLevel: AlertLevel.alert,
          rainfallMmPerHour: 34.0,
          soilSaturationPercent: 82.0,
          predictedWaterLevelMeters: 2.9,
          situationNarrative: 'Continuous antecedent rainfall over 48 hours; steep plantation soils reaching critical capacity.',
          actionTaken: 'Pre-alert monitoring of Mundakkai streams; emergency relief camps placed on standby.',
        ),
        ReplayTimeStep(
          timeLabel: 'T-3H',
          timeOffset: '-03:00:00',
          riskLevel: AlertLevel.warning,
          rainfallMmPerHour: 56.0,
          soilSaturationPercent: 91.0,
          predictedWaterLevelMeters: 4.1,
          situationNarrative: 'Intense meso-scale convective cloudburst cell over upper catchment ridge.',
          actionTaken: 'Level 4 Warning issued to Chooralmala; early evacuation of vulnerable slope homes.',
        ),
        ReplayTimeStep(
          timeLabel: 'T-1H',
          timeOffset: '-01:00:00',
          riskLevel: AlertLevel.critical,
          rainfallMmPerHour: 82.0,
          soilSaturationPercent: 98.0,
          predictedWaterLevelMeters: 5.6,
          situationNarrative: 'Multiple upper slope shallow slip failures consolidating into high-velocity debris avalanche.',
          actionTaken: 'Emergency sirens sound across valley; Meppadi High School opened for refuge.',
        ),
        ReplayTimeStep(
          timeLabel: 'EVENT',
          timeOffset: '00:00:00',
          riskLevel: AlertLevel.critical,
          rainfallMmPerHour: 88.0,
          soilSaturationPercent: 100.0,
          predictedWaterLevelMeters: 6.9,
          situationNarrative: 'Catastrophic debris flow destroys Chooralmala bridge and low-lying tea estate settlements.',
          actionTaken: 'NDRF and Indian Army deployment; aerial reconnaissance and ropeway rescue.',
        ),
        ReplayTimeStep(
          timeLabel: 'AFTERMATH',
          timeOffset: '+06:00:00',
          riskLevel: AlertLevel.warning,
          rainfallMmPerHour: 22.0,
          soilSaturationPercent: 92.0,
          predictedWaterLevelMeters: 3.8,
          situationNarrative: 'Rainfall intensity declines; high risk of secondary slope failures remains.',
          actionTaken: 'Comprehensive rehabilitation in progress at high-ground relief centers.',
        ),
      ],
    ),
  ];

  // Authentication & Role
  void loginAsOfficial({
    required String name,
    required String badgeId,
    required String department,
    LatLng? location,
    bool locationTracking = true,
    bool criticalAlerts = true,
    bool smsRelay = true,
    bool meshRelay = true,
  }) {
    _currentUser = AppUser(
      id: 'USR-OFF-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emailOrPhone: 'official@ndrf.gov.in',
      role: UserRole.disasterAuthority,
      department: department,
      badgeId: badgeId,
      currentCoordinates: location ?? const LatLng(30.5583, 79.5668),
      currentWardId: 'W-01',
      currentWardName: 'Joshimath Command Post',
      isLocationTrackingActive: locationTracking,
      isCriticalAlertsEnabled: criticalAlerts,
      isSmsRelayEnabled: smsRelay,
      isMeshNetworkEnabled: meshRelay,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginAsCitizen({
    required String name,
    required String phone,
    required String wardId,
    required String wardName,
    LatLng? location,
    bool locationTracking = true,
    bool criticalAlerts = true,
    bool smsRelay = true,
    bool meshRelay = true,
  }) {
    _currentUser = AppUser(
      id: 'USR-CIT-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emailOrPhone: phone,
      role: UserRole.citizen,
      currentCoordinates: location ?? const LatLng(30.5470, 79.5520),
      currentWardId: wardId,
      currentWardName: wardName,
      isLocationTrackingActive: locationTracking,
      isCriticalAlertsEnabled: criticalAlerts,
      isSmsRelayEnabled: smsRelay,
      isMeshNetworkEnabled: meshRelay,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void switchUserRole(UserRole role) {
    if (role == UserRole.disasterAuthority) {
      _initDefaultUser();
    } else {
      _currentUser = AppUser(
        id: 'USR-CIT-104',
        name: 'Aarav Rawat (Resident)',
        emailOrPhone: '+91 98451-22910',
        role: UserRole.citizen,
        currentCoordinates: const LatLng(30.5470, 79.5520),
        currentWardId: 'W-02',
        currentWardName: 'Alaknanda Riverfront (Ward 2)',
        isLocationTrackingActive: true,
        isCriticalAlertsEnabled: true,
        isSmsRelayEnabled: true,
        isMeshNetworkEnabled: true,
      );
    }
    _isLoggedIn = true;
    _checkLocationTargetedAlerts();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  void updateLiveLocation(LatLng newCoord, String wardId, String wardName) {
    if (_currentUser != null) {
      _currentUser!.currentCoordinates = newCoord;
      _currentUser!.currentWardId = wardId;
      _currentUser!.currentWardName = wardName;
      _checkLocationTargetedAlerts();
      notifyListeners();
    }
  }

  void dismissUserAlert() {
    _latestTargetedAlertForUser = null;
    notifyListeners();
  }

  void clearSimulatedSmsAndPush() {
    _simulatedSmsPayload = null;
    _simulatedPushPayload = null;
    notifyListeners();
  }

  void selectWard(WardRisk ward) {
    _selectedWard = ward;
    _selectedCatchment = _catchments.firstWhere(
      (c) => c.id == ward.catchmentId,
      orElse: () => _catchments.first,
    );
    notifyListeners();
  }

  void selectCatchment(CatchmentBasin catchment) {
    _selectedCatchment = catchment;
    final matchingWard = _wards.firstWhere(
      (w) => catchment.exposedVillageIds.contains(w.id),
      orElse: () => _wards.first,
    );
    _selectedWard = matchingWard;
    notifyListeners();
  }

  void selectSensor(IoTSensorNode? sensor) {
    _selectedSensor = sensor;
    notifyListeners();
  }

  void setRegion(String region) {
    _selectedRegion = region;
    _initializeData();
    notifyListeners();
  }

  // 5-Level Targeted Warning Dispatcher with multi-channel payload generation
  void dispatchFiveLevelAlert({
    required String targetWardId, // or 'ALL'
    required AlertLevel alertLevel,
    required String headline,
    required String specificProblemDetail,
    required String safeEvacuationRoute,
    required int leadTimeMinutes,
    double dangerRadiusKm = 5.0,
    bool channelPush = true,
    bool channelSms = true,
    bool channelSiren = true,
  }) {
    final alertId = 'FLUVIA-CAP-${DateTime.now().millisecondsSinceEpoch}';
    final isExtreme = alertLevel == AlertLevel.critical || alertLevel == AlertLevel.warning;

    if (targetWardId == 'ALL') {
      for (int i = 0; i < _wards.length; i++) {
        _wards[i] = _wards[i].copyWith(
          alertLevel: alertLevel,
          activeAlertHeadline: headline,
          activeAlertDetail: specificProblemDetail,
          designatedSafeRoute: safeEvacuationRoute,
          evacuationLeadTimeMinutes: leadTimeMinutes,
          lastBroadcastTime: DateTime.now(),
          dispatchedByOfficer: _currentUser?.name ?? 'NDRF Command',
          sirenStatus: (isExtreme && channelSiren) ? 'ACTIVE_BROADCAST' : 'ARMED',
        );
      }
    } else {
      final index = _wards.indexWhere((w) => w.id == targetWardId);
      if (index != -1) {
        _wards[index] = _wards[index].copyWith(
          alertLevel: alertLevel,
          activeAlertHeadline: headline,
          activeAlertDetail: specificProblemDetail,
          designatedSafeRoute: safeEvacuationRoute,
          evacuationLeadTimeMinutes: leadTimeMinutes,
          lastBroadcastTime: DateTime.now(),
          dispatchedByOfficer: _currentUser?.name ?? 'NDRF Command',
          sirenStatus: (isExtreme && channelSiren) ? 'ACTIVE_BROADCAST' : 'ARMED',
        );
      }
    }

    final targetName = targetWardId == 'ALL' ? 'ALL CATCHMENT BASINS' : _getWardName(targetWardId);

    // Insert to Active Alert Registry
    final alert = DisasterAlert(
      id: alertId,
      headline: headline,
      description: specificProblemDetail,
      instruction: safeEvacuationRoute,
      wardId: targetWardId,
      wardName: targetName,
      severity: alertLevel == AlertLevel.critical
          ? AlertSeverity.extreme
          : alertLevel == AlertLevel.warning
              ? AlertSeverity.severe
              : AlertSeverity.moderate,
      urgency: alertLevel == AlertLevel.critical ? AlertUrgency.immediate : AlertUrgency.expected,
      timestamp: DateTime.now(),
      leadTimeMinutes: leadTimeMinutes,
    );

    _activeAlerts.insert(0, alert);

    // Multi-Channel Outbound Simulation Payloads
    if (channelPush) {
      _simulatedPushPayload = {
        'title': '🚨 FLUVIA: ${alert.headline}',
        'body': '${alert.description} | Evacuation window: $leadTimeMinutes mins. Route: $safeEvacuationRoute',
        'timestamp': 'Just now',
        'level': alertLevel.name.toUpperCase(),
      };
    }

    if (channelSms) {
      _simulatedSmsPayload = {
        'sender': 'NDRF-FLUVIA',
        'message': '[GOVT EMERGENCY ALERT] Flash Flood warning issued for $targetName. $specificProblemDetail. Evacuate immediately via: $safeEvacuationRoute. Helpline: 1078 / 1070.',
        'timestamp': 'Just now',
      };
    }

    _checkLocationTargetedAlerts();
    notifyListeners();
  }

  void _checkLocationTargetedAlerts() {
    if (_currentUser == null || _activeAlerts.isEmpty) return;

    final userCoord = _currentUser!.currentCoordinates;
    final userWardId = _currentUser!.currentWardId;

    for (final alert in _activeAlerts) {
      if (alert.wardId == 'ALL' || alert.wardId == userWardId) {
        _latestTargetedAlertForUser = alert;
        return;
      }
      final targetWard = _wards.firstWhere((w) => w.id == alert.wardId, orElse: () => _wards.first);
      final double dist = const Distance().as(LengthUnit.Kilometer, userCoord, targetWard.center);
      if (dist <= 6.5) {
        _latestTargetedAlertForUser = alert;
        return;
      }
    }
  }

  String _getWardName(String id) {
    final w = _wards.where((w) => w.id == id);
    return w.isNotEmpty ? w.first.name : id;
  }

  // Simulation & Historical Replay
  void updateSimulation({
    required double rainfallBoostMm,
    required double soilBoostPercent,
    String? scenarioName,
  }) {
    _simulatedRainfallBoostMm = rainfallBoostMm;
    _simulatedSoilMoistureBoost = soilBoostPercent;
    _isSimulationActive = (rainfallBoostMm > 0 || soilBoostPercent > 0);
    _activeScenario = scenarioName ?? (_isSimulationActive ? 'Custom Scenario Simulation' : 'Live Environmental Baseline');
    _recalculateAllRisks();
    notifyListeners();
  }

  void applyScenarioPreset(String preset) {
    final lower = preset.toUpperCase();
    if (lower.contains('NORMAL')) {
      updateSimulation(rainfallBoostMm: 0, soilBoostPercent: 0, scenarioName: 'NORMAL (Live Baseline)');
    } else if (lower.contains('HEAVY RAIN') || lower.contains('MONSOON')) {
      updateSimulation(rainfallBoostMm: 38, soilBoostPercent: 12, scenarioName: 'HEAVY RAIN (Runoff Swell +38 mm/h)');
    } else if (lower.contains('HIGH ANTECEDENT WETNESS') || lower.contains('WETNESS')) {
      updateSimulation(rainfallBoostMm: 45, soilBoostPercent: 26, scenarioName: 'HIGH ANTECEDENT WETNESS (API-7 Saturated)');
    } else if (lower.contains('RAPID CATCHMENT RESPONSE') || lower.contains('RESPONSE')) {
      updateSimulation(rainfallBoostMm: 68, soilBoostPercent: 20, scenarioName: 'RAPID CATCHMENT RESPONSE (Steep Slope Surge)');
    } else if (lower.contains('HIGH RISK')) {
      updateSimulation(rainfallBoostMm: 82, soilBoostPercent: 25, scenarioName: 'HIGH RISK (Orange Warning - Roads Inundated)');
    } else if (lower.contains('CRITICAL RISK') || lower.contains('CLOUDBURST') || lower.contains('CATASTROPHIC')) {
      updateSimulation(rainfallBoostMm: 110, soilBoostPercent: 30, scenarioName: 'CRITICAL RISK (Red Alert - Mandatory Evacuation)');
    } else {
      updateSimulation(rainfallBoostMm: 25, soilBoostPercent: 10, scenarioName: preset);
    }
  }


  void setHistoricalReplay({
    required bool active,
    required double progress,
    String? eventName,
  }) {
    _isHistoricalReplayActive = active;
    _replayTimelineProgress = progress;
    if (eventName != null) _selectedHistoricalEvent = eventName;

    if (active) {
      // Scale rainfall based on timeline progression (T-6h -> T0 peak)
      final double replayRain = progress * 95.0;
      final double replaySoil = progress * 28.0;
      updateSimulation(
        rainfallBoostMm: replayRain,
        soilBoostPercent: replaySoil,
        scenarioName: 'Historical Replay: $_selectedHistoricalEvent (T-${((1.0 - progress) * 6).toStringAsFixed(1)}h)',
      );
    } else {
      applyScenarioPreset('Normal');
    }
  }

  void triggerWardSiren(String wardId) {
    final index = _wards.indexWhere((w) => w.id == wardId);
    if (index != -1) {
      final current = _wards[index];
      _wards[index] = current.copyWith(sirenStatus: 'ACTIVE_BROADCAST');

      _activeAlerts.insert(
        0,
        DisasterAlert(
          id: 'ALT-${DateTime.now().millisecondsSinceEpoch}',
          headline: 'EMERGENCY EVACUATION ORDER: ${current.name.toUpperCase()}',
          description: 'Acoustic siren sounded. High velocity debris flow & flash flood crest detected. Immediate evacuation to designated high ground required.',
          instruction: 'Proceed immediately via ${current.designatedSafeRoute ?? 'Route Green-1 to ${getNearestCenter(current.center).name}'}. Avoid riverbeds and lower culverts.',
          wardId: current.id,
          wardName: current.name,
          severity: AlertSeverity.extreme,
          urgency: AlertUrgency.immediate,
          timestamp: DateTime.now(),
          leadTimeMinutes: current.evacuationLeadTimeMinutes,
        ),
      );
      _checkLocationTargetedAlerts();
      notifyListeners();
    }
  }

  void submitCitizenReport(CitizenHazardReport report) {
    _citizenReports.insert(0, report);
    notifyListeners();
  }

  EvacuationCenter getNearestCenter(LatLng point) {
    if (_evacuationCenters.isEmpty) {
      return EvacuationCenter(
        id: 'ec-default',
        name: 'District High Refuge Haven',
        type: CenterType.highGroundShelter,
        location: point,
        elevationMeters: 2150,
        capacity: 500,
        currentOccupancy: 80,
        contactNumber: '+91 1800-180-1104',
        distanceKm: 1.2,
      );
    }
    return _evacuationCenters.first;
  }

  // Periodic Telemetry Stream Simulator
  void _startLiveTelemetryStream() {
    _liveTelemetryTimer?.cancel();
    _liveTelemetryTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _applyMicroTelemetryJitter();
    });
  }

  void _applyMicroTelemetryJitter() {
    for (int i = 0; i < _sensors.length; i++) {
      final s = _sensors[i];
      final double jitter = (_random.nextDouble() - 0.48) * 0.4;

      if (s.type == SensorType.soilMoisture && s.soilLayers != null) {
        final updatedLayers = s.soilLayers!.map((layer) {
          final newVwc = (layer.volumetricWaterContent + jitter + (_simulatedSoilMoistureBoost * 0.05)).clamp(15.0, 95.0);
          final newSat = (newVwc / 48.0 * 100).clamp(20.0, 100.0);
          return SoilLayerMoisture(
            depthCm: layer.depthCm,
            volumetricWaterContent: double.parse(newVwc.toStringAsFixed(1)),
            poreWaterPressureKPa: double.parse((newSat * 0.35).toStringAsFixed(1)),
            saturationPercentage: double.parse(newSat.toStringAsFixed(1)),
          );
        }).toList();

        _sensors[i] = IoTSensorNode(
          id: s.id,
          name: s.name,
          type: s.type,
          location: s.location,
          elevationMeters: s.elevationMeters,
          wardId: s.wardId,
          wardName: s.wardName,
          lastUpdated: DateTime.now(),
          soilLayers: updatedLayers,
        );
      } else if (s.type == SensorType.riverLevel) {
        final base = s.riverWaterLevelMeters ?? 2.0;
        final newLevel = (base + jitter * 0.15 + (_simulatedRainfallBoostMm * 0.02)).clamp(0.5, (s.riverDangerThresholdMeters ?? 4.0) * 1.3);
        _sensors[i] = IoTSensorNode(
          id: s.id,
          name: s.name,
          type: s.type,
          location: s.location,
          elevationMeters: s.elevationMeters,
          wardId: s.wardId,
          wardName: s.wardName,
          lastUpdated: DateTime.now(),
          riverWaterLevelMeters: double.parse(newLevel.toStringAsFixed(2)),
          riverDangerThresholdMeters: s.riverDangerThresholdMeters,
          riverDischargeFlowCumecs: double.parse((newLevel * 48.0).toStringAsFixed(1)),
        );
      } else if (s.type == SensorType.rainGauge) {
        final double baseRate = 12.0 + _simulatedRainfallBoostMm;
        final double currentRate = (baseRate + jitter * 2.0).clamp(0.0, 150.0);
        _sensors[i] = IoTSensorNode(
          id: s.id,
          name: s.name,
          type: s.type,
          location: s.location,
          elevationMeters: s.elevationMeters,
          wardId: s.wardId,
          wardName: s.wardName,
          lastUpdated: DateTime.now(),
          rainfallRateMmPerHour: double.parse(currentRate.toStringAsFixed(1)),
          cumulativeRain24hMm: double.parse((54.0 + currentRate * 0.4).toStringAsFixed(1)),
        );
      }
    }

    _recalculateAllRisks();
    notifyListeners();
  }

  void _recalculateAllRisks() {
    for (int i = 0; i < _wards.length; i++) {
      final ward = _wards[i];
      final wardSensors = _sensors.where((s) => s.wardId == ward.id).toList();

      double rainRate = 14.0 + _simulatedRainfallBoostMm;
      double soilMoisture = 32.0 + _simulatedSoilMoistureBoost;
      double slopeAngle = ward.slopeAngleDegrees;
      double riverRatio = 0.55;

      for (final sensor in wardSensors) {
        if (sensor.type == SensorType.rainGauge && sensor.rainfallRateMmPerHour != null) {
          rainRate = sensor.rainfallRateMmPerHour!;
        } else if (sensor.type == SensorType.soilMoisture && sensor.soilLayers != null) {
          soilMoisture = sensor.soilLayers!.first.volumetricWaterContent;
        } else if (sensor.type == SensorType.slopeStability && sensor.slopeTiltDegrees != null) {
          slopeAngle = sensor.slopeTiltDegrees!;
        } else if (sensor.type == SensorType.riverLevel &&
            sensor.riverWaterLevelMeters != null &&
            sensor.riverDangerThresholdMeters != null) {
          riverRatio = sensor.riverWaterLevelMeters! / sensor.riverDangerThresholdMeters!;
        }
      }

      final result = RiskCalculationEngine.computeMultiSourceRisk(
        rainfallMmHr: rainRate,
        soilMoistureVwc: soilMoisture,
        slopeAngleDeg: slopeAngle,
        historicalLandslideWeight: (ward.id == 'W-01' || ward.id == 'W-02') ? 0.85 : 0.45,
        riverLevelRatio: riverRatio,
      );

      final double score = result['riskScore'];
      final AlertLevel level = result['alertLevel'];

      // Generate 4 Forecast Horizons (6H, 3H, 1H, 30M)
      final horizons = [
        ForecastHorizonPrediction(
          horizon: '6H',
          label: '6 Hours Out',
          forecastRainfallMm: double.parse((rainRate * 0.6).toStringAsFixed(1)),
          predictedWaterLevelMeters: 2.2,
          riskScore: (score * 0.65).clamp(10, 95),
          alertLevel: score > 70 ? AlertLevel.alert : AlertLevel.advisory,
          trend: RiskTrend.increasing,
          expectedImpact: 'Upstream catchment cloud accumulation; moderate stream runoff.',
        ),
        ForecastHorizonPrediction(
          horizon: '3H',
          label: '3 Hours Out',
          forecastRainfallMm: double.parse((rainRate * 0.85).toStringAsFixed(1)),
          predictedWaterLevelMeters: 3.4,
          riskScore: (score * 0.85).clamp(15, 98),
          alertLevel: score > 60 ? AlertLevel.warning : AlertLevel.alert,
          trend: RiskTrend.increasing,
          expectedImpact: 'Soil column saturation reaches 85%; slope shear strength declines.',
        ),
        ForecastHorizonPrediction(
          horizon: '1H',
          label: '1 Hour Out',
          forecastRainfallMm: double.parse(rainRate.toStringAsFixed(1)),
          predictedWaterLevelMeters: (3.8 + _simulatedRainfallBoostMm * 0.02).clamp(2.0, 5.8),
          riskScore: score,
          alertLevel: level,
          trend: RiskTrend.increasing,
          expectedImpact: 'Rapid torrential cresting at downstream bridges and culverts.',
        ),
        ForecastHorizonPrediction(
          horizon: '30M',
          label: '30 Mins Out',
          forecastRainfallMm: double.parse((rainRate * 1.15).toStringAsFixed(1)),
          predictedWaterLevelMeters: (4.4 + _simulatedRainfallBoostMm * 0.025).clamp(2.0, 6.2),
          riskScore: (score * 1.1).clamp(20, 100),
          alertLevel: level == AlertLevel.warning || level == AlertLevel.critical ? AlertLevel.critical : level,
          trend: RiskTrend.increasing,
          expectedImpact: 'High-velocity debris flow & flash inundation across low-lying roads.',
        ),
      ];

      // Prediction Evidence / SHAP breakdown
      final evidence = PredictionEvidence(
        rainfallContributionPercent: double.parse(((rainRate / 90.0) * 42.0).clamp(20.0, 55.0).toStringAsFixed(1)),
        soilWetnessContributionPercent: double.parse(((soilMoisture / 50.0) * 28.0).clamp(15.0, 35.0).toStringAsFixed(1)),
        slopeContributionPercent: 18.0,
        lulcContributionPercent: 8.5,
        upstreamDischargePercent: double.parse((riverRatio * 15.0).clamp(5.0, 25.0).toStringAsFixed(1)),
        dominantTrigger: rainRate > 35 ? 'Extreme Upstream Doppler Precipitation' : 'Progressive Multi-Depth Soil Saturation',
        hydrologicalMechanism: 'Pore-water pressure escalation leading to rapid debris mobilization & stream swelling.',
      );

      final RiskTrend determinedTrend = score > 60
          ? RiskTrend.increasing
          : score > 35
              ? RiskTrend.stable
              : RiskTrend.decreasing;

      _wards[i] = ward.copyWith(
        riskScore: score,
        factorOfSafety: result['factorOfSafety'],
        alertLevel: level,
        trend: determinedTrend,
        evacuationLeadTimeMinutes: result['evacuationLeadTimeMinutes'],
        floodProbability: result['floodProbability'],
        landslideProbability: result['landslideProbability'],
        rainfall1hMm: rainRate,
        soilSaturationPercent: ((soilMoisture / 48.0) * 100).clamp(0.0, 100.0),
        actionAdvisory: _generateActionAdvisory(level, result['evacuationLeadTimeMinutes']),
        horizonPredictions: horizons,
        evidence: evidence,
        lastUpdated: DateTime.now(),
      );
    }
  }

  String _generateActionAdvisory(AlertLevel level, int leadMins) {
    switch (level) {
      case AlertLevel.critical:
        return 'LEVEL 5: MANDATORY EVACUATION. Lead time ~$leadMins mins. Move along designated Green Corridor Route to Auli High Refuge.';
      case AlertLevel.warning:
        return 'LEVEL 4 WARNING: PREPARE FOR EVACUATION. Catchment nearing saturation. Secure vulnerable citizens and livestock.';
      case AlertLevel.alert:
        return 'LEVEL 3 ALERT: High soil wetness and runoff detected. Monitor local drainage culverts and road crossings.';
      case AlertLevel.advisory:
        return 'LEVEL 2 ADVISORY: Continuous monitoring of upstream catchments and runoff levels.';
      case AlertLevel.safe:
        return 'LEVEL 1: NORMAL CONDITIONS. Low risk index. Multi-source IoT sensor mesh operational.';
    }
  }

  void _initializeData() {
    if (_selectedRegion.contains('Uttarakhand')) {
      _initHimalayanData();
    } else {
      _initWesternGhatsData();
    }
    _recalculateAllRisks();
  }

  void _initHimalayanData() {
    // 1. Critical Infrastructure
    _infrastructure = [
      const CriticalInfrastructure(
        id: 'INF-01',
        name: 'Alaknanda Suspension Gorge Bridge (Km 14)',
        type: InfrastructureType.bridge,
        location: LatLng(30.5480, 79.5510),
        wardId: 'W-02',
        status: 'AT_RISK',
        elevationMeters: 1485,
      ),
      const CriticalInfrastructure(
        id: 'INF-02',
        name: 'Joshimath Sub-District Emergency Hospital',
        type: InfrastructureType.hospital,
        location: LatLng(30.5590, 79.5690),
        wardId: 'W-01',
        status: 'SAFE',
        elevationMeters: 2160,
      ),
      const CriticalInfrastructure(
        id: 'INF-03',
        name: 'Helang Primary School & Relief Shelter',
        type: InfrastructureType.school,
        location: LatLng(30.5330, 79.5260),
        wardId: 'W-03',
        status: 'SAFE',
        elevationMeters: 1670,
      ),
      const CriticalInfrastructure(
        id: 'INF-04',
        name: 'Badrinath National Highway (NH-7 Bypass)',
        type: InfrastructureType.roadPass,
        location: LatLng(30.5420, 79.5440),
        wardId: 'W-02',
        status: 'AT_RISK',
        elevationMeters: 1490,
      ),
    ];

    // 2. Catchment Basins (Gauged vs PUB Ungauged)
    _catchments = [
      CatchmentBasin(
        id: 'CAT-01',
        name: 'Upper Alaknanda Main Catchment',
        riverSystem: 'Alaknanda / Ganga Basin',
        areaSqKm: 142.5,
        meanElevationMeters: 2450,
        meanSlopeDegrees: 34.0,
        runoffCoefficient: 0.72,
        isGauged: true,
        boundaryPolygon: const [
          LatLng(30.5750, 79.5350),
          LatLng(30.5820, 79.5850),
          LatLng(30.5350, 79.5950),
          LatLng(30.5250, 79.5150),
        ],
        drainageNetwork: const [
          DrainageStream(
            id: 'STR-01',
            name: 'Alaknanda Main Torrent',
            order: 4,
            points: [
              LatLng(30.5800, 79.5800),
              LatLng(30.5650, 79.5650),
              LatLng(30.5480, 79.5510),
              LatLng(30.5300, 79.5200),
            ],
            currentFlowCumecs: 184.0,
            peakCapacityCumecs: 240.0,
          ),
          DrainageStream(
            id: 'STR-02',
            name: 'Dhauliganga Headwater Tributary',
            order: 3,
            points: [
              LatLng(30.5750, 79.5400),
              LatLng(30.5600, 79.5550),
              LatLng(30.5480, 79.5510),
            ],
            currentFlowCumecs: 92.0,
            peakCapacityCumecs: 130.0,
          ),
        ],
        exposedVillageIds: const ['W-01', 'W-02'],
        criticalAssets: _infrastructure.where((i) => i.wardId == 'W-01' || i.wardId == 'W-02').toList(),
        currentRisk: AlertLevel.critical,
        riskTrend: RiskTrend.increasing,
        horizonPredictions: const [],
        evidence: const PredictionEvidence(
          rainfallContributionPercent: 44.0,
          soilWetnessContributionPercent: 26.0,
          slopeContributionPercent: 18.0,
          lulcContributionPercent: 7.0,
          upstreamDischargePercent: 5.0,
          dominantTrigger: 'Micro-Doppler Cloudburst Cell + Steep Slopes',
          hydrologicalMechanism: 'Rapid surface runoff concentration with high hydrograph peaking.',
        ),
        geomorphicFingerprint: const StaticGeomorphicFingerprint(
          reliefMeters: 2180.0,
          drainageDensityKmPerKm2: 2.85,
          maxStreamOrder: 4,
          topographicWetnessIndex: 7.42,
          dominantLulc: 'Alpine Scrub & Steep Valley Rock (58%)',
          dominantSoil: 'Gravelly Sandy Loam over Quartzite Gneiss (Group B)',
          hypsometricIntegral: 0.54,
          timeOfConcentrationHours: 1.85,
          channelSinuosity: 1.28,
        ),
      ),
      CatchmentBasin(
        id: 'CAT-02',
        name: 'Helang Ungauged Mountain Sub-Basin (PUB)',
        riverSystem: 'Helang Tributary Network',
        areaSqKm: 68.2,
        meanElevationMeters: 1890,
        meanSlopeDegrees: 29.5,
        runoffCoefficient: 0.58,
        isGauged: false, // Ungauged Basin using FLUVIA PUB transfer
        donorCatchmentId: 'CAT-01',
        boundaryPolygon: const [
          LatLng(30.5450, 79.5050),
          LatLng(30.5480, 79.5380),
          LatLng(30.5180, 79.5420),
          LatLng(30.5120, 79.5080),
        ],
        drainageNetwork: const [
          DrainageStream(
            id: 'STR-03',
            name: 'Helang Nallah Stream',
            order: 2,
            points: [
              LatLng(30.5420, 79.5120),
              LatLng(30.5350, 79.5240),
              LatLng(30.5250, 79.5350),
            ],
            currentFlowCumecs: 42.0,
            peakCapacityCumecs: 90.0,
          ),
        ],
        exposedVillageIds: const ['W-03'],
        criticalAssets: _infrastructure.where((i) => i.wardId == 'W-03').toList(),
        currentRisk: AlertLevel.advisory,
        riskTrend: RiskTrend.stable,
        horizonPredictions: const [],
        evidence: const PredictionEvidence(
          rainfallContributionPercent: 32.0,
          soilWetnessContributionPercent: 30.0,
          slopeContributionPercent: 22.0,
          lulcContributionPercent: 10.0,
          upstreamDischargePercent: 6.0,
          dominantTrigger: 'PUB Parameter Transfer from Upper Alaknanda',
          hydrologicalMechanism: 'Transferred non-linear unit hydrograph calibrated against donor terrain.',
        ),
        geomorphicFingerprint: const StaticGeomorphicFingerprint(
          reliefMeters: 1340.0,
          drainageDensityKmPerKm2: 2.15,
          maxStreamOrder: 2,
          topographicWetnessIndex: 8.12,
          dominantLulc: 'Sub-Alpine Mixed Forest & Terrace Agriculture (64%)',
          dominantSoil: 'Coarse Loamy Colluvium (Group B/C)',
          hypsometricIntegral: 0.48,
          timeOfConcentrationHours: 2.40,
          channelSinuosity: 1.19,
        ),
        pubMetadata: const PubTransferMetadata(
          isUngauged: true,
          donorCatchmentId: 'CAT-01',
          donorCatchmentName: 'Upper Alaknanda Main Catchment',
          geomorphicSimilarityScore: 0.86,
          transferMechanism: 'Spatial Proximity + Geomorphic Regionalization (Unit Hydrograph Transfer)',
          localDischargeStatus: 'Local discharge observation unavailable (Ungauged Basin)',
          justification: 'Hydro-geomorphic similarity: 86% match in hypsometric profile, slope distribution, and soil hydrologic group.',
        ),
      ),
    ];

    // 3. Wards (Red, Orange, Yellow, Green Hotspots)
    _wards = [
      // RED: Critical Hazard (Mandatory Evacuation)
      WardRisk(
        id: 'W-02',
        name: 'Alaknanda Riverfront (Ward 2)',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.5470, 79.5520),
        elevationMeters: 1480,
        population: 2800,
        highRiskHouseholds: 240,
        alertLevel: AlertLevel.critical,
        trend: RiskTrend.increasing,
        riskScore: 88.5,
        floodProbability: 94.0,
        landslideProbability: 68.0,
        evacuationLeadTimeMinutes: 18,
        rainfall1hMm: 48.0,
        accumulated24hRainMm: 88.0,
        soilSaturationPercent: 91.0,
        factorOfSafety: 1.01,
        slopeAngleDegrees: 38.5,
        lulcType: 'Steep River Valley / Colluvium Deposits',
        actionAdvisory: 'CRITICAL: River crest surging +1.6m. Immediate high-ground evacuation ordered.',
        designatedSafeRoute: 'Follow Green Route 1 to Auli High Haven Base',
        boundaryPoints: const [
          LatLng(30.5510, 79.5470),
          LatLng(30.5520, 79.5580),
          LatLng(30.5430, 79.5560),
          LatLng(30.5420, 79.5460),
        ],
      ),
      WardRisk(
        id: 'W-05',
        name: 'Marwari Lower Gorge Settlement',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.5530, 79.5490),
        elevationMeters: 1420,
        population: 1850,
        highRiskHouseholds: 190,
        alertLevel: AlertLevel.critical,
        trend: RiskTrend.increasing,
        riskScore: 92.0,
        floodProbability: 96.0,
        landslideProbability: 75.0,
        evacuationLeadTimeMinutes: 14,
        rainfall1hMm: 52.0,
        accumulated24hRainMm: 95.0,
        soilSaturationPercent: 94.0,
        factorOfSafety: 0.98,
        slopeAngleDegrees: 41.0,
        lulcType: 'Active Debris Chute / River Confluence',
        actionAdvisory: 'FLASH FLOOD IMMINENT: Siren sounding. Move all residents to Cantonment Camp.',
        designatedSafeRoute: 'Climb via Sunil Ridge track to Army Cantonment Camp',
        boundaryPoints: const [
          LatLng(30.5560, 79.5450),
          LatLng(30.5570, 79.5530),
          LatLng(30.5490, 79.5540),
          LatLng(30.5480, 79.5460),
        ],
      ),
      WardRisk(
        id: 'W-10',
        name: 'Vishnuprayag River Junction',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.5650, 79.5440),
        elevationMeters: 1380,
        population: 1200,
        highRiskHouseholds: 110,
        alertLevel: AlertLevel.critical,
        trend: RiskTrend.increasing,
        riskScore: 86.0,
        floodProbability: 91.0,
        landslideProbability: 70.0,
        evacuationLeadTimeMinutes: 20,
        rainfall1hMm: 44.0,
        accumulated24hRainMm: 82.0,
        soilSaturationPercent: 89.0,
        factorOfSafety: 1.03,
        slopeAngleDegrees: 36.0,
        lulcType: 'Narrow River Gorge Confluence',
        actionAdvisory: 'Dam surge wave transit. Clear riverbanks within 20 minutes.',
        designatedSafeRoute: 'Route B to Upper Highway Bypass',
        boundaryPoints: const [
          LatLng(30.5690, 79.5400),
          LatLng(30.5700, 79.5480),
          LatLng(30.5610, 79.5490),
          LatLng(30.5600, 79.5410),
        ],
      ),

      // ORANGE: Warning (Impending Hazard / Preparation)
      WardRisk(
        id: 'W-01',
        name: 'Joshimath - Upper Ward (Sector 4)',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.5583, 79.5668),
        elevationMeters: 2150,
        population: 4200,
        highRiskHouseholds: 310,
        alertLevel: AlertLevel.warning,
        trend: RiskTrend.increasing,
        riskScore: 68.0,
        floodProbability: 58.0,
        landslideProbability: 74.0,
        evacuationLeadTimeMinutes: 38,
        rainfall1hMm: 28.5,
        accumulated24hRainMm: 62.0,
        soilSaturationPercent: 78.0,
        factorOfSafety: 1.18,
        slopeAngleDegrees: 34.0,
        lulcType: 'Upper Mountain Ridge / Mixed Forest',
        actionAdvisory: 'Prepare emergency kit. Monitor slope crack sensors near Sunil village.',
        designatedSafeRoute: 'Follow Green Route 1 to Auli High Ground Shelter',
        boundaryPoints: const [
          LatLng(30.5620, 79.5620),
          LatLng(30.5630, 79.5710),
          LatLng(30.5540, 79.5720),
          LatLng(30.5530, 79.5630),
        ],
      ),
      WardRisk(
        id: 'W-06',
        name: 'Govindghat Hemkund Confluence',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.6240, 79.5960),
        elevationMeters: 1820,
        population: 1600,
        highRiskHouseholds: 150,
        alertLevel: AlertLevel.warning,
        trend: RiskTrend.increasing,
        riskScore: 74.0,
        floodProbability: 78.0,
        landslideProbability: 66.0,
        evacuationLeadTimeMinutes: 32,
        rainfall1hMm: 36.0,
        accumulated24hRainMm: 72.0,
        soilSaturationPercent: 82.0,
        factorOfSafety: 1.14,
        slopeAngleDegrees: 32.0,
        lulcType: 'Pilgrim Base / River Basin',
        actionAdvisory: 'Heavy tributary swell from Bhyundar valley. Prepare lower shops for closure.',
        designatedSafeRoute: 'Govindghat Gurudwara High Terrace Shelter',
        boundaryPoints: const [
          LatLng(30.6280, 79.5910),
          LatLng(30.6290, 79.6010),
          LatLng(30.6200, 79.6020),
          LatLng(30.6190, 79.5920),
        ],
      ),

      // YELLOW: Alert / Watch (Soil Saturated / Monitoring)
      WardRisk(
        id: 'W-03',
        name: 'Helang Valley Crossing',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-02',
        catchmentName: 'Helang Ungauged Sub-Basin (PUB)',
        center: const LatLng(30.5310, 79.5240),
        elevationMeters: 1650,
        population: 1950,
        highRiskHouseholds: 145,
        alertLevel: AlertLevel.alert,
        trend: RiskTrend.stable,
        riskScore: 48.0,
        floodProbability: 46.0,
        landslideProbability: 52.0,
        evacuationLeadTimeMinutes: 75,
        rainfall1hMm: 22.0,
        accumulated24hRainMm: 48.0,
        soilSaturationPercent: 62.0,
        factorOfSafety: 1.38,
        slopeAngleDegrees: 27.0,
        lulcType: 'Terraced Agricultural Slope',
        actionAdvisory: 'Rainfall moderate. PUB model tracks downstream tributary surge.',
        designatedSafeRoute: 'Helang Primary School High Ground Refuge',
        boundaryPoints: const [
          LatLng(30.5360, 79.5180),
          LatLng(30.5370, 79.5300),
          LatLng(30.5260, 79.5310),
          LatLng(30.5250, 79.5190),
        ],
      ),
      WardRisk(
        id: 'W-07',
        name: 'Pandukeshwar Ridge Sector',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.6050, 79.5820),
        elevationMeters: 1950,
        population: 1400,
        highRiskHouseholds: 95,
        alertLevel: AlertLevel.advisory,
        trend: RiskTrend.stable,
        riskScore: 42.0,
        floodProbability: 38.0,
        landslideProbability: 44.0,
        evacuationLeadTimeMinutes: 110,
        rainfall1hMm: 19.0,
        accumulated24hRainMm: 41.0,
        soilSaturationPercent: 56.0,
        factorOfSafety: 1.48,
        slopeAngleDegrees: 26.0,
        lulcType: 'Ancient Valley Terrace / Mixed Farming',
        actionAdvisory: 'Normal watch active. Stream culverts flowing smoothly.',
        designatedSafeRoute: 'Pandukeshwar Community Hall',
        boundaryPoints: const [
          LatLng(30.6090, 79.5770),
          LatLng(30.6100, 79.5870),
          LatLng(30.6010, 79.5880),
          LatLng(30.6000, 79.5780),
        ],
      ),
      WardRisk(
        id: 'W-09',
        name: 'Narsingh Mandir Ward',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.5520, 79.5620),
        elevationMeters: 1890,
        population: 2300,
        highRiskHouseholds: 120,
        alertLevel: AlertLevel.advisory,
        trend: RiskTrend.stable,
        riskScore: 36.0,
        floodProbability: 32.0,
        landslideProbability: 40.0,
        evacuationLeadTimeMinutes: 130,
        rainfall1hMm: 16.0,
        accumulated24hRainMm: 38.0,
        soilSaturationPercent: 52.0,
        factorOfSafety: 1.54,
        slopeAngleDegrees: 24.0,
        lulcType: 'Historic Town Center / Stone Masonry',
        actionAdvisory: 'Drainage clear. Inclinometers reporting zero sub-surface shear creep.',
        designatedSafeRoute: 'Narsingh High School Ground',
        boundaryPoints: const [
          LatLng(30.5550, 79.5580),
          LatLng(30.5560, 79.5660),
          LatLng(30.5490, 79.5670),
          LatLng(30.5480, 79.5590),
        ],
      ),

      // GREEN: Safe Haven (Designated High Ground Refuge)
      WardRisk(
        id: 'W-04',
        name: 'Auli High Haven (Safe Base)',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.5310, 79.5710),
        elevationMeters: 2750,
        population: 920,
        highRiskHouseholds: 15,
        alertLevel: AlertLevel.safe,
        trend: RiskTrend.decreasing,
        riskScore: 14.0,
        floodProbability: 5.0,
        landslideProbability: 12.0,
        evacuationLeadTimeMinutes: 360,
        rainfall1hMm: 8.0,
        accumulated24hRainMm: 24.0,
        soilSaturationPercent: 28.0,
        factorOfSafety: 2.20,
        slopeAngleDegrees: 16.0,
        lulcType: 'High Altitude Alpine Meadow',
        actionAdvisory: 'Designated Safe Haven. Relief camps, helipad and medical triage operational.',
        designatedSafeRoute: 'Primary Haven Base (Stationary Safety)',
        boundaryPoints: const [
          LatLng(30.5350, 79.5650),
          LatLng(30.5360, 79.5780),
          LatLng(30.5260, 79.5790),
          LatLng(30.5250, 79.5660),
        ],
      ),
      WardRisk(
        id: 'W-08',
        name: 'Parsari High Ridge Refuge',
        district: 'Chamoli',
        state: 'Uttarakhand',
        catchmentId: 'CAT-01',
        catchmentName: 'Upper Alaknanda Main Catchment',
        center: const LatLng(30.5420, 79.5760),
        elevationMeters: 2680,
        population: 650,
        highRiskHouseholds: 8,
        alertLevel: AlertLevel.safe,
        trend: RiskTrend.decreasing,
        riskScore: 11.0,
        floodProbability: 4.0,
        landslideProbability: 10.0,
        evacuationLeadTimeMinutes: 400,
        rainfall1hMm: 6.0,
        accumulated24hRainMm: 20.0,
        soilSaturationPercent: 24.0,
        factorOfSafety: 2.35,
        slopeAngleDegrees: 14.0,
        lulcType: 'Pine Forest & High Crest Ridge',
        actionAdvisory: 'Secondary Safe Refuge. Stocked with food rations and solar emergency backup.',
        designatedSafeRoute: 'Parsari Eco-Camp Ground',
        boundaryPoints: const [
          LatLng(30.5460, 79.5710),
          LatLng(30.5470, 79.5820),
          LatLng(30.5380, 79.5830),
          LatLng(30.5370, 79.5720),
        ],
      ),
    ];

    // 4. Sensors
    _sensors = [
      IoTSensorNode(
        id: 'S-101',
        name: 'Soil Moisture Array (Sunil Slope)',
        type: SensorType.soilMoisture,
        location: const LatLng(30.5560, 79.5650),
        elevationMeters: 2120,
        wardId: 'W-01',
        wardName: 'Joshimath Upper Ward',
        lastUpdated: DateTime.now(),
        soilLayers: [
          const SoilLayerMoisture(depthCm: 10, volumetricWaterContent: 42.5, poreWaterPressureKPa: 28.5, saturationPercentage: 88.5),
          const SoilLayerMoisture(depthCm: 30, volumetricWaterContent: 38.2, poreWaterPressureKPa: 24.1, saturationPercentage: 79.6),
          const SoilLayerMoisture(depthCm: 50, volumetricWaterContent: 34.0, poreWaterPressureKPa: 19.8, saturationPercentage: 70.8),
        ],
      ),
      IoTSensorNode(
        id: 'S-201',
        name: 'Biaxial Inclinometer Node (Gorge Wall)',
        type: SensorType.slopeStability,
        location: const LatLng(30.5490, 79.5540),
        elevationMeters: 1520,
        wardId: 'W-02',
        wardName: 'Alaknanda River Gorge',
        lastUpdated: DateTime.now(),
        slopeTiltDegrees: 38.2,
        tiltRateDegreesPerHour: 0.18,
        factorOfSafetyEstimate: 1.04,
      ),
      IoTSensorNode(
        id: 'S-301',
        name: 'Ultrasonic River Gauge (Alaknanda Bridge)',
        type: SensorType.riverLevel,
        location: const LatLng(30.5470, 79.5520),
        elevationMeters: 1475,
        wardId: 'W-02',
        wardName: 'Alaknanda River Gorge',
        lastUpdated: DateTime.now(),
        riverWaterLevelMeters: 4.35,
        riverDangerThresholdMeters: 4.50,
        riverDischargeFlowCumecs: 218.4,
      ),
      IoTSensorNode(
        id: 'S-401',
        name: 'Optical Rain Gauge (Helang Ridge)',
        type: SensorType.rainGauge,
        location: const LatLng(30.5320, 79.5250),
        elevationMeters: 1680,
        wardId: 'W-03',
        wardName: 'Helang Valley',
        lastUpdated: DateTime.now(),
        rainfallRateMmPerHour: 22.4,
        cumulativeRain24hMm: 58.2,
      ),
    ];

    // 5. Evacuation Centers
    _evacuationCenters = [
      const EvacuationCenter(
        id: 'EC-01',
        name: 'Auli High Haven Emergency Camp',
        type: CenterType.highGroundShelter,
        location: LatLng(30.5310, 79.5710),
        elevationMeters: 2750,
        capacity: 1200,
        currentOccupancy: 180,
        contactNumber: '+91 135-2710334',
        distanceKm: 3.8,
        hasHelipad: true,
        hasMedicalSupport: true,
      ),
      const EvacuationCenter(
        id: 'EC-02',
        name: 'Joshimath Army Cantonment Field Triage',
        type: CenterType.communityHall,
        location: LatLng(30.5590, 79.5690),
        elevationMeters: 2180,
        capacity: 800,
        currentOccupancy: 240,
        contactNumber: '+91 135-222144',
        distanceKm: 1.4,
        hasHelipad: false,
        hasMedicalSupport: true,
      ),
      const EvacuationCenter(
        id: 'EC-03',
        name: 'Helang Primary School Relief Point',
        type: CenterType.schoolReliefCamp,
        location: LatLng(30.5330, 79.5260),
        elevationMeters: 1670,
        capacity: 450,
        currentOccupancy: 60,
        contactNumber: '+91 1800-180-1104',
        distanceKm: 2.1,
        hasHelipad: false,
        hasMedicalSupport: false,
      ),
    ];

    // 6. Citizen Reports
    _citizenReports = [
      CitizenHazardReport(
        id: 'CR-01',
        reporterName: 'Sunil Negi',
        phoneNumber: '+91 94120-11234',
        category: HazardCategory.slopeCrack,
        description: '3-inch fresh ground fissure observed near upper Sunil orchard after morning rain.',
        location: const LatLng(30.5570, 79.5640),
        wardName: 'Joshimath Upper Ward',
        reportedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        severity: 'Critical',
        isVerified: true,
        upvotes: 18,
      ),
      CitizenHazardReport(
        id: 'CR-02',
        reporterName: 'Manoj Bisht',
        phoneNumber: '+91 98370-55421',
        category: HazardCategory.bridgeOverflow,
        description: 'Alaknanda riverbed water rising violently near lower footbridge. Turbulent muddy surge.',
        location: const LatLng(30.5475, 79.5515),
        wardName: 'Alaknanda River Gorge',
        reportedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        severity: 'Critical',
        isVerified: true,
        upvotes: 34,
      ),
    ];
  }

  void _initWesternGhatsData() {
    _infrastructure = [
      const CriticalInfrastructure(
        id: 'INF-WG-01',
        name: 'Chooralmala River Bailey Bridge',
        type: InfrastructureType.bridge,
        location: LatLng(11.5310, 76.1520),
        wardId: 'W-WG-01',
        status: 'AT_RISK',
        elevationMeters: 840,
      ),
      const CriticalInfrastructure(
        id: 'INF-WG-02',
        name: 'Meppadi Primary Health Centre',
        type: InfrastructureType.hospital,
        location: LatLng(11.5540, 76.1260),
        wardId: 'W-WG-02',
        status: 'SAFE',
        elevationMeters: 960,
      ),
    ];

    _catchments = [
      CatchmentBasin(
        id: 'CAT-WG-01',
        name: 'Chaliyar River Headwater Catchment',
        riverSystem: 'Chaliyar Basin (Western Ghats)',
        areaSqKm: 98.4,
        meanElevationMeters: 1120,
        meanSlopeDegrees: 31.0,
        runoffCoefficient: 0.78,
        isGauged: true,
        boundaryPolygon: const [
          LatLng(11.5650, 76.1150),
          LatLng(11.5750, 76.1750),
          LatLng(11.5150, 76.1850),
          LatLng(11.5050, 76.1200),
        ],
        drainageNetwork: const [
          DrainageStream(
            id: 'STR-WG-01',
            name: 'Punnapuzha Torrent',
            order: 3,
            points: [
              LatLng(11.5700, 76.1700),
              LatLng(11.5450, 76.1450),
              LatLng(11.5250, 76.1300),
            ],
            currentFlowCumecs: 142.0,
            peakCapacityCumecs: 180.0,
          ),
        ],
        exposedVillageIds: const ['W-WG-01', 'W-WG-02'],
        criticalAssets: _infrastructure,
        currentRisk: AlertLevel.warning,
        riskTrend: RiskTrend.increasing,
        horizonPredictions: const [],
        evidence: const PredictionEvidence(
          rainfallContributionPercent: 48.0,
          soilWetnessContributionPercent: 30.0,
          slopeContributionPercent: 12.0,
          lulcContributionPercent: 6.0,
          upstreamDischargePercent: 4.0,
          dominantTrigger: 'High Intensity Monsoon Cloudburst on Saturated Plantation Slopes',
          hydrologicalMechanism: 'Pore pressure spikes in lateritic soil mantle over bedrock interface.',
        ),
        geomorphicFingerprint: const StaticGeomorphicFingerprint(
          reliefMeters: 1480.0,
          drainageDensityKmPerKm2: 3.12,
          maxStreamOrder: 3,
          topographicWetnessIndex: 8.85,
          dominantLulc: 'Tea Plantation & Tropical Evergreen Canopy (72%)',
          dominantSoil: 'Lateritic Red Loam with High Clay Substratum',
          hypsometricIntegral: 0.51,
          timeOfConcentrationHours: 1.45,
          channelSinuosity: 1.34,
        ),
      ),
    ];

    _wards = [
      WardRisk(
        id: 'W-WG-01',
        name: 'Chooralmala / Mundakkai Sector',
        district: 'Wayanad',
        state: 'Kerala',
        catchmentId: 'CAT-WG-01',
        catchmentName: 'Chaliyar River Headwater Catchment',
        center: const LatLng(11.5310, 76.1520),
        elevationMeters: 840,
        population: 3100,
        highRiskHouseholds: 280,
        alertLevel: AlertLevel.critical,
        trend: RiskTrend.increasing,
        riskScore: 88.0,
        floodProbability: 94.0,
        landslideProbability: 91.0,
        evacuationLeadTimeMinutes: 18,
        rainfall1hMm: 52.0,
        accumulated24hRainMm: 145.0,
        soilSaturationPercent: 92.0,
        factorOfSafety: 0.98,
        slopeAngleDegrees: 36.0,
        lulcType: 'Tea Plantation on Steep Slope',
        actionAdvisory: 'Immediate evacuation from river bank settlements to Meppadi School.',
        designatedSafeRoute: 'Follow Mundakkai Upper Ridge Road to Meppadi Higher Secondary School',
        boundaryPoints: const [
          LatLng(11.5380, 11.5450),
          LatLng(11.5390, 76.1600),
          LatLng(11.5240, 76.1610),
          LatLng(11.5230, 76.1460),
        ],
      ),
      WardRisk(
        id: 'W-WG-02',
        name: 'Meppadi High Ridge Haven',
        district: 'Wayanad',
        state: 'Kerala',
        catchmentId: 'CAT-WG-01',
        catchmentName: 'Chaliyar River Headwater Catchment',
        center: const LatLng(11.5520, 76.1280),
        elevationMeters: 1020,
        population: 4500,
        highRiskHouseholds: 40,
        alertLevel: AlertLevel.safe,
        trend: RiskTrend.stable,
        riskScore: 22.0,
        floodProbability: 15.0,
        landslideProbability: 20.0,
        evacuationLeadTimeMinutes: 300,
        rainfall1hMm: 12.0,
        accumulated24hRainMm: 45.0,
        soilSaturationPercent: 48.0,
        factorOfSafety: 1.85,
        slopeAngleDegrees: 16.0,
        lulcType: 'Plateau Settlement / High Ground',
        actionAdvisory: 'Safe assembly point. Relief camp functioning at High School.',
        designatedSafeRoute: 'Primary Refuge Zone (Stationary Safety)',
        boundaryPoints: const [
          LatLng(11.5580, 76.1220),
          LatLng(11.5590, 76.1350),
          LatLng(11.5460, 76.1360),
          LatLng(11.5450, 76.1230),
        ],
      ),
    ];

    _sensors = [
      IoTSensorNode(
        id: 'S-WG-01',
        name: 'Pore Pressure Soil Array (Chooralmala)',
        type: SensorType.soilMoisture,
        location: const LatLng(11.5330, 76.1540),
        elevationMeters: 860,
        wardId: 'W-WG-01',
        wardName: 'Chooralmala',
        lastUpdated: DateTime.now(),
        soilLayers: [
          const SoilLayerMoisture(depthCm: 10, volumetricWaterContent: 45.0, poreWaterPressureKPa: 32.0, saturationPercentage: 93.8),
          const SoilLayerMoisture(depthCm: 30, volumetricWaterContent: 42.0, poreWaterPressureKPa: 29.0, saturationPercentage: 87.5),
          const SoilLayerMoisture(depthCm: 50, volumetricWaterContent: 39.0, poreWaterPressureKPa: 25.0, saturationPercentage: 81.2),
        ],
      ),
      IoTSensorNode(
        id: 'S-WG-02',
        name: 'River Stream Gauge (Punnapuzha Bridge)',
        type: SensorType.riverLevel,
        location: const LatLng(11.5310, 76.1520),
        elevationMeters: 838,
        wardId: 'W-WG-01',
        wardName: 'Chooralmala',
        lastUpdated: DateTime.now(),
        riverWaterLevelMeters: 4.85,
        riverDangerThresholdMeters: 4.20,
        riverDischargeFlowCumecs: 165.0,
      ),
    ];

    _evacuationCenters = [
      const EvacuationCenter(
        id: 'EC-WG-01',
        name: 'Meppadi St. Joseph High School Relief Camp',
        type: CenterType.schoolReliefCamp,
        location: LatLng(11.5540, 76.1260),
        elevationMeters: 1020,
        capacity: 1500,
        currentOccupancy: 320,
        contactNumber: '+91 4936-202234',
        distanceKm: 2.8,
        hasHelipad: true,
        hasMedicalSupport: true,
      ),
    ];
  }

  @override
  void dispose() {
    _liveTelemetryTimer?.cancel();
    super.dispose();
  }
}
