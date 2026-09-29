import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';

class EndToEndDemoWizard extends StatelessWidget {
  const EndToEndDemoWizard({super.key});

  static const List<Map<String, dynamic>> _stages = [
    {
      'title': '1. SENSE',
      'label': 'Multi-Source Data Ingestion',
      'desc': 'Ingesting IMD Doppler radar, NASA GPM rainfall, Copernicus 30m DEM, SMAP soil moisture, and IoT ground sensor telemetry.',
      'badge': 'DATA INGESTION',
      'color': Color(0xFF0284C7),
    },
    {
      'title': '2. HARMONIZE',
      'label': 'Spatial & Temporal Alignment',
      'desc': 'Harmonizing coarse gridded satellite precipitation and soil grids into hydrologically aligned catchment forcing without false downscaling.',
      'badge': 'INTERSECTION',
      'color': Color(0xFF0D9488),
    },
    {
      'title': '3. MODEL',
      'label': 'Catchment Modeling & PUB',
      'desc': 'Delineating sub-catchments, extracting static geomorphic fingerprints, and regionalizing parameters to data-sparse ungauged basins.',
      'badge': 'PUB TRANSFER',
      'color': Color(0xFF7C3AED),
    },
    {
      'title': '4. PREDICT',
      'label': 'Multi-Horizon Peak Surge Forecasting',
      'desc': 'Catchment-aware ML engine generates multi-horizon predictions: 6H (Prepare), 3H (Ready), 1H (Immediate Action), and 30M (Local Crest).',
      'badge': '6H / 3H / 1H / 30M',
      'color': Color(0xFFEA580C),
    },
    {
      'title': '5. LOCALIZE',
      'label': 'Downstream Vulnerability Tracing',
      'desc': 'Tracing runoff and debris surge down the Strahler drainage network to identify exposed downstream villages, bridges, and hospitals.',
      'badge': 'EXPOSURE TRACING',
      'color': Color(0xFFDC2626),
    },
    {
      'title': '6. VERIFY',
      'label': 'Authority Evidence Review',
      'desc': 'Officer reviews hydrological triggers (rainfall contribution, soil wetness, slope instability) before official public warning dissemination.',
      'badge': 'DECISION SUPPORT',
      'color': Color(0xFF2563EB),
    },
    {
      'title': '7. ALERT',
      'label': 'Targeted CAP Geo-Warning Dispatch',
      'desc': 'Authorized officer dispatches 5-level Common Alerting Protocol warning via Push Notification, SMS Relay, and Automated Local Sirens.',
      'badge': 'MULTI-CHANNEL CAP',
      'color': Color(0xFFDC2626),
    },
    {
      'title': '8. ACT',
      'label': 'Citizen Evacuation & Protective Action',
      'desc': 'Citizen receives location-aware alert with exact lead time countdown and 1-tap navigation to designated high-ground refuge shelters.',
      'badge': 'LIFE SAFETY CORRIDOR',
      'color': Color(0xFF16A34A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final int currentStage = service.demoStageIndex;
    final stageInfo = _stages[currentStage.clamp(0, _stages.length - 1)];
    final Color stageColor = stageInfo['color'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stageColor.withAlpha(100), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: stageColor.withAlpha(20), shape: BoxShape.circle),
                child: Icon(Icons.play_circle_filled_rounded, color: stageColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'FLUVIA 8-Stage Disaster Lifecycle',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                onPressed: () => service.resetDemoWizard(),
                tooltip: 'Exit Lifecycle Guide',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 8-Step Pill Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _stages.asMap().entries.map((entry) {
                final idx = entry.key;
                final isCurrent = idx == currentStage;
                final isPast = idx < currentStage;
                final c = entry.value['color'] as Color;

                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? c : isPast ? c.withAlpha(30) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.value['title'],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isCurrent ? Colors.white : isPast ? c : const Color(0xFF64748B),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Active Stage Narrative Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stageInfo['label'],
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: stageColor.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                      child: Text(stageInfo['badge'], style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: stageColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  stageInfo['desc'],
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Previous, Next, and Reset Controls
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: currentStage > 0 ? () => service.previousDemoStage() : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: currentStage < 7
                    ? () => service.nextDemoStage()
                    : () => service.resetDemoWizard(),
                icon: Icon(currentStage < 7 ? Icons.arrow_forward_rounded : Icons.check_circle_rounded, size: 14),
                label: Text(currentStage < 7 ? 'Next (${currentStage + 2}/8)' : 'Complete Lifecycle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: stageColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
