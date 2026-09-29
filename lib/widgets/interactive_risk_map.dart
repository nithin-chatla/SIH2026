import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';
import '../models/ward_risk.dart';
import '../models/evacuation_center.dart';
import '../models/catchment_model.dart';
import '../theme/app_colors.dart';

enum MapTileType {
  lightPositron,
  satellite,
  terrain,
  standard,
}

class InteractiveRiskMap extends StatefulWidget {
  final List<WardRisk> wards;
  final List<IoTSensorNode> sensors;
  final List<EvacuationCenter> evacuationCenters;
  final List<CatchmentBasin> catchments;
  final WardRisk? selectedWard;
  final LatLng? userLocation;
  final String? userWardName;
  final Function(WardRisk) onSelectWard;
  final Function(IoTSensorNode) onSelectSensor;
  final Function(EvacuationCenter)? onSelectCenter;
  final bool showSensors;
  final bool showEvacuationRoutes;
  final bool showInundationZones;
  final bool showCatchmentBoundary;
  final MapController mapController;

  const InteractiveRiskMap({
    super.key,
    required this.wards,
    required this.sensors,
    required this.evacuationCenters,
    this.catchments = const [],
    this.selectedWard,
    this.userLocation,
    this.userWardName,
    required this.onSelectWard,
    required this.onSelectSensor,
    this.onSelectCenter,
    this.showSensors = true,
    this.showEvacuationRoutes = true,
    this.showInundationZones = true,
    this.showCatchmentBoundary = true,
    required this.mapController,
  });

  @override
  State<InteractiveRiskMap> createState() => _InteractiveRiskMapState();
}

