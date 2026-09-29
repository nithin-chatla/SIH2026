import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';


class FluviaSensingMatrixCard extends StatelessWidget {
  const FluviaSensingMatrixCard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final ward = service.selectedWard ?? (service.wards.isNotEmpty ? service.wards.first : null);
    final catchment = service.selectedCatchment ?? (service.catchments.isNotEmpty ? service.catchments.first : null);
    final rainfall = service.getRainfallBreakdownForWard(ward?.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sensors_rounded, color: Color(0xFF0284C7), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FLUVIA SENSE Grid',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                      'ALL STREAMS LIVE',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 6-Category Grid Matrix
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 600 ? 3 : (constraints.maxWidth >= 360 ? 2 : 1);
              final childAspectRatio = constraints.maxWidth >= 600
                  ? 1.45
                  : (constraints.maxWidth >= 360 ? 1.05 : 2.2);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
                children: [
                  // 1. RAINFALL
                  _buildStreamCard(
                    category: 'RAINFALL',
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFF0284C7),
                    primaryMetric: '${rainfall['1h']?.toStringAsFixed(1)} mm/h',
                    details: [
                      '15m: ${rainfall['15m']} mm • 1h: ${rainfall['1h']} mm',
                      '3h: ${rainfall['3h']} mm • 6h: ${rainfall['6h']} mm',
                      '24h Total: ${rainfall['24h']} mm',
                    ],
                  ),

                  // 2. WEATHER & RADAR
                  _buildStreamCard(
                    category: 'WEATHER & RADAR',
                    icon: Icons.cloud_sync_outlined,
                    color: const Color(0xFF0284C7),
                    primaryMetric: '52 dBZ Core',
                    details: [
                      'Doppler: Mukteshwar Radar',
                      'Temp: 14.2°C • Humidity: 94%',
                      'GPM IMERG: Active Ingestion',
                    ],
                  ),

                  // 3. TERRAIN & SLOPE
                  _buildStreamCard(
                    category: 'TERRAIN & SLOPE',
                    icon: Icons.landscape_rounded,
                    color: const Color(0xFFD97706),
                    primaryMetric: '${catchment?.meanSlopeDegrees.toStringAsFixed(1) ?? "38.4"}° Slope',
                    details: [
                      'DEM: 30m Copernicus / Carto',
                      'Elevation: ${ward?.elevationMeters.toInt() ?? 1875}m MSL',
                      'Drainage D: ${catchment?.geomorphicFingerprint.drainageDensityKmPerKm2.toStringAsFixed(2) ?? "3.42"} km/km²',
                    ],
                  ),

                  // 4. SOIL & GROUND
                  _buildStreamCard(
                    category: 'SOIL & GROUND',
                    icon: Icons.grass_rounded,
                    color: const Color(0xFF16A34A),
                    primaryMetric: '${ward?.soilSaturationPercent.toStringAsFixed(1) ?? "74.5"}% Sat',
                    details: [
                      'API-7 Wetness: ${rainfall['api7']} mm',
                      'Pore Pressure: Elevated',
                      'Infiltration: 18 mm/h (Group B)',
                    ],
                  ),

                  // 5. HYDROLOGY
                  _buildStreamCard(
                    category: 'HYDROLOGY',
                    icon: Icons.waves_rounded,
                    color: const Color(0xFF7C3AED),
                    primaryMetric: '3.85m Stage',
                    details: [
                      'Discharge: 162 cumecs (Surging)',
                      'Trend: ${ward?.trend.name.toUpperCase() ?? "INCREASING"}',
                      'CWC Gauge: Alaknanda #04',
                    ],
                  ),


                  // 6. IoT NODES
                  _buildStreamCard(
                    category: 'IoT TELEMETRY',
                    icon: Icons.cell_tower_rounded,
                    color: const Color(0xFFEA580C),
                    primaryMetric: '${service.sensors.length} Active Nodes',
                    details: [
                      'TDR Soil: Online (100%)',
                      'Ultrasonic River: Online (98%)',
                      'Rain Gauge Mesh: Low Latency',
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Sensing Output Summary Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Color(0xFF38BDF8), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATCHMENT STATE: HYDRAULICALLY SURGING',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'CARF Forcing: ${rainfall['1h']} mm/h • API-7: ${rainfall['api7']}mm • Runoff Coeff: ${catchment?.runoffCoefficient ?? 0.72}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamCard({
    required String category,
    required IconData icon,
    required Color color,
    required String primaryMetric,
    required List<String> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            primaryMetric,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.map((d) => Text(
              d,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: const Color(0xFF64748B),
                height: 1.25,
              ),
              overflow: TextOverflow.ellipsis,
            )).toList(),
          ),
        ],
      ),
    );
  }
}
