import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/disaster_data_service.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';
import '../widgets/sensor_telemetry_card.dart';

class IoTSensorsScreen extends StatefulWidget {
  const IoTSensorsScreen({super.key});

  @override
  State<IoTSensorsScreen> createState() => _IoTSensorsScreenState();
}

class _IoTSensorsScreenState extends State<IoTSensorsScreen> {
  SensorType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;
    final isMobile = screenWidth < 600;

    final filteredSensors = _selectedFilter == null
        ? service.sensors
        : service.sensors.where((s) => s.type == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMobile ? 'IoT Telemetry Grid' : 'IoT Multi-Source Telemetry Grid',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.safeGreenBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.safeGreenBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub_outlined, size: 13, color: AppColors.safeGreen),
                const SizedBox(width: 4),
                Text(
                  isMobile ? 'LoRa' : 'LoRa MESH',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.safeGreen),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Pills (Clean Light Styling)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All (${service.sensors.length})', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Soil Array', SensorType.soilMoisture),
                  const SizedBox(width: 8),
                  _buildFilterChip('Slope Tilt', SensorType.slopeStability),
                  const SizedBox(width: 8),
                  _buildFilterChip('River Level', SensorType.riverLevel),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rainfall', SensorType.rainGauge),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Hydrograph Curve Card (Clean White Canvas)
            _buildHydrographChartCard(context, service),
            const SizedBox(height: 24),

            // Telemetry Cards Grid
            Text(
              'LIVE FIELD TELEMETRY NODES',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            if (isDesktop)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.3,
                ),
                itemCount: filteredSensors.length,
                itemBuilder: (context, index) {
                  return SensorTelemetryCard(
                    sensor: filteredSensors[index],
                    onTap: () => _showSensorDetailsDialog(context, filteredSensors[index]),
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredSensors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SensorTelemetryCard(
                      sensor: filteredSensors[index],
                      onTap: () => _showSensorDetailsDialog(context, filteredSensors[index]),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, SensorType? type) {
    final bool isSelected = _selectedFilter == type;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHydrographChartCard(BuildContext context, DisasterDataService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydrograph & Discharge Crest Forecaster (12h Horizon)',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Alaknanda River Catchment • Ultrasonic Gauge Node S-301',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.criticalRedBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.criticalRedBorder),
                ),
                child: Text('Danger Mark: 4.5m', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.criticalRed)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.borderLight, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return Text('-6h', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted));
                          case 3: return Text('-3h', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted));
                          case 6: return Text('NOW', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary));
                          case 9: return Text('+3h', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.criticalRed));
                          case 12: return Text('+6h', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(1)}m', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 12,
                minY: 1.0,
                maxY: 6.0,
                lineBarsData: [
                  // Danger Mark Constant Line
                  LineChartBarData(
                    spots: const [FlSpot(0, 4.5), FlSpot(12, 4.5)],
                    isCurved: false,
                    color: AppColors.criticalRed,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                  // River Level Actual & Predicted Curve
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 2.1),
                      const FlSpot(2, 2.4),
                      const FlSpot(4, 3.1),
                      FlSpot(6, (4.35 + service.simulatedRainfallBoostMm * 0.015).clamp(2.0, 5.8)),
                      FlSpot(8, (4.9 + service.simulatedRainfallBoostMm * 0.02).clamp(2.0, 5.9)),
                      FlSpot(10, (4.6 + service.simulatedRainfallBoostMm * 0.01).clamp(2.0, 5.5)),
                      const FlSpot(12, 3.8),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primarySurface,
                    ),
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot.x == 6 || spot.x == 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSensorDetailsDialog(BuildContext context, IoTSensorNode sensor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
          title: Text(sensor.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Telemetry: ${sensor.primaryReadingString}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('Coordinates: ${sensor.location.latitude.toStringAsFixed(4)}°N, ${sensor.location.longitude.toStringAsFixed(4)}°E', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              Text('Altitude: ${sensor.elevationMeters.toStringAsFixed(0)} m MSL', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              Text('Telemetry Gateway: LoRaWAN 868MHz (Active)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.safeGreen, fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
