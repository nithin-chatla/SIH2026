import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';


class SimulationControlPanel extends StatelessWidget {
  const SimulationControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.isSimulationActive ? const Color(0xFFEA580C) : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: service.isSimulationActive ? const Color(0xFFFFF7ED) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: service.isSimulationActive ? const Color(0xFFEA580C) : const Color(0xFF0284C7),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unified Disaster Scenario Controller',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Deterministic Environmental State Synchronization',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                  ],
                ),
              ),
              if (service.isSimulationActive)
                TextButton(
                  onPressed: () => service.applyScenarioPreset('NORMAL'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Reset Baseline',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Active Scenario Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: service.isSimulationActive ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: service.isSimulationActive ? const Color(0xFFFEE2E2) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 14,
                  color: service.isSimulationActive ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ACTIVE: ${service.activeScenario}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: service.isSimulationActive ? const Color(0xFFDC2626) : const Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 6 Standard Preset Chips (AUDIT 12 Requirements)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPresetChip(service, '1. NORMAL', 'NORMAL'),
              _buildPresetChip(service, '2. HEAVY RAIN', 'HEAVY RAIN'),
              _buildPresetChip(service, '3. HIGH WETNESS', 'HIGH ANTECEDENT WETNESS'),
              _buildPresetChip(service, '4. RAPID RESPONSE', 'RAPID CATCHMENT RESPONSE'),
              _buildPresetChip(service, '5. HIGH RISK', 'HIGH RISK'),
              _buildPresetChip(service, '6. CRITICAL RISK', 'CRITICAL RISK'),
            ],
          ),
          const SizedBox(height: 14),

          // Slider Controls
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Precipitation Forcing (CARF Boost)',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
              ),
              Text(
                '+${service.simulatedRainfallBoostMm.toInt()} mm/h',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: service.simulatedRainfallBoostMm > 50 ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: service.simulatedRainfallBoostMm > 50 ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7, elevation: 2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: service.simulatedRainfallBoostMm,
              min: 0,
              max: 120,
              divisions: 24,
              onChanged: (val) {
                service.updateSimulation(
                  rainfallBoostMm: val,
                  soilBoostPercent: (val * 0.25).clamp(0, 30),
                  scenarioName: 'Manual Calibration (+${val.toInt()} mm/h)',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    DisasterDataService service,
    String label,
    String presetKey,
  ) {
    final bool isSelected = service.activeScenario.toUpperCase().contains(presetKey);

    return InkWell(
      onTap: () => service.applyScenarioPreset(presetKey),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

