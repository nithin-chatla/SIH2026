import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../services/disaster_data_service.dart';
import '../models/ward_risk.dart';
import '../models/sensor_data.dart';
import '../models/evacuation_center.dart';
import '../theme/app_colors.dart';
import '../widgets/interactive_risk_map.dart';
import '../widgets/risk_gauge_meter.dart';
import '../widgets/lead_time_counter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  bool _showSensors = true;
  bool _showEvacuationRoutes = true;
  bool _showInundationZones = true;
  bool _showCatchmentBoundary = true;

  WardRisk? _inspectedWard;
  IoTSensorNode? _inspectedSensor;
  EvacuationCenter? _inspectedCenter;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    final user = service.currentUser;

    // Calculate real-time 24/7 Safety Percentage
    final double avgRisk = service.wards.isEmpty
        ? 15.0
        : service.wards.map((w) => w.riskScore).reduce((a, b) => a + b) / service.wards.length;
    final double safetyPercentage = (100.0 - avgRisk).clamp(0.0, 100.0);

    final Color safetyColor = safetyPercentage >= 75
        ? const Color(0xFF16A34A)
        : safetyPercentage >= 45
            ? const Color(0xFFEA580C)
            : const Color(0xFFDC2626);

    final Color safetyBg = safetyPercentage >= 75
        ? const Color(0xFFF0FDF4)
        : safetyPercentage >= 45
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFFEF2F2);

    return Scaffold(
      body: Stack(
        children: [
          // 1. The Interactive GIS Map
          InteractiveRiskMap(
            mapController: _mapController,
            wards: service.wards,
            sensors: service.sensors,
            evacuationCenters: service.evacuationCenters,
            catchments: service.catchments,
            selectedWard: _inspectedWard ?? service.selectedWard,
            userLocation: user?.currentCoordinates,
            userWardName: user?.currentWardName,
            showSensors: _showSensors,
            showEvacuationRoutes: _showEvacuationRoutes,
            showInundationZones: _showInundationZones,
            showCatchmentBoundary: _showCatchmentBoundary,
            onSelectWard: (ward) {
              setState(() {
                _inspectedWard = ward;
                _inspectedSensor = null;
                _inspectedCenter = null;
              });
              service.selectWard(ward);
            },
            onSelectSensor: (sensor) {
              setState(() {
                _inspectedSensor = sensor;
                _inspectedWard = null;
                _inspectedCenter = null;
              });
              service.selectSensor(sensor);
            },
            onSelectCenter: (center) {
              setState(() {
                _inspectedCenter = center;
                _inspectedWard = null;
                _inspectedSensor = null;
              });
            },
          ),

          // 2. 24/7 Persistent Top Safety Index & Layer Control Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 24/7 Real-Time Safety Percentage Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F0F172A),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // 24/7 Pulse Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: safetyBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: safetyColor.withAlpha(50)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: safetyColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '24/7 AI SAFETY INDEX',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: safetyColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Safety Percentage Score
                            Text(
                              '${safetyPercentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: safetyColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SAFE',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: safetyColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Progress Safety Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: safetyPercentage / 100.0,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(safetyColor),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Quick Status Snippet
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Valley Catchment: Alaknanda Basin (Normal Flow)',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${service.criticalWardsCount} Critical Wards',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: service.criticalWardsCount > 0
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Layer Filter Toggles
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterToggle(
                          label: 'Sensors (${service.sensors.length})',
                          icon: Icons.sensors,
                          isActive: _showSensors,
                          onToggle: () => setState(() => _showSensors = !_showSensors),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterToggle(
                          label: 'Hazard Zones',
                          icon: Icons.radar,
                          isActive: _showInundationZones,
                          onToggle: () => setState(() => _showInundationZones = !_showInundationZones),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterToggle(
                          label: 'Evac Routes',
                          icon: Icons.alt_route_rounded,
                          isActive: _showEvacuationRoutes,
                          onToggle: () => setState(() => _showEvacuationRoutes = !_showEvacuationRoutes),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterToggle(
                          label: 'Basin Border',
                          icon: Icons.polyline_rounded,
                          isActive: _showCatchmentBoundary,
                          onToggle: () => setState(() => _showCatchmentBoundary = !_showCatchmentBoundary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating "My Live Location" & Fast Navigation Buttons (Bottom Left)
          Positioned(
            bottom: 24,
            left: 16,
            child: FloatingActionButton.extended(
              heroTag: 'myLiveLocationFab',
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                'My Live Location',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                final targetCoords = user?.currentCoordinates ??
                    (service.wards.isNotEmpty ? service.wards.first.center : const LatLng(30.5470, 79.5520));

                _mapController.move(targetCoords, 15.5);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Panned to Live Location: ${user?.currentWardName ?? 'Alaknanda Riverfront'}',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFF0284C7),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),

          // 4. Inspection Bottom Floating Card (When any element is tapped)
          if (_inspectedWard != null || _inspectedSensor != null || _inspectedCenter != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: isDesktop ? null : 16,
              width: isDesktop ? 400 : null,
              child: _buildInspectionCard(context, service),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0284C7) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionCard(BuildContext context, DisasterDataService service) {
    if (_inspectedWard != null) {
      return _buildWardInspectorCard(_inspectedWard!, service);
    } else if (_inspectedSensor != null) {
      return _buildSensorInspectorCard(_inspectedSensor!);
    } else if (_inspectedCenter != null) {
      return _buildCenterInspectorCard(_inspectedCenter!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildWardInspectorCard(WardRisk ward, DisasterDataService service) {
    final Color riskColor = AppColors.getRiskColor(ward.alertLevel.name);
    final Color riskBg = AppColors.getRiskBg(ward.alertLevel.name);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ward.alertLevelName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () => setState(() => _inspectedWard = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ward.name,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            '${ward.district} • Elevation ${ward.elevationMeters.toInt()}m • Pop: ${ward.population}',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              RiskGaugeMeter(score: ward.riskScore, size: 80, showTiers: false),
              const SizedBox(width: 10),
              Expanded(
                child: LeadTimeCounter(
                  leadTimeMinutes: ward.evacuationLeadTimeMinutes,
                  wardName: ward.name,
                  isCompact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ward.actionAdvisory,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final nearest = service.getNearestCenter(ward.center);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Safe Corridor mapped to ${nearest.name} (Elev: ${nearest.elevationMeters.toInt()}m)'),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.navigation_rounded, size: 15),
              label: const Text('Start Safe Evacuation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorInspectorCard(IoTSensorNode sensor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sensor.typeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () => setState(() => _inspectedSensor = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(sensor.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          Text('Node ID: ${sensor.id} • Ward: ${sensor.wardName}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LIVE TELEMETRY', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                    Text(sensor.primaryReadingString, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0284C7))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('BATTERY / NODE', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                    Text('${sensor.batteryPercent}% • Online', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterInspectorCard(EvacuationCenter center) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SAFE REFUGE HAVEN',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () => setState(() => _inspectedCenter = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(center.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          Text('Elevation: ${center.elevationMeters.toInt()}m MSL • Distance: ${center.distanceKm} km', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Beds: ${center.availableBeds} / ${center.capacity}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
              Text('Helpline: ${center.contactNumber}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF0284C7), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