class _InteractiveRiskMapState extends State<InteractiveRiskMap> with SingleTickerProviderStateMixin {
  MapTileType _currentTileType = MapTileType.standard; // Default to OpenStreetMap
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getTileUrl() {
    switch (_currentTileType) {
      case MapTileType.lightPositron:
        return 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
      case MapTileType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapTileType.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapTileType.standard:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng centerPoint = widget.userLocation ??
        widget.selectedWard?.center ??
        (widget.wards.isNotEmpty ? widget.wards.first.center : const LatLng(30.5583, 79.5668));

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: centerPoint,
            initialZoom: 14.0,
            minZoom: 5.0,
            maxZoom: 19.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // 1. Base Map Tiles
            TileLayer(
              urlTemplate: _getTileUrl(),
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.sih.fluvia',
            ),

            // 2. Catchment Basin Polygons (if enabled)
            if (widget.showCatchmentBoundary && widget.catchments.isNotEmpty)
              PolygonLayer(
                polygons: widget.catchments.map((catchment) {
                  return Polygon(
                    points: catchment.boundaryPolygon,
                    color: const Color(0xFF0284C7).withAlpha(18),
                    borderColor: const Color(0xFF0284C7).withAlpha(120),
                    borderStrokeWidth: 2.0,
                  );
                }).toList(),
              ),

            // 3. Inundation Hazard Zones (Radial Risk Buffers)
            if (widget.showInundationZones)
              CircleLayer(
                circles: widget.wards.map((ward) {
                  final Color color = AppColors.getRiskColor(ward.alertLevel.name);
                  final double radius = ward.alertLevel == AlertLevel.critical
                      ? 650
                      : ward.alertLevel == AlertLevel.warning
                          ? 450
                          : 280;

                  return CircleMarker(
                    point: ward.center,
                    radius: radius,
                    useRadiusInMeter: true,
                    color: color.withAlpha(24),
                    borderColor: color.withAlpha(160),
                    borderStrokeWidth: 2.0,
                  );
                }).toList(),
              ),

            // 4. Live User Location Pulse Radar Wave
            if (widget.userLocation != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: widget.userLocation!,
                    radius: 350,
                    useRadiusInMeter: true,
                    color: const Color(0xFF0284C7).withAlpha(30),
                    borderColor: const Color(0xFF0284C7).withAlpha(120),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),

            // 5. River Streams & Safe Evacuation Corridors
            if (widget.showEvacuationRoutes)
              PolylineLayer(
                polylines: [
                  // Main Alaknanda River Surge Flow Line
                  Polyline(
                    points: const [
                      LatLng(30.5650, 79.5440),
                      LatLng(30.5550, 79.5490),
                      LatLng(30.5470, 79.5520),
                      LatLng(30.5380, 79.5420),
                      LatLng(30.5280, 79.5300),
                    ],
                    strokeWidth: 4.5,
                    color: const Color(0xFF0284C7),
                  ),
                  // Tributary Drainage Stream
                  Polyline(
                    points: const [
                      LatLng(30.5620, 79.5600),
                      LatLng(30.5520, 79.5540),
                      LatLng(30.5470, 79.5520),
                    ],
                    strokeWidth: 3.0,
                    color: const Color(0xFF38BDF8),
                  ),
                  // Designated Safe Evacuation Corridor (Green)
                  Polyline(
                    points: const [
                      LatLng(30.5470, 79.5520),
                      LatLng(30.5440, 79.5590),
                      LatLng(30.5380, 79.5650),
                      LatLng(30.5285, 79.5710),
                    ],
                    strokeWidth: 4.0,
                    color: const Color(0xFF16A34A),
                    pattern: const StrokePattern.dotted(),
                  ),
                ],
              ),

            // 6. Safe High-Ground Refuge Centers
            MarkerLayer(
              markers: widget.evacuationCenters.map((center) {
                return Marker(
                  point: center.location,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => widget.onSelectCenter?.call(center),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF16A34A), width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2216A34A),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shield_rounded, color: Color(0xFF16A34A), size: 20),
                    ),
                  ),
                );
              }).toList(),
            ),

            // 7. Ward Risk Status Badges
            MarkerLayer(
              markers: widget.wards.map((ward) {
                final bool isSelected = widget.selectedWard?.id == ward.id;
                final Color riskColor = AppColors.getRiskColor(ward.alertLevel.name);

                return Marker(
                  point: ward.center,
                  width: 142,
                  height: 42,
                  child: GestureDetector(
                    onTap: () {
                      widget.onSelectWard(ward);
                      widget.mapController.move(ward.center, 15.0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x120F172A),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: riskColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              ward.name.split(' - ').first,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ward.riskScore.toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: riskColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // 8. IoT Sensor Node Markers
            if (widget.showSensors)
              MarkerLayer(
                markers: widget.sensors.map((sensor) {
                  final bool isCrit = sensor.isCritical;
                  final Color sColor = isCrit ? const Color(0xFFDC2626) : const Color(0xFF0284C7);

                  return Marker(
                    point: sensor.location,
                    width: 34,
                    height: 34,
                    child: GestureDetector(
                      onTap: () => widget.onSelectSensor(sensor),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: sColor, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x180F172A),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getSensorIcon(sensor.type),
                          color: sColor,
                          size: 17,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            // 9. Live User Location Marker (Glowing Beacon)
            if (widget.userLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.userLocation!,
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0284C7).withAlpha(45),
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x330284C7),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Floating Map Controls (Bottom Right)
        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tile Layer Selector
              _buildControlBox(
                child: PopupMenuButton<MapTileType>(
                  icon: const Icon(Icons.layers_outlined, color: Color(0xFF0F172A), size: 19),
                  tooltip: 'Switch Map Layer',
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (type) => setState(() => _currentTileType = type),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: MapTileType.lightPositron, child: Text('Light Clean GIS')),
                    PopupMenuItem(value: MapTileType.satellite, child: Text('High-Res Satellite')),
                    PopupMenuItem(value: MapTileType.terrain, child: Text('Topographic Contour')),
                    PopupMenuItem(value: MapTileType.standard, child: Text('OpenStreetMap')),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Zoom In Button
              _buildMapBtn(
                icon: Icons.add_rounded,
                onTap: () {
                  final currentZoom = widget.mapController.camera.zoom;
                  widget.mapController.move(widget.mapController.camera.center, currentZoom + 1.0);
                },
                tooltip: 'Zoom In',
              ),
              const SizedBox(height: 6),

              // Zoom Out Button
              _buildMapBtn(
                icon: Icons.remove_rounded,
                onTap: () {
                  final currentZoom = widget.mapController.camera.zoom;
                  widget.mapController.move(widget.mapController.camera.center, currentZoom - 1.0);
                },
                tooltip: 'Zoom Out',
              ),
              const SizedBox(height: 8),

              // Recenter / Fit Catchment
              _buildMapBtn(
                icon: Icons.center_focus_strong_rounded,
                onTap: () {
                  if (widget.wards.isNotEmpty) {
                    widget.mapController.move(widget.wards.first.center, 14.0);
                  }
                },
                tooltip: 'Fit Valley Basin',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMapBtn({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF0F172A), size: 20),
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  IconData _getSensorIcon(SensorType type) {
    switch (type) {
      case SensorType.soilMoisture:
        return Icons.layers_outlined;
      case SensorType.slopeStability:
        return Icons.terrain_outlined;
      case SensorType.riverLevel:
        return Icons.water_outlined;
      case SensorType.rainGauge:
        return Icons.cloud_outlined;
      case SensorType.weatherRadar:
        return Icons.radar_outlined;
    }
  }
}
